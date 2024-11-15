#ifndef __KERN_MM_SWAP_H__
#define __KERN_MM_SWAP_H__

#include <defs.h>
#include <memlayout.h>
#include <pmm.h>
#include <vmm.h>

/* *
 * swap_entry_t
 * --------------------------------------------
 * |         offset        |   reserved   | 0 |
 * --------------------------------------------
 *           24 bits            7 bits    1 bit
 * */

#define MAX_SWAP_OFFSET_LIMIT (1 << 24)

extern size_t max_swap_offset;

/* *
 * swap_offset - takes a swap_entry (saved in pte), and returns
 * the corresponding offset in swap mem_map.
 * */
#define swap_offset(entry) ({                             \
     size_t __offset = (entry >> 8);                      \
     if (!(__offset > 0 && __offset < max_swap_offset))   \
     {                                                    \
          panic("invalid swap_entry_t = %08x.\n", entry); \
     }                                                    \
     __offset;                                            \
})

struct swap_manager
{
     // 该字段用于存储交换管理器的名称
     const char *name;
     /* Global initialization for the swap manager */
     // 该函数指针指向一个初始化函数，负责全局初始化交换管理器。
     int (*init)(void);
     /* Initialize the priv data inside mm_struct */
     // 该函数指针指向一个初始化函数，负责初始化 mm_struct 中的私有数据。
     int (*init_mm)(struct mm_struct *mm);

     /* Called when tick interrupt occured */
     // 该函数指针指向一个函数，负责处理时钟中断。
     int (*tick_event)(struct mm_struct *mm);
     /* Called when map a swappable page into the mm_struct */
     // 该函数指针指向一个将可交换页面映射到虚拟地址空间的函数。当一个页面需要交换时，这个函数会被调用。
     // swap_in 参数标识是否是将页面从交换区加载回内存（swap_in 为 1）还是将页面从内存交换到交换空间（swap_in 为 0）。
     int (*map_swappable)(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
     /* When a page is marked as shared, this routine is called to
      * delete the addr entry from the swap manager */
     // 该函数指针用于标记某个页面为不可交换。当一个页面被标记为“不可交换”时，交换管理器将不再交换它。
     int (*set_unswappable)(struct mm_struct *mm, uintptr_t addr);
     /* Try to swap out a page, return then victim */
     // 该函数指针指向一个函数，负责尝试将一个页面换出到交换空间。
     int (*swap_out_victim)(struct mm_struct *mm, struct Page **ptr_page, int in_tick);
     /* check the page relpacement algorithm */
     // 该函数指针指向一个函数，负责检查页面替换算法。
     int (*check_swap)(void);
};

extern volatile int swap_init_ok;
int swap_init(void);
int swap_init_mm(struct mm_struct *mm);
int swap_tick_event(struct mm_struct *mm);
int swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
int swap_set_unswappable(struct mm_struct *mm, uintptr_t addr);
int swap_out(struct mm_struct *mm, int n, int in_tick);
int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result);

// #define MEMBER_OFFSET(m,t) ((int)(&((t *)0)->m))
// #define FROM_MEMBER(m,t,a) ((t *)((char *)(a) - MEMBER_OFFSET(m,t)))

#endif
