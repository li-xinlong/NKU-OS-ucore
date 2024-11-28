# lab3实验报告
李欣龙 闫耀方 赵思洋

### 练习0：填写已有实验

> 本实验依赖实验2。请把你做的实验2的代码填入本实验中代码中有“LAB2”的注释相应部分。（建议手动补充，不要直接使用merge）

### 练习1：理解基于FIFO的页面替换算法（思考题）

> 描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）

> - 至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数

#### 辅助结构

- `vma_struct`
  - `vma_struct`(虚拟内存区域)用来描述一段连续的虚拟内存，`vm_start`与`vm_end`描述了这段内存的起止地址位置，`list_link`是关联结构体链表的结构，`vm_flags`是这段内存对应的权限。
  - 在虚拟内存中，多个虚拟内存区域（VMA）可以共享相同的内存，它们就会指向相同的 `mm_struct`。

```C++
struct vma_struct
{
    // 进程的内存管理结构
    struct mm_struct *vm_mm; // the set of vma using the same PDT
    // VMA 起始地址
    uintptr_t vm_start; // start addr of vma
    // VMA 结束地址（不包括该地址）
    uintptr_t vm_end; // end addr of vma, not include the vm_end itself
    // VMA 的标志（如读写权限）
    uint_t vm_flags; // flags of vma
    // 链表链接，用于将 VMA 排序和连接
    list_entry_t list_link; // linear list link which sorted by start addr of vma
};
```

- `mm_struct`
  - `mm_struct`(内存管理)把与自己有映射的`vma_struct`进行保存，并记录当前访问的`vma_struct`以提高访问速度。`pgdir`则指向虚拟地址空间的页目录表，`map_count`则跟踪管理的VMA数量。

```C++
struct mm_struct
{
    // 一个线性链表（通常通过 list_entry_t 类型来实现），用于存储与进程相关的所有 虚拟内存区域（VMA）
    list_entry_t mmap_list; // linear list link which sorted by start addr of vma
    // 存储当前访问的 虚拟内存区域（VMA） 的指针
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
    // 进程的 页目录（Page Directory） 的指针。每个进程都可以有一个独立的页目录，存储该进程的虚拟地址到物理地址的映射。
    pde_t *pgdir; // the PDT of these vma
    // 记录了进程的虚拟内存区域（VMA）的数量。
    int map_count; // the count of these vma
    // 一个指向私有数据的指针，通常用于存储与 交换管理（swap manager） 相关的数据。
    void *sm_priv; // the private data for swap manager
};
```

#### 具体流程

在本实验中，页面的置换采用的是一种消极的换出策略，在调用`alloc_pages` 获取空闲页时，发现无法从物理内存页的分配器中获得页，就调用`swap_out`函数完成页的换出。

1. 在发生页面异常时，会由`pgfault_handler`函数进行处理。该函数打印有关错误信息后，调用`do_pgfault`函数进行进一步处理。
2. `do_pgfault()`首先会调用`swap_in()`，该函数可能会将物理内存中的某个页替换出去（如果物理内存满了），然后将需要的数据（页面）从磁盘写到内存中。
   1. 在`do_pgfault()`函数中，会调用`get_pte()`函数来查找虚拟地址对应的页表项，如果 `*ptep` 为0，说明页表项不存在；如果对应页表不存在，将会创建一个新的页表并返回相应的 PTE 指针。同时需要使用`pgdir_alloc_page()`函数分配物理页面来存储数据。若查到了页表项，说明页面已经在内存中，但是可能是一个交换条目（swap entry）。在这种情况下，需要将使用`swap_in()`函数，将页面从磁盘加载到内存；使用`page_Insert()`函数，建立物理地址与虚拟地址的映射；使用`swap_map_swappable()`函数，标记页面为可交换，将该页作为最近被用到的页面，添加到序列的队尾。

```C++
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr){
    int ret = -E_INVAL;
    struct vma_struct *vma = find_vma(mm, addr);
    pgfault_num++;
    if (vma == NULL || vma->vm_start > addr){
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE){
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
    ret = -E_NO_MEM;
    pte_t *ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 1);
    if (*ptep == 0){
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
    else{
        if (swap_init_ok){
            struct Page *page = NULL;
            swap_in(mm, addr, &page);
            page_insert(mm->pgdir, page, addr, perm);
            swap_map_swappable(mm, addr, page, 1);
            page->pra_vaddr = addr;
        }
        else{
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
    }

    ret = 0;
failed:
    return ret;
}
```

1. `get_pte()`函数用于在页表中查找指定的虚拟地址 `la` 对应的页表项指针（`pte_t`），如果 `create` 标志为真且页表不存在，它将分配新的页表并初始化，最后返回指向虚拟地址 `la` 的页表项的指针或者`NULL`。
2. `swap_in()`函数负责完成页面换入工作，将页面从磁盘加载到内存。
   1. 首先调用alloc_page()分配物理内存页面，如果有空闲的物理页面，则返回相应的Page*，如果没有，则调用swap_out()函数；
   2. ```C++
      int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result){
           struct Page *result = alloc_page();
           assert(result != NULL);
           pte_t *ptep = get_pte(mm->pgdir, addr, 0);
           int r;
           if ((r = swapfs_read((*ptep), result)) != 0){
                assert(r != 0);
           }
           cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep) >> 8, addr);
           *ptr_result = result;
           return 0;
      }
      ```
3. `alloc_page()`是分配一页，即为`alloc_pages(1)`。
   1. `local_intr_save`与`local_intr_restore`这两个函数用于保存和恢复中断状态，以确保在分配内存时不会被中断打断。具体分配则调用了pmm_manager中的`alloc_pages`函数。
   2. if里的三个条件较为重要，swap_init_ok保证`swap_init`函数初始化结束，表示可以使用swap机制；page不为空说明分配成功，不必进行页面的置换；由于swap机制一次只能换出去一个页，因此若需要分配的页面数大于1直接break。否则，说明需要将页面进行换出，需要调用`swap_out`函数
   3. ```C++
       struct Page *alloc_pages(size_t n) {
           struct Page *page = NULL;
           bool intr_flag;
           while (1) {
               local_intr_save(intr_flag);
               { page = pmm_manager->alloc_pages(n); }
               local_intr_restore(intr_flag);
               if (page != NULL || n > 1 || swap_init_ok == 0) break;
               extern struct mm_struct *check_mm_struct;
               swap_out(check_mm_struct, n, 0);
           }
           return page;
       }
      ```
4. `swap_out()`函数在分配页面时使用，在物理内存不足时实行页面换出操作。
   1. 该函数核心在于调用 **`sm->swap_out_victim`** **函数**，选择要置换的牺牲者页面。并将结果存储在 `page` 变量中；随后获取虚拟地址v对应的页表项的指针 ptep，使用断言检查页面的合法性，并调用`swapfs_write()` 函数，将被选为牺牲的页面内容写入到磁盘交换区。`swapfs_write` 的参数包括磁盘交换区的偏移位置， `(page->pra_vaddr / PGSIZE + 1) << 8` 构造了`swap_entry_t`以计算出磁盘交换区的位置，具体实现交换时调用`swap_offset()`函数处理`swap_entry_t`后，乘以`PAGE_NSECT`得到占用的扇区数，最终利用`ide_write_secs()`函数将页写入磁盘。
   2. 在ucore中将页面替换打包成一个页面替换管理器，即`swap.h`和`swap.c`，我们在实现任意页面替换算法之后只需要修改页面替换管理器中挂载的替换算法部分即可。使用FIFO时，这里挂载的应该是`&swap_manager_fifo`。故`swap_out_victim`函数实际指向`_fifo_swap_out_victim`函数。
   3. ```C++
      int swap_out(struct mm_struct *mm, int n, int in_tick){
           int i;
           for (i = 0; i != n; ++i)     {
                uintptr_t v;   
                struct Page *page;
                int r = sm->swap_out_victim(mm, &page, in_tick);
                if (r != 0)          {
                     cprintf("i %d, swap_out: call swap_out_victim failed\n", i);
                     break;
                }
                v = page->pra_vaddr;
                pte_t *ptep = get_pte(mm->pgdir, v, 0);
                assert((*ptep & PTE_V) != 0);
                if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0){
                     cprintf("SWAP: failed to save\n");
                     sm->map_swappable(mm, v, page, 0);
                     continue;
                }
                else{
                     cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
                     *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
                     free_page(page);
                }
                tlb_invalidate(mm->pgdir, v);
           }
           return i;
      }
      ```
5. `_fifo_swap_out_victim()`中，首先获取内存管理器mm的`sm_priv`字段，该字段记录一个队列的head节点，这个队列按进入内存的先后次序链接着所有可交换的物理内存页，它们都被相应的虚拟内存页映射，然后通过`list_prev(head)`，我们就可以得到最先进入内存的页，调用`list_del()`将其从队列中删除，并利用`le2page()`通过链表指针减去偏移计算所在结构体变量的地址，返回待换出页的结构体指针；
6. `page_insert()`函数用于更新页表项，即虚拟页面和物理页面的映射关系，
7. `swap_map_swappable()`指向`_fifo_map_swappable()`函数。
8. `_fifo_map_swappable()`函数在进程的页面置换管理中，将一个页面标记为可置换的，并将其加入到 FIFO 队列中以跟踪页面的使用顺序。
   1. ```C++
      _fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
      {
          list_entry_t *head = (list_entry_t *)mm->sm_priv;
          list_entry_t *entry = &(page->pra_page_link);
          assert(entry != NULL && head != NULL);
          list_add(head, entry);
          return 0;
      }
      ```

### 练习2：深入理解不同分页模式的工作原理（思考题）

> get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

> - get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。

get_pte()函数的代码如下：

```C++
 pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create){
    pde_t *pdep1 = &pgdir[PDX1(la)];
    if (!(*pdep1 & PTE_V)){
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL){
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V))
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}
```

RISC-V中有四种分页模式：Sv32、Sv39、Sv48，它们分别使用不同级别的页表结构，即二级、三级、四级页表。

get_pte() 函数的主要目的是查找或创建与特定线性地址相关的页表项。由于ucore使用Sv39分页机制，因此它使用了三级页表。在get_pte()函数中，有两段相似的代码，分别对应于在第三级和第二级页表（页表目录）中查找或创建页表项。下面是对这两段代码的详细解释：

 首先，get_pte()函数接受一个名为create的参数，用于标识是否需要分配新的页表项。

 然后，通过使用宏PDX1，它从线性地址la中提取出了第一级VPN2（第一级虚拟页号）。接着，在根页表（页目录）pgdir中查找与这个VPN2相关的页表项，并检查其V标志位是否已设置为有效。如果V标志位已设置，表示该页表项已存在，get_pte()会继续向下查找下一个级别的页表。如果V标志位未设置，说明需要创建一个新的页表项，这时会根据create参数或alloc_page()函数的结果来设置该级别的页表项，包括更新页面的引用计数和建立下一级页表的页号映射关系。

 最后，对下一级页表进行相同的操作，使用宏PDE_ADDR获取页表项对应的物理地址。通过pdep0来找到最底层页表项的内容，并将其返回。

 总的来说，get_pte()函数负责在Sv39分页模式下，查找或创建高两级页目录的页表项，并返回最底层页表项的内容。两段相似的代码分别用于不同级别的VPN操作。这种设计使得代码具有可维护性和可扩展性，以适应不同的页表级别。

> - 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

我认为并不好：如果只是考虑 Sv39 分页机制，没什么问题，但是日后扩展程序，这种写法可适配性并不好。

- 同时拆分功能可以使每个函数负责一个明确定义的任务，并且可以更容易地编写单元测试。
- 从模块化方面考虑，可以单独使用查找或分配功能，不必同时使用它们。
- 拆分功能还可以提供更清晰的代码结构，因为每个函数都有一个特定的用途，减少了复杂的嵌套和条件语句，可以更容易地实现错误处理，因为每个函数可以针对不同的错误情况返回适当的错误代码或异常。

### 练习3：给未被映射的地址映射上物理页（需要编程）

> 补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。
>
> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

> - 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。

1. 访问位。在时钟页面替换算法中，页表项中设置一位访问位来表示此页表项对应的页当前是否被访问过，将内存中的页面都通过指针链接。当该页被访问时，将访问位设置为1；当需要选择待换出的页时，对当前指针指向的页所对应的页表项进行查询，如果访问位为0，则将该页换出，如果访问位为1，则将该访问位置0，继续访问下一个页。
2. 修改位。在改进的时钟页面替换算法中，页表项设置一位访问位和一位修改位。当该页被访问时，将访问位设置成1；当该页被写时，将修改位设置成1。这样淘汰页面的顺序就变成了(0,0)->(0,1)->(1,0)->(1,1)，最多4次扫描即可选择一个淘汰页面。
3. 如果页目录项的每一位都为0，则在get_pte时需要分配页来存储页目录。
4. 如果页表项有效位为0，但存储物理页号的位置不为0，代表存储的是磁盘地址，需要进行swap_in()。

> - 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

首先需要保存触发页访问异常指令的虚拟地址到badaddr寄存器中，然后保存缺页服务例程的上下文，执行新的缺页异常处理函数，分配页，将数据从磁盘换入到内存，再恢复缺页服务例程的上下文，继续执行上一级的缺页服务例程。

> - 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

有关系，数据结构page是最低级的页表，目录项是一级页表，存储的内容是页表项的起始地址（二级页表），而页表项是二级页表，存储的是每个页表的开始地址，这些内容之间的关系是通过线性地址高低位不同功能的寻址体现的。

### 练习4：补充完成Clock页替换算法（需要编程）

> 通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)

> 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

> - 比较Clock页替换算法和FIFO算法的不同。

Clock页替换算法和FIFO页替换算法在实现方式和性能上有显著的不同，以下是两者的比较：

1. **实现方式**：
   1. **Clock算法**：使用一个环形链表（称为时钟队列）来管理页面。每个页面有一个访问位（也称为使用位或引用位）。当需要置换页面时，算法扫描时钟队列，查找访问位为0的页面。如果找到，则置换该页面；如果没有找到，则将访问位重置为0，并继续扫描，直到找到一个访问位为0的页面。
   2. **FIFO算法**：使用一个队列来管理页面。当需要置换页面时，选择队列中最旧的页面进行置换。
2. **性能**：
   1. **Clock算法**：通常比FIFO算法更高效，因为它考虑了页面的访问情况。如果一个页面被频繁访问，它的访问位会被重置为1，从而避免被置换。这使得Clock算法能够更好地适应程序的局部性原理，减少页面置换的次数。
   2. **FIFO算法**：简单直观，但可能会置换出仍在使用的页面，因为它只考虑页面进入内存的时间，而不考虑页面的访问频率。这可能导致性能下降，特别是在程序具有局部性特征时。
3. **复杂性**：
   1. **Clock算法**：比FIFO算法稍微复杂一些，因为它需要维护访问位和扫描环形队列。
   2. **FIFO算法**：相对简单，只需要维护一个队列。
4. **适用性**：
   1. **Clock算法**：适用于大多数场景，特别是当程序的局部性特征明显时。
   2. **FIFO算法**：适用于对性能要求不高的简单场景，或者在无法获取页面访问信息时作为一种简单的替代方案。

总的来说，Clock算法通常比FIFO算法更优，因为它能够更好地利用页面的访问信息，减少不必要的页面置换，从而提高系统性能。在实际应用中，选择哪种算法取决于具体的需求和系统环境。

#### **1. 算法原理**

##### **FIFO（First-In-First-Out）**

- **原理**：按照页面进入内存的时间顺序进行替换，最早进入内存的页面会被优先替换。
- **实现**：通常使用一个队列来记录页面的访问顺序，队列头部的页面就是被替换的候选页面。
- **问题**：FIFO算法可能会出现 **Belady现象**（增加页框数反而导致更多的缺页中断），因为它不考虑页面的实际使用频率。

##### **Clock（时钟算法，改进版的FIFO）**

- **原理**：在FIFO基础上加入一个访问位（Access Bit）来记录页面是否被访问过。
  - **访问位为0**：页面没有被访问，优先替换。
  - **访问位为1**：页面被访问过，重置访问位为0，并跳过它，继续检查下一个页面。
- **实现**：模拟一个环形队列（时钟形状），用一个指针指向下一个待替换页面。指针不断前进，直到找到访问位为0的页面。
- **改进点**：Clock算法避免了盲目替换最近使用过的页面，优先保留活跃的页面。

#### **2. 算法比较**

| **特性**       | **FIFO**                               | **Clock**                               |
| -------------- | -------------------------------------- | --------------------------------------- |
| **基本原理**   | 替换最早进入内存的页面                 | 替换访问位为0的页面，跳过最近访问的页面 |
| **实现结构**   | 线性队列                               | 环形队列（类似时钟）                    |
| **访问记录**   | 无记录，只关注页面进入的时间           | 使用访问位记录页面是否被访问过          |
| **性能**       | 可能频繁替换最近被使用的页面（不高效） | 更倾向于保留活跃页面，替换不常用页面    |
| **Belady现象** | 容易发生                               | 很少发生                                |
| **优先级判断** | 仅依据页面进入的时间                   | 结合页面进入时间和访问状态              |
| **复杂度**     | 简单实现，维护一个队列即可             | 略复杂，需要额外的访问位和环形指针      |

#### **3. 优缺点总结**

##### **FIFO算法**

- **优点**：
  - 实现简单，使用队列即可。
  - 不需要额外的访问记录。
- **缺点**：
  - 不考虑页面的访问状态，可能替换最近频繁使用的页面。
  - 容易出现Belady现象，性能不稳定。

##### **Clock算法**

- **优点**：
  - 更倾向于保留活跃的页面，性能更优。
  - 更少出现Belady现象，性能稳定。
- **缺点**：
  - 实现复杂度稍高，需要额外的访问位和时钟指针。
  - 需要硬件支持或操作系统软件模拟访问位。

#### **4. 适用场景**

- **FIFO**：适用于对实现简单有要求的系统（如嵌入式设备），或者对内存管理效率要求不高的场景。
- **Clock**：适用于多任务操作系统，尤其是需要高效内存管理的场景，常见于现代操作系统。

#### **6. 总结**

Clock算法是FIFO的改进版本，通过结合页面访问位，有效提升了页面替换的性能和效率，同时减少了Belady现象的发生，是一种更智能的页面替换策略。

### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

> 如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

#### **大页表的好处**

1. **结构简单，效率高**：
   1. 大页表只有一级，每个虚拟地址直接对应一个页表项。无需逐级遍历，地址转换过程非常简单。
   2. 对于硬件实现来说，只需一个页表基址寄存器，无需管理多级页表的复杂结构。
2. **地址转换速度快**：
   1. 地址转换只需一次页表查找，相比多级页表需要逐级遍历，大页表显著减少了内存访问次数，延迟更低。
3. **编程简单**：
   1. 系统设计中无需复杂的页表管理逻辑，比如动态分配和释放中间级别的页表。
   2. 虚拟地址与物理地址的映射管理更直观，便于调试。
4. **适合小地址空间**：
   1. 在小型系统（如嵌入式系统）中，虚拟地址空间较小，页表大小有限。一个大页表足以覆盖整个地址空间，内存浪费可以忽略不计。
5. **连续内存映射支持更高效**：
   1. 如果需要对一段连续的大物理内存进行映射，大页表可以通过直接设置对应的页表项完成操作，无需多级页表逐层建立映射。
6. **减少多级页表的层级开销**：
   1. 分级页表每级都可能引入额外的内存管理开销，而大页表直接省略了这些中间过程。

#### **大页表的坏处**

1. **内存浪费严重**：
   1. 大页表必须为整个虚拟地址空间建立页表项，即使很多地址不被实际使用。这对于稀疏地址空间应用会导致大量无效页表项，显著浪费内存。
   2. 例如，64位系统中，虚拟地址空间为 \(2^{64}\) 个字节，即使每个页表项只有 8 字节，页表本身也会占用天文数字级别的内存。
2. **扩展性差**：
   1. 当地址空间增大时，大页表的大小增长迅速。例如，在64位架构下，支持完整地址空间的大页表是完全不可行的。
   2. 即使对于32位系统，虚拟地址空间 \(2^{32}\) 的页表也可能过于庞大。
3. **稀疏地址空间支持不足**：
   1. 对于现代程序，虚拟地址空间往往是稀疏分布的。大页表必须为每个可能的地址建立页表项，而分级页表可以按需分配和创建对应的页表部分。
4. **权限设置不灵活**：
   1. 大页表不支持针对不同地址段灵活设置权限（如只读、只执行等）。分级页表可以对不同段进行细粒度的权限管理。
5. **TLB（Translation Lookaside Buffer）压力更大**：
   1. 单级大页表的页表项数量庞大，TLB命中率可能会更低。TLB失效时需要更频繁地访问内存，降低性能。

1. **难以支持分散物理内存映射**：
   1. 如果物理内存不连续，大页表需要逐一映射，增加管理复杂度。而多级页表可以更高效地管理这些分散的内存块。

1. **不适合大规模系统**：
   1. 大页表无法支持大规模系统所需的灵活性和效率。在多用户、多任务的操作系统中，大页表的内存占用和管理开销会显著增加。

#### **总结**

- **好处**：大页表适合简单场景和小型地址空间，具有高效的地址转换性能和简单实现。
- **坏处**：大页表无法应对现代大规模、稀疏地址空间的需求，内存浪费严重，扩展性差，在复杂系统中不可行。

### 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）

> challenge部分不是必做部分，不过在正确最后会酌情加分。需写出有详细的设计、分析和测试的实验报告。完成出色的可获得适当加分。

#### **实验背景**

虚拟内存管理是操作系统的核心功能之一，通过将虚拟地址映射到物理地址，为程序提供透明且连续的内存视图。在多任务系统中，由于物理内存有限，操作系统需要页面替换算法来管理虚拟页面。

**LRU 页面替换算法**是一种常见策略，其核心思想是选择最久未使用的页面进行替换，尽可能降低页面缺失的概率：

- **优点**：准确反映页面的实际访问情况，命中率高。
- **缺点**：在实现上需要记录页面访问的顺序，通常带来较高的时间或空间开销。

为此，我们基于 uCore 操作系统框架，完成了以下任务：

1. **实现 LRU 算法**：通过双向链表维护页面的访问顺序，动态调整链表。
2. **处理缺页异常**：模拟访问不存在的虚拟页面，触发缺页异常，验证页面替换逻辑。
3. **对比实验**：与 FIFO 和 Clock 算法进行对比，分析其性能和行为差异。

#### **实验设计**

##### **1. 核心数据结构**

本实验中，采用了 uCore 提供的 `list_entry_t` 双向链表结构，管理虚拟页面的替换顺序：

- **链表定义**：
  - `pra_list_head`：链表头，指向当前所有页面的管理链表。
  - `curr_ptr`：当前链表指针，用于替换时遍历页面。

- **页面节点**：

每个页面通过 `Page` 结构体的 `pra_page_link` 成员链接到链表。

- **数据结构示例**：

```
pra_list_head -> Page 1 -> Page 2 -> Page 3 -> Page 4 -> ...
```

##### **2. 函数实现**

**(1) 初始化 LRU 管理器**

在内存管理器初始化时，创建一个空的页面链表，指针 `curr_ptr` 指向链表头：

```Java
static int _lru_init_mm(struct mm_struct *mm) {
    list_init(&pra_list_head);
    curr_ptr = &pra_list_head; // 初始化为链表头
    mm->sm_priv = &pra_list_head; // 链表头挂载到 mm
    return 0;
}
```

**(2) 页面访问记录**

当页面被访问或加载到内存时，按照 LRU 的逻辑将其移至链表尾部。若页面已存在于链表中，需先删除原位置，避免重复：

```Java
static int _lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
    list_entry_t *entry = &(page->pra_page_link);

    assert(entry != NULL);
    if (entry->prev != NULL) { // 页面已存在链表中
        list_del(entry);       // 从原位置删除
    }

    list_add_before((list_entry_t *)mm->sm_priv, entry); // 插入到链表尾部

    cprintf("map_swappable: Added page at addr 0x%lx to the swap queue\n", addr);
    return 0;
}
```

**(3) 页面替换**

```Java
static int _lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) {
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    assert(head != NULL);

    curr_ptr = list_next(curr_ptr); // 移动到下一个页面
    if (curr_ptr == head) {         // 回到链表头
        curr_ptr = list_next(curr_ptr); // 再次向下移动
        if (curr_ptr == head) {         // 链表为空，无页面可替换
            *ptr_page = NULL;
            return 0;
        }
    }

    struct Page *page = le2page(curr_ptr, pra_page_link);
    *ptr_page = page;
    list_del(curr_ptr); // 从链表中删除被替换的页面

    cprintf("swap_out: store page at vaddr 0x%lx to disk swap entry\n", (uintptr_t)page->pra_vaddr);
    return 0;
}
```

当内存不足时，从链表头部选择页面（即最久未使用的页面）进行替换：

**(4) 检查页面替换逻辑**

定义测试函数 `_lru_check_swap`，模拟页面访问和替换，验证实现的正确性。此函数按顺序访问虚拟页面，记录缺页次数，并验证页面替换后的数据一致性。

```Java
static int
_lru_check_swap(void)
{
    cprintf("write Virt Page c in lru_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 4);
    cprintf("write Virt Page a in lru_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 4);
    cprintf("write Virt Page d in lru_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 4);
    cprintf("write Virt Page b in lru_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 4);
    cprintf("write Virt Page e in lru_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 5);
    cprintf("write Virt Page b in lru_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 5);
    cprintf("write Virt Page a in lru_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 6);
    cprintf("write Virt Page b in lru_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 7);
    cprintf("write Virt Page c in lru_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 8);
    cprintf("write Virt Page d in lru_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 9);
    cprintf("write Virt Page e in lru_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 10);
    cprintf("write Virt Page a in lru_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 11);
    return 0;
}
```

#### **测试部分**

**测试目标**

1. 验证页面替换逻辑：是否按 LRU 策略正确选择页面替换。
2. 检查缺页次数：是否符合预期。
3. 验证数据一致性：页面替换后能否正确加载和恢复数据。

**测试方法**

利用 `_lru_check_swap` 函数模拟页面访问序列，按如下步骤进行测试：

1. 按顺序访问页面地址 `0x3000, 0x1000, 0x4000, 0x2000, 0x5000`。
2. 检查页面是否正确加入链表尾部。
3. 当内存不足时，验证是否按 LRU 逻辑替换链表头部页面。
4. 验证页面替换后，数据能否正确恢复。

**测试步骤与结果**

| 步骤 | 访问虚拟地址 | 预期缺页次数 | 验证点                           | 测试结果 |
| ---- | ------------ | ------------ | -------------------------------- | -------- |
| 1    | `0x3000`     | 4            | 加载页面到内存，触发缺页         | 通过     |
| 2    | `0x1000`     | 4            | 加载页面到内存，链表尾部插入     | 通过     |
| 3    | `0x4000`     | 4            | 加载页面到内存                   | 通过     |
| 4    | `0x2000`     | 4            | 加载页面到内存                   | 通过     |
| 5    | `0x5000`     | 5            | 替换最久未使用页面，缺页         | 通过     |
| 6    | `0x1000`     | 6            | 替换最久未使用页面，验证链表顺序 | 通过     |
| 7    | `0x3000`     | 8            | 验证页面数据恢复                 | 通过     |

![img](./res/1.png)

#### **实验结果**

- 实现的 LRU 页面替换算法正确，符合预期。
- 页面访问顺序与链表维护的逻辑一致。
- 页面替换后，数据保持一致性。

#### **实验总结**

- 深入理解了 LRU 页面替换算法的实现原理。
- 掌握了虚拟内存管理中的页面替换和缺页处理机制。
- 理解了链表在操作系统中的重要作用
