#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

#include <assert.h>
#include <atomic.h>
#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <riscv.h>

// pmm_manager is a physical memory management class. A special pmm manager -
// XXX_pmm_manager
// only needs to implement the methods in pmm_manager class, then
// XXX_pmm_manager can be used
// by ucore to manage the total physical memory space.
//定义了一个物理内存管理器的结构体，包含了初始化、初始化内存映射、分配内存、释放内存、获取空闲页数、检查的函数指针。
struct pmm_manager {
    // name：物理内存管理器的名称。
    const char *name;  // XXX_pmm_manager's name
    // init：初始化内存管理器的函数指针。
    void (*init)(
        void);  // initialize internal description&management data structure
                // (free block list, number of free block) of XXX_pmm_manager
    // init_memmap：根据初始的空闲物理内存空间设置描述和管理数据结构的函数指针。
    void (*init_memmap)(
        struct Page *base,
        size_t n);  // setup description&management data structcure according to
                    // the initial free physical memory space
    // alloc_pages：分配>=n个物理页的函数指针，根据分配算法的不同，分配的页数可能会大于n。
    struct Page *(*alloc_pages)(
        size_t n);  // allocate >=n pages, depend on the allocation algorithm
    // free_pages：释放>=n个物理页的函数指针，根据释放算法的不同，释放的页数可能会大于n。
    void (*free_pages)(struct Page *base, size_t n);  // free >=n pages with
                                                      // "base" addr of Page
                                                      // descriptor
                                                      // structures(memlayout.h)
    // nr_free_pages：获取空闲页数的函数指针。
    size_t (*nr_free_pages)(void);  // return the number of free pages
    // check：检查物理内存管理器的正确性的函数指针。
    void (*check)(void);            // check the correctness of XXX_pmm_manager
};

extern const struct pmm_manager *pmm_manager;

void pmm_init(void);

struct Page *alloc_pages(size_t n);
void free_pages(struct Page *base, size_t n);
size_t nr_free_pages(void); // number of free pages

#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)


/* *
 * PADDR - takes a kernel virtual address (an address that points above
 * KERNBASE),
 * where the machine's maximum 256MB of physical memory is mapped and returns
 * the
 * corresponding physical address.  It panics if you pass it a non-kernel
 * virtual address.
 * */
//PADDR：将一个内核虚拟地址转换为对应的物理地址，如果传递了一个无效的内核虚拟地址，则会触发panic。
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
/*
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })
*/
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;
// page2ppn - 地址转换函数，将一个Page结构体指针转换为对应的物理页号。
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
// page2pa - 地址转换函数，将一个Page结构体指针转换为对应的物理地址。
static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}


// page_ref - 获取页面的引用计数。
static inline int page_ref(struct Page *page) { return page->ref; }
// set_page_ref - 设置页面的引用计数。
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
// page_ref_inc - 页面引用计数加一。
static inline int page_ref_inc(struct Page *page) {
    page->ref += 1;
    return page->ref;
}
// page_ref_dec - 页面引用计数减一。
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
// pa2page - 地址转换函数，将一个物理地址转换为对应的Page结构体指针。
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
}
//flush_tlb - 刷新TLB缓存。
/*asm volatile("sfence.vm")：这是一个内联汇编指令，用于执行一个特定的操作。
在 RISC-V 架构中，sfence.vm 指令用于确保虚拟内存相关的操作完成并且更新生效，防止因 TLB 缓存未更新而导致的内存访问错误。*/
static inline void flush_tlb() { asm volatile("sfence.vm"); }
extern char bootstack[], bootstacktop[]; // defined in entry.S

#endif /* !__KERN_MM_PMM_H__ */
