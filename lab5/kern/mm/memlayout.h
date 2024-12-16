#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* This file contains the definitions for memory management in our OS. */

/* *
 * 虚拟内存映射:                                          权限
 *                                                      内核/用户
 *
 *     4G ------------------> +---------------------------------+
 *                            |                                 |
 *                            |         空内存 (*)                |
 *                            |                                 |
 *                            +---------------------------------+ 0xFB000000
 *                            |   当前页表 (内核, 读写)           | 读写/--
 *     VPT -----------------> +---------------------------------+ 0xFAC00000
 *                            |        无效内存 (*)              | --/--
 *     KERNTOP -------------> +---------------------------------+ 0xF8000000
 *                            |                                 |
 *                            |    重映射的物理内存               | 读写/--
 *                            |                                 |
 *     KERNBASE ------------> +---------------------------------+ 0xC0000000
 *                            |        无效内存 (*)              | --/--
 *     USERTOP -------------> +---------------------------------+ 0xB0000000
 *                            |           用户栈                  |
 *                            +---------------------------------+
 *                            |                                 |
 *                            :                                 :
 *                            |         ~~~~~~~~~~~~~~~~        |
 *                            :                                 :
 *                            |                                 |
 *                            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *                            |       用户程序和堆               |
 *     UTEXT ---------------> +---------------------------------+ 0x00800000
 *                            |        无效内存 (*)              | --/--
 *                            |  - - - - - - - - - - - - - - -  |
 *                            |    用户STAB数据 (可选)            |
 *     USERBASE, USTAB------> +---------------------------------+ 0x00200000
 *                            |        无效内存 (*)              | --/--
 *     0 -------------------> +---------------------------------+ 0x00000000
 * (*) 注意: 内核确保 "无效内存" *永远不会* 被映射。
 *     "空内存" 通常是未映射的，但用户程序可以根据需要映射页面。
 *
 * */

/*
 * 所有物理内存映射到这个地址
 */
/* All physical memory mapped at this address */
#define KERNBASE 0xFFFFFFFFC0200000
#define KMEMSIZE 0x7E00000 // the maximum amount of physical memory
#define KERNTOP (KERNBASE + KMEMSIZE)

#define KERNEL_BEGIN_PADDR 0x80200000
#define KERNEL_BEGIN_VADDR 0xFFFFFFFFC0200000
#define PHYSICAL_MEMORY_END 0x88000000
/* *
 * The end address of physical memory.
 * This is the address where physical memory ends and any memory beyond this address is invalid.
 * */
#define PHYSICAL_MEMORY_END 0x88000000

#define KSTACKPAGE 2                     // # of pages in kernel stack
#define KSTACKSIZE (KSTACKPAGE * PGSIZE) // sizeof kernel stack
// USERTOP 表示用户空间地址范围的顶部地址（最高地址）
#define USERTOP 0x80000000
// USTACKTOP 表示用户堆栈的栈顶地址，其值与 USERTOP 相同
#define USTACKTOP USERTOP
// USTACKPAGE 定义了用户栈的页数，值为 256 页。
#define USTACKPAGE 256 // # of pages in user stack
// USTACKSIZE 表示用户栈的总大小，值为 USTACKPAGE × PGSIZE。
#define USTACKSIZE (USTACKPAGE * PGSIZE) // sizeof user stack
// USERBASE 定义了用户空间的起始地址
#define USERBASE 0x00200000
// UTEXT 表示用户程序代码段（Text Segment）通常开始的地址
#define UTEXT 0x00800000 // where user programs generally begin
// USTAB 定义了用户程序中的 STABS 数据结构 的起始地址，值为 USERBASE。USTAB用于提供符号表地址，使调试器可以查找程序中的变量或函数信息。
#define USTAB USERBASE // the location of the user STABS data structure
// 检查一个地址范围是否在用户空间范围内。
#define USER_ACCESS(start, end) \
    (USERBASE <= (start) && (start) < (end) && (end) <= USERTOP)
// 检查一个地址范围是否在内核空间范围内。
#define KERN_ACCESS(start, end) \
    (KERNBASE <= (start) && (start) < (end) && (end) <= KERNTOP)
// 防止代码被汇编器（assembler）处理。
#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t;
typedef uintptr_t pde_t;
typedef pte_t swap_entry_t; // the pte can also be a swap entry

/* *
 * struct Page - 页面描述符结构体。每个Page描述一个物理页面。
 * 在kern/mm/pmm.h中，你可以找到很多有用的函数，用于将Page转换为其他数据类型，比如物理地址。
 * */
struct Page
{
    int ref;                    // 页面帧的引用计数
    uint64_t flags;             // 描述页面帧状态的标志数组
    unsigned int property;      // 空闲块的数量，在首次适应物理内存管理器中使用
    list_entry_t page_link;     // 空闲链表链接
    list_entry_t pra_page_link; // 用于页面替换算法
    uintptr_t pra_vaddr;        // 用于页面置换算法，记录页面对应的虚拟地址。
};

/* Flags describing the status of a page frame */
#define PG_reserved 0 // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0
#define PG_property 1 // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.
// 设置 page 的 PG_reserved 标志位。表示该页被保留（reserved），通常用于防止内存管理子系统对某些关键页面的误操作。
#define SetPageReserved(page) set_bit(PG_reserved, &((page)->flags))
// 清除 page 的 PG_reserved 标志位。表示该页不再被保留（reserved）。
#define ClearPageReserved(page) clear_bit(PG_reserved, &((page)->flags))
// 检测 page 的 PG_reserved 标志位是否被设置。确定该页是否处于保留状态。
#define PageReserved(page) test_bit(PG_reserved, &((page)->flags))
// 设置 page 的 PG_property 标志位。
#define SetPageProperty(page) set_bit(PG_property, &((page)->flags))
// 清除 page 的 PG_property 标志位。
#define ClearPageProperty(page) clear_bit(PG_property, &((page)->flags))
// 检测 page 的 PG_property 标志位是否被设置。
#define PageProperty(page) test_bit(PG_property, &((page)->flags))

// convert list entry to page
#define le2page(le, member) \
    to_struct((le), struct Page, member)

/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct
{
    list_entry_t free_list; // the list header
    unsigned int nr_free;   // # of free pages in this free list
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */
