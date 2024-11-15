#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

#include <assert.h>
#include <atomic.h>
#include <defs.h>
#include <memlayout.h>
#include <mmu.h>

// pmm_manager is a physical memory management class. A special pmm manager -
// XXX_pmm_manager
// only needs to implement the methods in pmm_manager class, then
// XXX_pmm_manager can be used
// by ucore to manage the total physical memory space.
struct pmm_manager
{
    const char *name; // XXX_pmm_manager's name
    void (*init)(
        void); // initialize internal description&management data structure
               // (free block list, number of free block) of XXX_pmm_manager
    void (*init_memmap)(
        struct Page *base,
        size_t n); // setup description&management data structcure according to
                   // the initial free physical memory space
    struct Page *(*alloc_pages)(
        size_t n);                                   // allocate >=n pages, depend on the allocation algorithm
    void (*free_pages)(struct Page *base, size_t n); // free >=n pages with
                                                     // "base" addr of Page
                                                     // descriptor
                                                     // structures(memlayout.h)
    size_t (*nr_free_pages)(void);                   // return the number of free pages
    void (*check)(void);                             // check the correctness of XXX_pmm_manager
};

extern const struct pmm_manager *pmm_manager;
extern pde_t *boot_pgdir;
extern const size_t nbase;
extern uintptr_t boot_cr3;

void pmm_init(void);

struct Page *alloc_pages(size_t n);
void free_pages(struct Page *base, size_t n);
size_t nr_free_pages(void);

#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)

pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create);
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store);
void page_remove(pde_t *pgdir, uintptr_t la);
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm);

void tlb_invalidate(pde_t *pgdir, uintptr_t la);
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm);

/* *
 * PADDR - takes a kernel virtual address (an address that points above
 * KERNBASE),
 * where the machine's maximum 256MB of physical memory is mapped and returns
 * the
 * corresponding physical address.  It panics if you pass it a non-kernel
 * virtual address.
 * */
// 这个宏 PADDR(kva) 的作用是将 内核虚拟地址（KVA） 转换为 物理地址（PA）。
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE)                                    \
        {                                                          \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */
// 这个宏 KADDR(pa) 的作用是将物理地址（pa）转换为 内核虚拟地址。
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage)                                    \
        {                                                        \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })

extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }

static inline uintptr_t page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa)
{
    if (PPN(pa) >= npage)
    {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
}
// page2kva 函数将一个物理页面 Page 转换为对应的内核虚拟地址（KVA）。
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
// kva2page 函数将一个内核虚拟地址（KVA）转换回对应的物理页面 struct Page *。
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }

// 这个函数 pte2page 是用来 从页表条目（Page Table Entry, PTE）获取对应的物理页面（struct Page） 的。
static inline struct Page *pte2page(pte_t pte)
{
    if (!(pte & PTE_V))
    {
        panic("pte2page called with invalid pte");
    }
    // 将 PTE 中的物理地址提取出来并转化为 struct Page 指针
    return pa2page(PTE_ADDR(pte));
}
// 这个函数 pde2page 的作用是从 页目录条目（Page Directory Entry, PDE） 中获取对应的物理页面（struct Page）。
static inline struct Page *pde2page(pde_t pde)
{ // 将 PDE 中的物理地址提取出来并转化为 struct Page 指针
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }

// 增加引用计数
static inline int page_ref_inc(struct Page *page)
{
    page->ref += 1;
    return page->ref;
}
// 减少引用计数
static inline int page_ref_dec(struct Page *page)
{
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
}

static inline pte_t ptd_create(uintptr_t ppn) { return pte_create(ppn, PTE_V); }

extern char bootstack[], bootstacktop[];

extern void *kmalloc(size_t n);
extern void kfree(void *ptr, size_t n);

#endif /* !__KERN_MM_PMM_H__ */
