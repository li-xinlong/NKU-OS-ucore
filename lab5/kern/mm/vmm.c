#include <vmm.h>
#include <sync.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <error.h>
#include <pmm.h>
#include <riscv.h>
#include <swap.h>
#include <kmalloc.h>

/*
  vmm design include two parts: mm_struct (mm) & vma_struct (vma)
  mm is the memory manager for the set of continuous virtual memory
  area which have the same PDT. vma is a continuous virtual memory area.
  There a linear link list for vma & a redblack link list for vma in mm.
---------------
  mm related functions:
   golbal functions
     struct mm_struct * mm_create(void)
     void mm_destroy(struct mm_struct *mm)
     int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr)
--------------
  vma related functions:
   global functions
     struct vma_struct * vma_create (uintptr_t vm_start, uintptr_t vm_end,...)
     void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
     struct vma_struct * find_vma(struct mm_struct *mm, uintptr_t addr)
   local functions
     inline void check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
---------------
   check correctness functions
     void check_vmm(void);
     void check_vma_struct(void);
     void check_pgfault(void);
*/

static void check_vmm(void);
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void)
{
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));

    if (mm != NULL)
    {
        list_init(&(mm->mmap_list));
        mm->mmap_cache = NULL;
        mm->pgdir = NULL;
        mm->map_count = 0;

        if (swap_init_ok)
            swap_init_mm(mm);
        else
            mm->sm_priv = NULL;

        set_mm_count(mm, 0);
        lock_init(&(mm->mm_lock));
    }
    return mm;
}

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags)
{
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));

    if (vma != NULL)
    {
        vma->vm_start = vm_start;
        vma->vm_end = vm_end;
        vma->vm_flags = vm_flags;
    }
    return vma;
}

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr)
{
    struct vma_struct *vma = NULL;
    if (mm != NULL)
    {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
        {
            bool found = 0;
            list_entry_t *list = &(mm->mmap_list), *le = list;
            while ((le = list_next(le)) != list)
            {
                vma = le2vma(le, list_link);
                if (vma->vm_start <= addr && addr < vma->vm_end)
                {
                    found = 1;
                    break;
                }
            }
            if (!found)
            {
                vma = NULL;
            }
        }
        if (vma != NULL)
        {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
        {
            break;
        }
        le_prev = le;
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
    }
    if (le_next != list)
    {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
}

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
    }
    kfree(mm); // kfree mm
    mm = NULL;
}
// mm_map 的函数，用于在给定的进程内存管理结构 mm 中映射一段虚拟内存区域（VMA）。它根据传入的虚拟地址、长度和权限标志来创建并插入新的 VMA。
/*
mm: 目标进程的内存管理结构（mm_struct），表示该进程的虚拟内存管理信息。
addr: 起始地址，表示映射区域的虚拟地址。
len: 映射区域的大小（字节数）。
vm_flags: 虚拟内存区域的权限标志（如读、写、执行等）。
vma_store: 一个指向 vma_struct 指针的指针。如果不为空，映射创建成功后，存储新创建的 VMA。

0: 映射成功。
-E_INVAL: 地址范围无效（地址不在用户可访问范围内）。
-E_NO_MEM: 内存分配失败。
*/
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    // 地址范围对齐：
    // 将 addr 向下对齐到页面边界（页大小对齐）。
    // 将 addr + len 向上对齐到页面边界。
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
    // 使用 USER_ACCESS 宏检查给定的虚拟地址范围是否在用户可访问的内存范围内。
    if (!USER_ACCESS(start, end))
    {
        return -E_INVAL;
    }
    // 确保 mm 不是空指针。
    assert(mm != NULL);

    int ret = -E_INVAL;
    // 查找给定地址范围内是否已经存在 VMA。
    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
    {
        goto out;
    }
    // 不存在则创建一个新的 VMA。
    ret = -E_NO_MEM;

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    // 将新创建的 VMA 插入到mm的 VMA 链表中。
    insert_vma_struct(mm, vma);
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;

out:
    return ret;
}

// dup_mmap 的函数，它用于将一个进程的内存映射（虚拟内存区域，VMA）复制到另一个进程。它通常用于实现进程间的内存共享或在进程复制时进行内存映射的复制。
/*
to: 目标进程的内存管理结构（mm_struct），将接收复制的内存映射。
from: 源进程的内存管理结构（mm_struct），提供要复制的内存映射。
*/
int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
    // 确保 to 和 from 参数都不为空。
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list)
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
        // share 设置为 0，表示不共享内存，只是单纯的复制。
        // bool share = 0;
        // cow机制下，设置为共享
        //
        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}

// 主要用于处理进程退出时清理该进程的所有虚拟内存区域
void exit_mmap(struct mm_struct *mm)
{
    assert(mm != NULL && mm_count(mm) == 0);
    // 获取进程的页目录（pgdir）。pgdir 指向该进程的页目录表，用于处理虚拟地址到物理地址的映射。
    pde_t *pgdir = mm->pgdir;
    // 初始化 list 为进程虚拟内存区域链表的头指针，并将 le 设置为该链表的当前元素指针。mmap_list 存储了进程所有的虚拟内存区域（VMA）。
    list_entry_t *list = &(mm->mmap_list), *le = list;
    // 遍历 mmap_list 链表中的所有元素。
    while ((le = list_next(le)) != list)
    {
        // 使用 le2vma 宏将链表元素指针 le 转换为对应的虚拟内存区域（VMA）结构体指针。
        struct vma_struct *vma = le2vma(le, list_link);
        // 调用 unmap_range 函数解除该虚拟内存区域（VMA）的映射
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *vma = le2vma(le, list_link);
        // 调用 exit_range 函数清理和释放该虚拟内存区域（VMA）所占用的资源（如释放页表项、解除映射等）。
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}
// copy_from_user 函数用于从用户空间复制数据到内核空间
/*
mm: 当前进程的内存管理结构，包含了该进程的页表和虚拟内存区域信息。
dst: 内核空间的目标地址，数据将从 src 复制到这个位置。
src: 用户空间的源地址，数据将从这里复制到内核空间。
len: 需要复制的数据长度。
writable: 如果 src 指向的数据是可写的，则 writable 为 true，否则为 false。
*/
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable)
{
    if (!user_mem_check(mm, (uintptr_t)src, len, writable))
    {
        return 0;
    }
    memcpy(dst, src, len);
    return 1;
}
// copy_to_user 函数用于将数据从内核空间复制到用户空间
/*
mm: 当前进程的内存管理结构，包含了该进程的页表和虚拟内存区域信息。
dst: 用户空间的目标地址，数据将从内核空间的 src 复制到这个位置。
src: 内核空间的源地址，数据将从这里复制到用户空间。
len: 需要复制的数据长度。
*/
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len)
{
    /*
    函数调用 user_mem_check 来检查用户空间内存的有效性，
    确认 dst 地址及其指定的长度 len 是否是合法的，
    并且是否具有写权限（由于 copy_to_user 是向用户空间写数据，
    因此固定传入 writable = 1）。
    */
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1))
    {
        return 0;
    }
    memcpy(dst, src, len);
    return 1;
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
    check_vmm();
}

// check_vmm - check correctness of vmm
static void
check_vmm(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    check_vma_struct();
    check_pgfault();

    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void)
{
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i++)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
    {
        assert(le != &(mm->mmap_list));
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
        assert(vma1 != NULL);
        struct vma_struct *vma2 = find_vma(mm, i + 1);
        assert(vma2 != NULL);
        struct vma_struct *vma3 = find_vma(mm, i + 2);
        assert(vma3 == NULL);
        struct vma_struct *vma4 = find_vma(mm, i + 3);
        assert(vma4 == NULL);
        struct vma_struct *vma5 = find_vma(mm, i + 4);
        assert(vma5 == NULL);

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
    }

    for (i = 4; i >= 0; i--)
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
        if (vma_below_5 != NULL)
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
}

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
    size_t nr_free_pages_store = nr_free_pages();

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
    assert(pgdir[0] == 0);

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;

    for (i = 0; i < 100; i++)
    {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i++)
    {
        sum -= *(char *)(addr + i);
    }

    assert(sum == 0);

    pde_t *pd1 = pgdir, *pd0 = page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    pgdir[0] = 0;
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
    check_mm_struct = NULL;

    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_pgfault() succeeded!\n");
}
// page fault number
volatile unsigned int pgfault_num = 0;

/* do_pgfault - interrupt handler to process the page fault execption
 * @mm         : the control struct for a set of vma using the same PDT
 * @error_code : the error code recorded in trapframe->tf_err which is setted by x86 hardware
 * @addr       : the addr which causes a memory access exception, (the contents of the CR2 register)
 *
 * CALL GRAPH: trap--> trap_dispatch-->pgfault_handler-->do_pgfault
 * The processor provides ucore's do_pgfault function with two items of information to aid in diagnosing
 * the exception and recovering from it.
 *   (1) The contents of the CR2 register. The processor loads the CR2 register with the
 *       32-bit linear address that generated the exception. The do_pgfault fun can
 *       use this address to locate the corresponding page directory and page-table
 *       entries.
 *   (2) An error code on the kernel stack. The error code for a page fault has a format different from
 *       that for other exceptions. The error code tells the exception handler three things:
 *         -- The P flag   (bit 0) indicates whether the exception was due to a not-present page (0)
 *            or to either an access rights violation or the use of a reserved bit (1).
 *         -- The W/R flag (bit 1) indicates whether the memory access that caused the exception
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
    int ret = -E_INVAL;
    // try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    // If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
    {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE)
    {
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;

    pte_t *ptep = NULL;

    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    // 查找当前虚拟地址所对应的页表项
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL)
    {
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    // 如果这个页表项所对应的物理页不存在，则
    if (*ptep == 0)
    {
        // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        // 分配一块物理页，并设置页表项
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
    else
    {
        /*LAB3 EXERCISE 3: YOUR CODE
         * 请你根据以下信息提示，补充函数
         * 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
         * 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
         *
         *  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
         *  宏或函数:
         *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
         *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
         *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
         *    swap_map_swappable ： 设置页面可交换
         */
        // 引入写时复制
        struct Page *page = NULL;
        // 如果当前页错误的原因是写入了只读页面
        if (*ptep & PTE_V)
        {
            // 写时复制：复制一块内存给当前进程
            cprintf("COW: ptep 0x%x, pte 0x%x\n", ptep, *ptep);
            // 原先所使用的只读物理页
            page = pte2page(*ptep);
            // 如果该物理页面被多个进程引用
            if (page_ref(page) > 1)
            {
                // 释放当前PTE的引用并分配一个新物理页
                struct Page *newPage = pgdir_alloc_page(mm->pgdir, addr, perm);
                void *kva_src = page2kva(page);
                void *kva_dst = page2kva(newPage);
                // 拷贝数据
                memcpy(kva_dst, kva_src, PGSIZE);
            }
            // 如果该物理页面只被当前进程所引用,即page_ref等1
            else
            {
                // 则可以直接执行page_insert，保留当前物理页并重设其PTE权限。
                page_insert(mm->pgdir, page, addr, perm);
            }
        }
        else
        {
            if (swap_init_ok)
            {
                struct Page *page = NULL;
                // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
                //(1）According to the mm AND addr, try
                // to load the content of right disk page
                // into the memory which page managed.
                //(2) According to the mm,
                // addr AND page, setup the
                // map of phy addr <--->
                // logical addr
                //(3) make the page swappable.

                // 在swap_in()函数执行完之后，page保存换入的物理页面。
                // swap_in()函数里面可能把内存里原有的页面换出去
                int r = swap_in(mm, addr, &page);

                if (r != 0)
                {
                    cprintf("swap_in in do_pgfault failed\n");
                    goto failed;
                }

                r = page_insert(mm->pgdir, page, addr, perm); // 更新页表，插入新的页表项

                if (r != 0)
                {
                    goto failed;
                }

                swap_map_swappable(mm, addr, page, 1);
                // 标记这个页面将来是可以再换出的

                page->pra_vaddr = addr;
            }
            else
            {
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
                goto failed;
            }
        }
    }
    ret = 0;
failed:
    return ret;
}
// user_mem_check 的函数用于检查用户空间的内存访问是否合法。
/*
mm: 当前进程的内存管理结构，包含了该进程的虚拟内存区域（VMA）和页表信息。
addr: 要检查的内存区域的起始地址。
len: 要检查的内存区域的长度。
write: 如果是 true，表示检查写权限；如果是 false，表示检查读权限。
*/
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
    if (mm != NULL)
    {
        // USER_ACCESS(addr, addr + len) 宏用来检查 addr 到 addr + len 的内存是否属于用户空间。
        if (!USER_ACCESS(addr, addr + len))
        {
            return 0;
        }
        // 接下来函数会遍历这个地址范围的每一部分，检查每一段虚拟内存区域（VMA）是否符合访问要求。

        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end)
        {
            //// 使用 find_vma(mm, start) 查找当前进程的虚拟内存区域（VMA），
            // 如果 find_vma 返回 NULL，或者 start 地址不在该虚拟内存区域的范围内，表示该区域不合法，返回 0。
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
            {
                return 0;
            }
            // 检查 vma->vm_flags，确保该区域具有相应的访问权限。
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
            {
                return 0;
            }
            /*
            如果请求的是写权限并且该区域是栈空间（通过 VM_STACK 标志标识），
            并且地址 start 小于栈的起始位置加一个页面的大小（PGSIZE），则认为该地址无效，返回 0。
            这是为了防止栈溢出等问题。
            */
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
