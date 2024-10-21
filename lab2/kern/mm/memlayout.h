#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* All physical memory mapped at this address */
#define KERNBASE            0xFFFFFFFFC0200000 // = 0x80200000(物理内存里内核的起始位置, KERN_BEGIN_PADDR) + 0xFFFFFFFF40000000(偏移量, PHYSICAL_MEMORY_OFFSET)
//把原有内存映射到虚拟内存空间的最后一页
#define KMEMSIZE            0x7E00000          // the maximum amount of physical memory
// 0x7E00000 = 0x8000000 - 0x200000
// QEMU 缺省的RAM为 0x80000000到0x88000000, 128MiB, 0x80000000到0x80200000被OpenSBI占用
#define KERNTOP             (KERNBASE + KMEMSIZE) // 0x88000000对应的虚拟地址
//PHYSICAL_MEMORY_END：定义物理内存的结束地址。
#define PHYSICAL_MEMORY_END         0x88000000
//PHYSICAL_MEMORY_OFFSET：定义虚拟地址与物理地址之间的偏移量。
#define PHYSICAL_MEMORY_OFFSET      0xFFFFFFFF40000000
//KERNEL_BEGIN_PADDR 和 KERNEL_BEGIN_VADDR：定义内核在物理和虚拟地址空间的起始位置。
#define KERNEL_BEGIN_PADDR          0x80200000
#define KERNEL_BEGIN_VADDR          0xFFFFFFFFC0200000

//KSTACKPAGE 和 KSTACKSIZE：定义内核栈的页数和大小。
#define KSTACKPAGE          2                           // # of pages in kernel stack
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t;
typedef uintptr_t pde_t;

/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as physical address.
 * */
//struct Page：描述一个物理页的结构，包含引用计数、状态标志、空闲块数量以及用于链表的链接。
struct Page {
    // ref：页面的引用计数，表示该页被引用的次数。
    int ref;                        // page frame's reference counter
    // flags：页面的状态标志，包括保留标志和属性标志。
    uint64_t flags;                 // array of flags that describe the status of the page frame
    // property：页面的空闲块数量，用于first fit物理内存管理。
    unsigned int property;          // the num of free block, used in first fit pm manager
    // page_link：页面的链表链接，用于空闲页链表。
    list_entry_t page_link;         // free list link
};

/* Flags describing the status of a page frame */
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.
//设置页面的保留标志，表示该页不可用于分配或释放。
#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))
//清除页面的保留标志，表示该页可以用于分配或释放。
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))
//检查页面的保留标志，返回该页是否被保留。
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))
//设置页面的属性标志，表示该页是空闲内存块的头页。
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))
//清除页面的属性标志，表示该页不是空闲内存块的头页。
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))
//检查页面的属性标志，返回该页是否是空闲内存块的头页。
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))

// convert list entry to page
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)

/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // number of free pages in this free list
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */
