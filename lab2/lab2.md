# Lab 2

## 一、实验要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 二、知识点整理：

### （一）实验中重要的知识点与对应的OS原理
### 1. 物理内存管理
在代码中，物理内存管理的实现通常通过结构体和函数来管理内存页的分配与释放。例如，`struct Page` 代表内存页，每个页面的属性（如是否可用、是否被使用等）由相应的位标志来管理。
#### 代码示例分析
```c
struct Page {
    int property; // 页的属性标志
    struct list_head page_link; // 链接到空闲列表
};
```
这个结构体中的 `property` 用于标识页的状态，确保不同进程对内存的访问互不干扰。

### 2. 虚拟地址与物理地址
在代码中，虚拟地址与物理地址的转换涉及页表的操作。通过查找页表，代码能够将虚拟地址转换为物理地址，并进行访问。

#### 代码示例分析
```c
struct Page *page = le2page(le, page_link); // 从链表节点获取页面
```
这段代码通过链表操作获取一个空闲页面，展示了如何通过结构体和链表管理物理内存。

### 4. 多级页表
代码可能通过多个结构体和指针实现多级页表的概念。在多级页表中，每一层的页表项负责管理更大的地址空间。

#### 代码示例分析
```c
list_add(&free_area[order].free_list, &(buddy->page_link));
```
这行代码表示将一个空闲块加入到特定级别的空闲链表中，反映了多级页表的动态管理。

### 5. 页表项 (PTE) 结构
页表项结构通常在代码中以数组或结构体的形式存在，标记页的权限和状态。

#### 代码示例分析
```c
page->property = n; // 设置页的属性
```
这里，属性包括可读、可写等，直接影响页面的访问权限。

### 6. 页表基址寄存器 (satp)
尽管代码中未直接涉及 `satp`，但可以在页表的初始化和切换中找到相关逻辑。

#### 代码示例分析
```c
ClearPageProperty(page);
```
在进行页表操作前，代码可能需要清除标志，确保系统状态一致性。

### （二）列出你认为OS原理中很重要，但在实验中没有对应上的知识点
建立快表以加快访问效率
#### 练习0：填写已有实验

本实验依赖实验1。请把你做的实验1的代码填入本实验中代码中有“LAB1”的注释相应部分并按照实验手册进行进一步的修改。具体来说，就是跟着实验手册的教程一步步做，然后完成教程后继续完成完成exercise部分的剩余练习。

#### 练习1：理解first-fit 连续物理内存分配算法（思考题）
first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合`kern/mm/default_pmm.c`中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：
- 你的first fit算法是否有进一步的改进空间？
1. 短期优化：可以立即通过按块大小排序的方式优化当前双向链表结构，这能显著提高查找效率，避免地址线性遍历的开销。
2. 长期优化：引入更复杂的数据结构如红黑树、跳表或分离空闲链表结构可以进一步提升内存分配和释放的效率。这些方法可以减少查找和插入空闲块时的时间复杂度，使得内存管理系统更高效、灵活。
#### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）
在完成练习一后，参考kern/mm/default_pmm.c对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。
请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：
- 你的 Best-Fit 算法是否有进一步的改进空间？
1. 使用二级或多级分配策略
为了提高内存分配的效率，可以采用二级或多级分配策略。在此策略中，首先根据请求的内存大小选择一个合适的块，如果没有合适的块，则分配一个更大的块并将其拆分为多个小块，以适应不同的请求。这种方法可以减少小块的合并和碎片化问题。
2. 合并空闲块的策略优化
在释放内存时，当前的实现可能需要遍历整个空闲链表来找到可以合并的块。可以考虑在分配时维护一个合并列表，只记录相邻的空闲块，减少查找时间。
#### 扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）

Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...

 -  参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。
 -  # Buddy System分配算法

## 一、概述
Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理，每个存储块的大小必须是2的n次幂(Pow(2, n))，即1, 2, 4, 8, 16, 32, 64, 128...

在实现伙伴系统分配算法之前，首先回顾一下伙伴系统的基本概念。伙伴系统分配算法通过将内存按2的幂进行划分，以便于高效管理内存的分配与释放。该算法利用空闲链表来维护不同大小的空闲内存块，能够快速查找合适大小的块，且在合并时能够减少外部碎片。尽管其优点明显，但也存在内部碎片的问题，尤其在请求大小不是2的幂次方时。

## 二、设计思路

### （一）内存分区管理
整个可分配的分区大小为N，请求的分区大小为n，当n < N时，将N分配给进程。
按2的幂划分空闲块，直至找到合适大小的空闲块。

### （二）合并条件
1. 相同大小且为2的整数次幂。
2. 地址相邻。
3. 低地址空闲块的起始地址为块大小的整数次幂的位数。

### （三）空闲页初始化部分：按照伙伴系统的规则划分成合适大小的块，并将这些块添加到对应的空闲块链表中进行管理。按照order从大到小顺序在物理内存base处，通过找到合适的块大小对应的幂次（order）来完成这一操作。
```c
static void buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n > 0);
    int order = MAX_ORDER;
    while ((1 << order) > n)
    {
        order--;
    }
    list_add(&free_area[order].free_list, &(base->page_link));
    base->property = (1 << order);
    SetPageProperty(base);
    free_area[order].nr_free++;
}
```

### （四）页分配：order从从当前页大小到大查找，通过地址偏移量二进制位运算，计算拆分得到伙伴地址page + (1 << current_order)，
```c
static struct Page *buddy_alloc_pages(size_t n)
{
    int order = 0;
    while ((1 << order) < n)
    {
        order++;
    }
    if (order > MAX_ORDER)
        return NULL; // 请求的块超出最大支持块的大小

    // 查找适合的块
    for (int current_order = order; current_order <= MAX_ORDER; current_order++)
    {
        if (!list_empty(&free_area[current_order].free_list))
        {
            list_entry_t *le = list_next(&free_area[current_order].free_list);
            struct Page *page = le2page(le, page_link);
            list_del(le); // 从空闲列表中删除
            free_area[current_order].nr_free--;

            // 拆分较大的块，直到我们找到合适的大小
            while (current_order > order)
            {
                current_order--;
                struct Page *buddy = page + (1 << current_order);
                buddy->property = (1 << current_order);
                SetPageProperty(buddy);
                list_add(&free_area[current_order].free_list, &(buddy->page_link));
                free_area[current_order].nr_free++;
            }
            ClearPageProperty(page);
            page->property = n;
            return page;
        }
    }
    return NULL; // 如果没有合适的块，返回NULL
}
```

### （五）页释放：order从当前页大小到大释放，通过uintptr_t buddy_addr = addr ^ (1 << (PGSHIFT + order));中二进制大块地址低位都是0的原理，通过PGSHIFT 将运算从页为单位到字节为单位。
```c
static void buddy_free_pages(struct Page *base, size_t n)
{
    int order = 0;
    while ((1 << order) < n)
    {
        order++;
    }

    // 检查页面是否已经被释放，避免重复释放
    if (PageProperty(base))
    {
        // cprintf("Error: Page at %p has already been freed!\n", base);
        return;
    }

    // 设置当前块为可释放状态
    base->property = (1 << order);
    SetPageProperty(base);

    // 开始处理释放和合并
    while (order <= MAX_ORDER)
    {
        uintptr_t addr = page2pa(base);
        uintptr_t buddy_addr = addr ^ (1 << (PGSHIFT + order));
        struct Page *buddy = pa2page(buddy_addr);

        // 检查伙伴块是否已经被使用或地址越界
        if (buddy_addr >= npage * PGSIZE ||!PageProperty(buddy) || buddy->property!= (1 << order))
        {
            break;
        }

        // 合并
        list_del(&(buddy->page_link));
        ClearPageProperty(buddy);
        base = (base < buddy)? base : buddy; // 合并到较小地址的块
        order++;
    }

    // 释放后的最终块加入空闲列表
    list_add(&free_area[order].free_list, &(base->page_link));
    free_area[order].nr_free++; // 更新空闲块数量
}
```

## 三、测试样例

### （一）测试多次小规模分配与释放
```c
// 测试多次小规模分配与释放
static void buddy_check_1(void)
{
    cprintf("伙伴系统测试1开始\n");
    struct Page *p0, *p1, *p2, *p3;
    p0 = p1 = p2 = p3 = NULL;

    // 分配多个较小的内存块
    assert((p0 = alloc_pages(3))!= NULL);
    assert((p1 = alloc_pages(2))!= NULL);
    assert((p2 = alloc_pages(1))!= NULL);
    assert((p3 = alloc_pages(5))!= NULL);

    // 释放这些内存块
    free_pages(p0, 3);
    free_pages(p1, 2);
    free_pages(p2, 1);
    free_pages(p3, 5);

    // 再次分配相同大小的块以验证内存是否正确释放
    assert((p0 = alloc_pages(3))!= NULL);
    assert((p1 = alloc_pages(2))!= NULL);
    assert((p2 = alloc_pages(1))!= NULL);
    assert((p3 = alloc_pages(5))!= NULL);

    // 最后释放所有内存块
    free_pages(p0, 3);
    free_pages(p1, 2);
    free_pages(p2, 1);
    free_pages(p3, 5);
    cprintf("伙伴系统测试1成功完成\n");
}
```

### （二）测试大规模块分配与释放
```c
// 测试大规模块分配与释放
static void buddy_check_2(void)
{
    cprintf("伙伴系统测试2开始\n");
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    // 分配较大的内存块
    assert((p0 = alloc_pages(128))!= NULL);
    assert((p1 = alloc_pages(64))!= NULL);
    assert((p2 = alloc_pages(256))!= NULL);

    // 释放这些内存块
    free_pages(p0, 128);
    free_pages(p1, 64);
    free_pages(p2, 256);

    // 再次分配相同大小的块以验证内存是否正确释放
    assert((p0 = alloc_pages(128))!= NULL);
    assert((p1 = alloc_pages(64))!= NULL);
    assert((p2 = alloc_pages(256))!= NULL);

    // 最后释放所有内存块
    free_pages(p0, 128);
    free_pages(p1, 64);
    free_pages(p2, 256);
    cprintf("伙伴系统测试2成功完成\n");
}
```

### （三）测试不同大小块的交替分配与释放
```c
// 测试不同大小块的交替分配与释放
static void buddy_check_3(void)
{
    cprintf("伙伴系统测试3开始\n");
    struct Page *p0, *p1, *p2, *p3;
    p0 = p1 = p2 = p3 = NULL;

    // 交替分配不同大小的内存块
    assert((p0 = alloc_pages(10))!= NULL);
    assert((p1 = alloc_pages(20))!= NULL);
    assert((p2 = alloc_pages(5))!= NULL);
    assert((p3 = alloc_pages(8))!= NULL);

    // 释放部分内存块
    free_pages(p1, 20);
    free_pages(p3, 8);

    // 分配新的块并再次释放
    assert((p1 = alloc_pages(15))!= NULL);
    free_pages(p0, 10);
    free_pages(p1, 15);
    free_pages(p2, 5);
    cprintf("伙伴系统测试3成功完成\n");
}
```

### （四）测试边界条件，超出限制的分配应该失败
```c
// 测试边界条件，超出限制的分配应该失败
static void buddy_check_4(void)
{
    cprintf("伙伴系统测试4开始\n");
    struct Page *p0, *p1;
    p0 = p1 = NULL;

    // 分配较大的块
    assert((p0 = alloc_pages(512))!= NULL);

    // 试图分配超出最大限制的块，应返回 NULL
    assert(alloc_pages(1024) == NULL);

    // 释放内存块
    free_pages(p0, 512);

    // 再次分配较大的块以验证内存是否正确释放
    assert((p1 = alloc_pages(512))!= NULL);

    // 最后释放所有内存块
    free_pages(p1, 512);
    cprintf("伙伴系统测试4成功完成\n");
}
```

### （五）测试多次快速分配和释放
```c
// 测试多次快速分配和释放
static void buddy_check_5(void)
{
    cprintf("伙伴系统测试5开始\n");
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    // 快速分配和释放
    assert((p0 = alloc_pages(10))!= NULL);
    assert((p1 = alloc_pages(20))!= NULL);
    free_pages(p0, 10);
    assert((p2 = alloc_pages(30))!= NULL);
    free_pages(p1, 20);
    free_pages(p2, 30);

    // 再次快速分配和释放
    assert((p0 = alloc_pages(15))!= NULL);
    assert((p1 = alloc_pages(25))!= NULL);
    free_pages(p0, 15);
    assert((p2 = alloc_pages(35))!= NULL);
    free_pages(p1, 25);
    free_pages(p2, 35);
    cprintf("伙伴系统测试5成功结束\n");
}
```

### （六）测试小块合并
```c
static void buddy_check_6(void)
{
    cprintf("伙伴系统测试6开始\n");
    struct Page *p0, *p1, *p2, *p3;
    p0 = p1 = p2 = p3 = NULL;

    // 分配4个较小的块，每个块的大小分别为 1, 2, 4 页
    assert((p0 = alloc_pages(1))!= NULL); // 分配1页
    assert((p1 = alloc_pages(1))!= NULL); // 再分配1页
    assert((p2 = alloc_pages(2))!= NULL); // 分配2页
    assert((p3 = alloc_pages(4))!= NULL); // 分配4页

    // 释放所有的块，并期望它们自动合并为一个更大的块
    free_pages(p0, 1); // 释放1页
    free_pages(p1, 1); // 释放1页
    free_pages(p2, 2); // 释放2页
    free_pages(p3, 4); // 释放4页

    // 检查是否可以成功分配一个8页的块（期望通过合并得到8页的空闲块）
    assert((p0 = alloc_pages(8))!= NULL); // 如果合并成功，应该能够分配8页的块

    // 释放合并后的块
    free_pages(p0, 8); // 释放8页的块
    cprintf("伙伴系统测试6成功结束\n");
}
```
 
#### 扩展练习Challenge：任意大小的内存单元slub分配算法（需要编程）

slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。

 - 参考[linux的slub分配算法/](http://www.ibm.com/developerworks/cn/linux/l-cn-slub/)，在ucore中实现slub分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

#### 扩展练习Challenge：硬件的可用物理内存范围的获取方法（思考题）
  - 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？
# 硬件的可用物理内存范围的获取方法

## 一、问题背景
如果OS无法提前知道当前硬件的可用物理内存范围，需要寻找方法让OS获取此信息。例如可用物理内存范围可能存在理论值如[0x80000000,0x88000000)，实际值如[0x0000000080200000, 0x0000000087ffffff]。

## 二、获取可用物理内存范围的方法
1. **通过BIOS/UEFI固件获取内存映射信息**
   - **原理**：BIOS/UEFI在系统启动初期对硬件进行自检和初始化时，会获取到硬件的内存映射情况。这些信息可以被操作系统获取来了解可用物理内存范围。
   - **优点**：BIOS/UEFI能够全面地探测到硬件的初始内存布局，可靠性较高。
   - **缺点**：BIOS/UEFI提供的信息可能较为复杂，需要操作系统进行解析，且BIOS/UEFI的实现可能因厂商而异。
2. **依靠引导加载程序在启动时传递的内存布局信息**
   - **原理**：引导加载程序（如GRUB等）在加载操作系统内核之前，已经对内存有一定的了解，可以将内存布局相关信息传递给操作系统。
   - **优点**：直接由引导加载程序传递，对操作系统来说获取方式相对简单。
   - **缺点**：依赖于引导加载程序的实现，不同的引导加载程序可能提供信息的方式和准确性不同。
3. **使用ACPI表格获取系统的内存布局**
   - **原理**：ACPI（Advanced Configuration and Power Interface）表格包含了系统的各种配置信息，其中包括内存布局信息。操作系统可以通过读取ACPI表格来获取可用物理内存范围。
   - **优点**：ACPI是一种标准化的接口，能够提供较为准确和统一的信息。
   - **缺点**：ACPI表格的内容可能较为复杂，操作系统需要有相应的解析机制。
4. **在某些情况下，操作系统可以直接进行内存扫描或通过硬件抽象层（HAL）进行管理**
   - **内存扫描原理**：操作系统可以尝试从某个起始地址开始，逐步对内存进行读写测试，根据读写结果判断哪些内存是可用的。
   - **优点**：不依赖于其他外部机制，操作系统可以自主探测。
   - **缺点**：内存扫描可能会耗费大量时间，而且在扫描过程中可能会干扰到已经在使用的内存区域，导致系统不稳定。
   - **硬件抽象层（HAL）原理**：HAL可以对硬件资源进行抽象和管理，它可以向操作系统提供关于可用物理内存的信息。
   - **优点**：对操作系统屏蔽了硬件的复杂性，能够较好地管理硬件资源。
   - **缺点**：HAL本身的实现较为复杂，且依赖于硬件平台。
5. **某些处理器支持的机制也可以用于内存布局探测**
   - **原理**：一些处理器有内置的机制用于探测内存布局，操作系统可以利用这些机制。
   - **优点**：与处理器紧密结合，可能获取到准确和高效的内存布局信息。
   - **缺点**：这种机制通常是处理器特定的，缺乏通用性。

现代操作系统通常使用BIOS/UEFI和ACPI表格来获取物理内存的布局信息，确保系统在启动时能够正确分配和管理内存资源。

## 三、sv39相关内存定义
1. **物理地址和虚拟地址**
   - 在sv39中，物理地址(Physical Address)有56位，而虚拟地址(Virtual Address)有39位。实际使用时，一个虚拟地址要占用64位，只有低39位有效，并且规定63−39位的值必须等于第38位的值（类似有符号整数的规则），否则该虚拟地址被认为不合法，访问时会产生异常。
2. **satp寄存器**
   - satp里面存的不是最高级页表（三级页表的根节点）的起始物理地址，而是它所在的物理页号。
   - 1000表示sv39页表，对应的虚拟内存空间高达512GiB。

> Challenges是选做，完成Challenge的同学可单独提交Challenge。完成得好的同学可获得最终考试成绩的加分。
