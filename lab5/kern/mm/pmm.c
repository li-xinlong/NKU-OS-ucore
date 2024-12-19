#include <default_pmm.h>
#include <defs.h>
#include <error.h>
#include <kmalloc.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <sync.h>
#include <vmm.h>
#include <riscv.h>

// virtual address of physical page array
struct Page *pages;
// amount of physical memory (in pages)
size_t npage = 0;
// The kernel image is mapped at VA=KERNBASE and PA=info.base
// va_pa_offset 是虚拟地址（Virtual Address）和物理地址（Physical Address）之间的偏移量。
uint_t va_pa_offset;
// memory starts at 0x80000000 in RISC-V
// nbase 是从物理内存基地址（DRAM_BASE）到第一个页框的偏移量
const size_t nbase = DRAM_BASE / PGSIZE;

// virtual address of boot-time page directory
// boot_pgdir 是一个指针，指向操作系统启动时的页目录
pde_t *boot_pgdir = NULL;
// physical address of boot-time page directory
// boot_cr3 表示启动时页目录的物理地址，通常会存储在 CPU 的 CR3 寄存器中。
uintptr_t boot_cr3;

// physical memory management
const struct pmm_manager *pmm_manager;

static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void)
{
    pmm_manager = &default_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory
static void init_memmap(struct Page *base, size_t n)
{
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n)
{
    struct Page *page = NULL;
    bool intr_flag;

    while (1)
    {
        local_intr_save(intr_flag);
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0)
            break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 调用pmm->nr_free_pages函数获取当前空闲内存的大小（nr*PAGESIZE）
// of current free memory
size_t nr_free_pages(void)
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

/* pmm_init - initialize the physical memory management */
static void page_init(void)
{
    extern char kern_entry[];

    va_pa_offset = KERNBASE - 0x80200000;

    uint_t mem_begin = KERNEL_BEGIN_PADDR;
    uint_t mem_size = PHYSICAL_MEMORY_END - KERNEL_BEGIN_PADDR;
    uint_t mem_end = PHYSICAL_MEMORY_END;

    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
            mem_end - 1);

    uint64_t maxpa = mem_end;

    if (maxpa > KERNTOP)
    {
        maxpa = KERNTOP;
    }

    extern char end[];

    npage = maxpa / PGSIZE;
    // BBL has put the initial page table at the first available page after the
    // kernel
    // so stay away from it by adding extra offset to end
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (size_t i = 0; i < npage - nbase; i++)
    {
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));

    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    if (freemem < mem_end)
    {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
    cprintf("vapaofset is %llu\n", va_pa_offset);
}

// boot_map_segment - 设置并启用分页机制
// 参数：
//  la：需要映射的线性地址（在x86段映射之后）
//  size：内存大小
//  pa：物理地址
//  perm：内存的权限
/*
实现了分页机制的一个核心功能：将虚拟地址（Linear Address, LA）映射到物理地址（Physical Address, PA），
并为每个映射设置权限（perm）*/
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size,
                             uintptr_t pa, uint32_t perm)
{
    // 检查虚拟地址和物理地址的页内偏移量是否一致。
    assert(PGOFF(la) == PGOFF(pa));
    // 计算需要映射的页数
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    // 将虚拟地址和物理地址都向下对齐到页边界
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    // 循环映射每一页
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
    {
        // 获取虚拟地址对应的页表项
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        // 设置页表项的内容，包括物理页号和权限
        *ptep = pte_create(pa >> PGSHIFT, PTE_V | perm);
    }
}

// boot_alloc_page - 使用pmm->alloc_pages(1)分配一页内存
// 返回值：分配的内核虚拟地址
// 用于在启动时分配一页内存，并返回该内存页的内核虚拟地址。
// 注意：此函数用于获取PDT（页目录表）和PT（页表）的内存
static void *boot_alloc_page(void)
{
    struct Page *p = alloc_page();
    if (p == NULL)
    {
        panic("boot_alloc_page failed.\n");
    }
    // 将 struct Page 类型的物理页面指针 p 转换为对应的内核虚拟地址。
    return page2kva(p);
}

// pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup
// paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void pmm_init(void)
{
    // We need to alloc/free the physical memory (granularity is 4KB or other
    // size).
    // So a framework of physical memory manager (struct pmm_manager)is defined
    // in pmm.h
    // First we should init a physical memory manager(pmm) based on the
    // framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();

    // use pmm->check to verify the correctness of the alloc/free function in a
    // pmm
    check_alloc_page();

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    extern char boot_page_table_sv39[];
    boot_pgdir = (pte_t *)boot_page_table_sv39;
    boot_cr3 = PADDR(boot_pgdir);

    check_pgdir();

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // now the basic virtual memory map(see memalyout.h) is established.
    // check the correctness of the basic virtual memory map.
    check_boot_pgdir();

    kmalloc_init();
}

// get_pte - 获取pte并返回该pte的内核虚拟地址
//        - 如果PT中不包含该pte，则为PT分配一个页面
// 参数：
//  pgdir：PDT的内核虚拟基地址
//  la：需要映射的线性地址
//  create：一个逻辑值，决定是否为PT分配一个页面
// 返回值：该pte的内核虚拟地址
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    // 获取PDT的一级页表项
    pde_t *pdep1 = &pgdir[PDX1(la)];
    // 如果一级页表项不存在
    if (!(*pdep1 & PTE_V))
    {
        struct Page *page;
        // 如果不需要创建或者无法分配页面，则返回空指针
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        // 创建一级页表项
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }

    // 获取PDT的二级页表项
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    // 如果二级页表项不存在
    if (!(*pdep0 & PTE_V))
    {
        struct Page *page;
        // 如果不需要创建或者无法分配页面，则返回空指针
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        // 创建二级页表项
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    // 返回pte的内核虚拟地址
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

// get_page - get related Page struct for linear address la using PDT pgdir
/*
用于根据给定的线性地址（la）查找并返回对应的 struct Page。
它通过页目录（pgdir）查找相应的页表项（PTE），然后返回与该线性地址关联的页面结构。*/
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
    // 通过给定的页目录 pgdir 和线性地址 la 查找相应的页表项（PTE）。
    pte_t *ptep = get_pte(pgdir, la, 0);
    // 如果 ptep_store 参数不为 NULL，将找到的页表项（ptep）保存到 ptep_store 中
    if (ptep_store != NULL)
    {
        *ptep_store = ptep;
    }
    if (ptep != NULL && *ptep & PTE_V)
    {
        return pte2page(*ptep);
    }
    return NULL;
}

/**
 * 从页表中移除页表项，并释放相关的Page结构和清除（使无效）与线性地址la相关的页表项。
 *
 * @param pgdir 指向页目录表的指针
 * @param la 线性地址
 * @param ptep 指向页表项的指针
 */
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
    if (*ptep & PTE_V)
    { //(1) 检查该页表项是否有效
        struct Page *page =
            pte2page(*ptep); //(2) 找到与页表项对应的Page结构
        page_ref_dec(page);  //(3) 减少Page的引用计数
        if (page_ref(page) ==
            0)
        { //(4) 当Page的引用计数为0时，释放该Page
            free_page(page);
        }
        *ptep = 0;                 //(5) 清除第二级页表项
        tlb_invalidate(pgdir, la); //(6) 刷新TLB
    }
}

// unmap_range - 取消映射指定线性地址范围的页表项
// 参数：
//  pgdir：页目录表的内核虚拟基地址
//  start：起始线性地址
//  end：结束线性地址
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    do
    {
        // 获取线性地址对应的页表项
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            // 如果页表项不存在，则继续下一个页表项
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        if (*ptep != 0)
        {
            // 如果页表项不为0，则移除该页表项
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
}

void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    uintptr_t d1start, d0start;
    int free_pt, free_pd0;
    pde_t *pd0, *pt, pde1, pde0;
    d1start = ROUNDDOWN(start, PDSIZE);
    d0start = ROUNDDOWN(start, PTSIZE);
    do
    {
        // 一级页目录项
        pde1 = pgdir[PDX1(d1start)];
        // 如果存在有效的页目录项，进入二级页表
        // 尝试释放所有由有效的页目录项指向的二级页表
        // 然后尝试释放该二级页表，并更新一级页目录项
        if (pde1 & PTE_V)
        {
            pd0 = page2kva(pde2page(pde1));
            // 尝试释放所有的二级页表
            free_pd0 = 1;
            do
            {
                pde0 = pd0[PDX0(d0start)];
                if (pde0 & PTE_V)
                {
                    pt = page2kva(pde2page(pde0));
                    // 尝试释放页表
                    free_pt = 1;
                    for (int i = 0; i < NPTEENTRY; i++)
                    {
                        if (pt[i] & PTE_V)
                        {
                            free_pt = 0;
                            break;
                        }
                    }
                    // 当所有的页表项都无效时才释放
                    if (free_pt)
                    {
                        free_page(pde2page(pde0));
                        pd0[PDX0(d0start)] = 0;
                    }
                }
                else
                    free_pd0 = 0;
                d0start += PTSIZE;
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
            // 当所有的pde0都无效时才释放二级页表
            if (free_pd0)
            {
                free_page(pde2page(pde1));
                pgdir[PDX1(d1start)] = 0;
            }
        }
        d1start += PDSIZE;
        d0start = d1start;
    } while (d1start != 0 && d1start < end);
}
/* copy_range - 将进程A的内存内容（start，end）复制到进程B
 * @to:    进程B的页目录的地址
 * @from:  进程A的页目录的地址
 * @share: 标志位，表示复制还是共享。我们只使用复制方法，所以它没有被使用。
 *
 * 调用图：copy_mm-->dup_mmap-->copy_range
 */
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,
               bool share)
{
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // 按页单位复制内容。
    do
    {
        // 调用get_pte根据地址start找到进程A的pte
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // 调用get_pte根据地址start找到进程B的pte。如果pte为NULL，就分配一个PT
        if (*ptep & PTE_V)
        {
            if ((nptep = get_pte(to, start, 1)) == NULL)
            {
                return -E_NO_MEM;
            }
            uint32_t perm = (*ptep & PTE_USER);
            // 从ptep中获取页
            struct Page *page = pte2page(*ptep);
            assert(page != NULL);

            int ret = 0;
            /* LAB5:EXERCISE2 2212599 2212294 2212045
             * 复制页的内容到npage，建立phy addr和线性地址start的映射
             *
             * 一些有用的宏和定义，你可以在下面的实现中使用它们。
             * 宏或函数：
             *    page2kva(struct Page *page)：返回page管理的内存的内核虚拟地址（参见pmm.h）
             *    page_insert：建立phy addr和线性地址la的映射
             *    memcpy：典型的内存复制函数
             *
             * (1) 找到src_kvaddr：页的内核虚拟地址
             * (2) 找到dst_kvaddr：npage的内核虚拟地址
             * (3) 从src_kvaddr复制内容到dst_kvaddr，大小为PGSIZE
             * (4) 建立phy addr和npage的线性地址start的映射
             */

            if (share)
            {
                cprintf("Sharing the page 0x%x\n", page2kva(page));
                // 将一个物理页映射到两个不同的虚拟地址中，从而实现共享。
                page_insert(from, page, start, perm & (~PTE_W));
                ret = page_insert(to, page, start, perm & (~PTE_W));
            }
            else
            {
                // 为进程B分配一个页
                struct Page *npage = alloc_page();
                assert(npage != NULL);
                // 1.找寻父进程的内核虚拟页地址
                uintptr_t src_kvaddr = page2kva(page);
                // 2.找寻子进程的内核虚拟页地址
                uintptr_t dst_kvaddr = page2kva(npage);
                // 3.复制父进程内容到子进程
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
                // 4.建立物理地址与子进程的页地址起始位置的映射关系
                ret = page_insert(to, npage, start, perm);
            }

            assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep != NULL)
    {
        page_remove_pte(pgdir, la, ptep);
    }
}

// page_insert - build the map of phy addr of an Page with the linear addr la
// paramemters:
//  pgdir: the kernel virtual base address of PDT
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL)
    {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V)
    {
        struct Page *p = pte2page(*ptep);
        if (p == page)
        {
            page_ref_dec(page);
        }
        else
        {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    tlb_invalidate(pgdir, la);
    return 0;
}

// 使TLB项无效，但仅当当前正在使用的页表是处理器当前正在使用的页表时。
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
}

// pgdir_alloc_page - 调用alloc_page和page_insert函数来
//                  - 分配一个页面大小的内存并设置地址映射
//                  - pa<->la与线性地址la和PDT pgdir相关联
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
{
    struct Page *page = alloc_page();
    if (page != NULL)
    {
        if (page_insert(pgdir, page, la, perm) != 0)
        {
            free_page(page);
            return NULL;
        }
        if (swap_init_ok)
        {
            if (check_mm_struct != NULL)
            {
                swap_map_swappable(check_mm_struct, la, page, 0);
                page->pra_vaddr = la;
                assert(page_ref(page) == 1);
                // cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x,
                // pra_link_next %x in pgdir_alloc_page\n", (page-pages),
                // page->pra_vaddr,page->pra_page_link.prev,
                // page->pra_page_link.next);
            }
            else
            { // 现在current存在，将来应该修复它
              // swap_map_swappable(current->mm, la, page, 0);
              // page->pra_vaddr=la;
              // assert(page_ref(page) == 1);
              // panic("pgdir_alloc_page: no pages. now current is existed,
              // should fix it in the future\n");
            }
        }
    }

    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}

static void check_pgdir(void)
{
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert(page_ref(p1) == 1);

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);

    p2 = alloc_page();
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(*ptep & PTE_U);
    assert(*ptep & PTE_W);
    assert(boot_pgdir[0] & PTE_U);
    assert(page_ref(p2) == 1);

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
    assert(page_ref(p1) == 2);
    assert(page_ref(p2) == 0);
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);

    page_remove(boot_pgdir, 0x0);
    assert(page_ref(p1) == 1);
    assert(page_ref(p2) == 0);

    page_remove(boot_pgdir, PGSIZE);
    assert(page_ref(p1) == 0);
    assert(page_ref(p2) == 0);

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
    flush_tlb();

    assert(nr_free_store == nr_free_pages());

    cprintf("check_pgdir() succeeded!\n");
}

static void check_boot_pgdir(void)
{
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
    {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(boot_pgdir[0] == 0);

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 2);

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);

    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);

    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
    flush_tlb();

    assert(nr_free_store == nr_free_pages());

    cprintf("check_boot_pgdir() succeeded!\n");
}

// perm2str - use string 'u,r,w,-' to present the permission
static const char *perm2str(int perm)
{
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
    str[1] = 'r';
    str[2] = (perm & PTE_W) ? 'w' : '-';
    str[3] = '\0';
    return str;
}

// get_pgtable_items - 在PDT或PT的[left, right]范围内，找到一个连续的线性地址空间
//                  - (left_store*X_SIZE~right_store*X_SIZE) 用于PDT或PT
//                  - X_SIZE=PTSIZE=4M，如果是PDT；X_SIZE=PGSIZE=4K，如果是PT
// 参数：
//  left：无用？？？
//  right：表的高端范围
//  start：表的低端范围
//  table：表的起始地址
//  left_store：表的下一个范围的高端指针
//  right_store：表的下一个范围的低端指针
// 返回值：0 - 不是无效的项范围，perm - 具有perm权限的有效项范围
static int get_pgtable_items(size_t left, size_t right, size_t start,
                             uintptr_t *table, size_t *left_store,
                             size_t *right_store)
{
    if (start >= right)
    {
        return 0;
    }
    while (start < right && !(table[start] & PTE_V))
    {
        start++;
    }
    if (start < right)
    {
        if (left_store != NULL)
        {
            *left_store = start;
        }
        int perm = (table[start++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm)
        {
            start++;
        }
        if (right_store != NULL)
        {
            *right_store = start;
        }
        return perm;
    }
    return 0;
}
