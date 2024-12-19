#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc,
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:

  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  +
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit
SYS_getpid      : get the process's pid

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT 10
#define HASH_LIST_SIZE (1 << HASH_SHIFT)
#define pid_hashfn(x) (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        // LAB4:EXERCISE1 YOUR CODE
        /*
         * below fields in proc_struct need to be initialized
         *       enum proc_state state;                      // Process state
         *       int pid;                                    // Process ID
         *       int runs;                                   // the running times of Proces
         *       uintptr_t kstack;                           // Process kernel stack
         *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
         *       struct proc_struct *parent;                 // the parent process
         *       struct mm_struct *mm;                       // Process's memory management field
         *       struct context context;                     // Switch here to run process
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        proc->state = PROC_UNINIT;
        proc->pid = -1;
        proc->runs = 0;
        proc->kstack = NULL;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN + 1);

        // LAB5 2212599 2212294 2212045 : (update LAB4 steps)
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        /*
        wait_state用于记录进程当前的等待状态，包括等待子进程结束、等待某个事件发生等等。
        这个字段的存在使得ucore能够实现进程的等待和唤醒机制，从而可以在进程间实现协作和同步。
        */

        /*
        cptr，yptr和optr是用于实现进程间通信的指针。

        * cptr（child process pointer）指向该进程的子进程，即该进程创建的子进程；
        * yptr（young sibling pointer）指向该进程的下一个兄弟进程，即该进程的创建时间比该进程晚的兄弟进程；
        * optr（older sibling pointer）指向该进程的上一个兄弟进程，即该进程的创建时间比该进程早的兄弟进程。

        这些指针的存在使得进程可以通过父子关系或兄弟关系进行通信和协作，从而实现了进程间的协作。
        例如，一个进程可以通过cptr指向的子进程来传递数据或指令，
        也可以通过yptr和optr指向的兄弟进程来协同完成某些任务。
        */
        proc->wait_state = 0;
        proc->cptr = NULL;
        proc->yptr = NULL;
        proc->optr = NULL;
    }
    return proc;
}

// set_proc_name - 设置进程的名称
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc)
{
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// set_links - 设置进程的关系链接
static void
set_links(struct proc_struct *proc)
{
    list_add(&proc_list, &(proc->list_link));      // 将进程添加到进程列表中
    proc->yptr = NULL;                             // 将年幼兄弟指针设置为NULL
    if ((proc->optr = proc->parent->cptr) != NULL) // 如果父进程有子进程
    {
        proc->optr->yptr = proc; // 将父进程的子进程的年长兄弟指针设置为当前进程
    }
    proc->parent->cptr = proc; // 将父进程的子进程指针设置为当前进程
    nr_process++;              // 增加进程数
}

// remove_links - 清除进程的关系链接
static void
remove_links(struct proc_struct *proc)
{
    list_del(&(proc->list_link)); // 从进程列表中删除进程
    if (proc->optr != NULL)       // 如果进程有一个年长的兄弟
    {
        proc->optr->yptr = proc->yptr; // 更新年长兄弟的年轻兄弟指针
    }
    if (proc->yptr != NULL) // 如果进程有一个年轻的兄弟
    {
        proc->yptr->optr = proc->optr; // 更新年轻兄弟的年长兄弟指针
    }
    else // 如果进程没有年轻的兄弟
    {
        proc->parent->cptr = proc->optr; // 更新父进程的子进程指针为年长兄弟
    }
    nr_process--; // 减少进程数
}

// get_pid - alloc a unique pid for process
static int
get_pid(void)
{
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID)
    {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe)
    {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list)
        {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid)
            {
                if (++last_pid >= next_safe)
                {
                    if (last_pid >= MAX_PID)
                    {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid)
            {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void proc_run(struct proc_struct *proc)
{
    if (proc != current)
    {
        // LAB4:EXERCISE3 YOUR CODE
        /*
         * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
         * MACROs or Functions:
         *   local_intr_save():        Disable interrupts
         *   local_intr_restore():     Enable Interrupts
         *   lcr3():                   Modify the value of CR3 register
         *   switch_to():              Context switching between two processes
         */
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag); // 禁用中断
        // 实现切换进程
        { // 切换当前进程为要运行的进程
            current = proc;
            // 切换页表，以便使用新进程的地址空间。
            lcr3(next->cr3);
            // 实现上下文切换。
            switch_to(&(prev->context), &(next->context));
        }
        local_intr_restore(intr_flag); // 允许中断
    }
}

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc)
{
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc)
{
    list_del(&(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid)
{
    if (0 < pid && pid < MAX_PID)
    {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list)
        {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid)
            {
                return proc;
            }
        }
    }
    return NULL;
}

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to
//       proc->tf in do_fork-->copy_thread function
// kernel_thread - 使用 "fn" 函数创建一个内核线程
// 注意：临时 trapframe tf 的内容将被复制到 do_fork-->copy_thread 函数中的 proc->tf
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.gpr.s0 = (uintptr_t)fn;
    tf.gpr.s1 = (uintptr_t)arg;
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    tf.epc = (uintptr_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
// 为进程分配内核栈空间
static int
setup_kstack(struct proc_struct *proc)
{
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL)
    {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - 释放进程内核栈的内存空间
static void
put_kstack(struct proc_struct *proc)
{
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// setup_pgdir - alloc one page as PDT
// 用于设置进程的页目录（Page Directory）。它的作用是为指定的进程分配一页内存，并将该内存作为页目录表 (PDT)，同时初始化页目录表的内容。
static int
setup_pgdir(struct mm_struct *mm)
{
    struct Page *page;
    if ((page = alloc_page()) == NULL)
    {
        return -E_NO_MEM;
    }
    pde_t *pgdir = page2kva(page);
    memcpy(pgdir, boot_pgdir, PGSIZE);

    mm->pgdir = pgdir;
    return 0;
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
    free_page(kva2page(mm->pgdir));
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
// 主要用于处理进程内存空间的复制或共享。根据 clone_flags 标志来判断是复制内存（CLONE_VM 不设置）还是共享内存（CLONE_VM 设置）。
// 如果是共享内存，则子进程将共享父进程的虚拟内存；如果是复制内存，则会为子进程创建一个新的内存空间并进行初始化。
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    // oldmm 为当前进程的内存管理结构，oldmm 为 NULL 时表示当前进程是一个内核线程
    // mm 为新进程的内存管理结构
    struct mm_struct *mm, *oldmm = current->mm;

    /* current is a kernel thread */
    // 当前进程是一个内核线程，,不涉及用户空间的内存操作,因此直接返回 0
    if (oldmm == NULL)
    {
        return 0;
    }
    /*
    如果 clone_flags 中设置了 CLONE_VM，表示子进程和父进程共享内存空间（虚拟内存）。
    因此，直接将 mm 设置为 oldmm（即父进程的内存描述符），然后跳转到 good_mm，后续将增加 mm 的引用计数。
    */
    if (clone_flags & CLONE_VM)
    {
        mm = oldmm;
        goto good_mm;
    }
    int ret = -E_NO_MEM;
    // 创建一个新的内存管理结构
    if ((mm = mm_create()) == NULL)
    {
        goto bad_mm;
    }
    // 为新进程分配一个页目录表
    if (setup_pgdir(mm) != 0)
    {
        goto bad_pgdir_cleanup_mm;
    }
    // 锁定父进程的内存结构（oldmm），然后通过 dup_mmap() 复制父进程的内存映射（VMA）到新进程 mm 中。复制完成后解锁父进程的内存结构。
    lock_mm(oldmm);
    {
        ret = dup_mmap(mm, oldmm);
    }
    unlock_mm(oldmm);
    // 复制失败，释放新进程的页目录表并返回错误
    if (ret != 0)
    {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
/*
copy_thread 函数的作用是为新创建的进程设置内核栈和 trapframe（用于保存CPU寄存器状态的结构体），
并设置进程的内核入口点和栈指针。这个函数通常在进程创建（如 fork）时使用，用于初始化新进程的状态。
*/
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
    // proc->tf 是一个指针，指向新进程的 trapframe
    // 将 proc->tf 设置为内核栈顶部，即栈的最后一个位置，用于保存进程的寄存器状态。
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    // 将父进程的 trapframe（即 tf）内容复制到新进程的 trapframe 中
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    // a0 寄存器通常用于存储系统调用的返回值或参数。这里将其设置为 0，表示这是一个新创建的子进程。
    proc->tf->gpr.a0 = 0;
    // 这行代码设置 sp（栈指针）。如果传入的 esp 为 0，则将栈指针设置为 trapframe 的地址，即将栈指针指向新进程的 trapframe。否则，使用传入的 esp 作为栈指针。
    /// 如果传入的 esp 为 0，则将栈指针设置为 trapframe 的地址，即将栈指针指向新进程的 trapframe。否则，使用传入的 esp 作为栈指针。
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    /*
    这两行代码设置新进程的 context（上下文）。
    ra（返回地址）寄存器设置为 forkret，这是新进程启动时的入口函数。
    sp（栈指针）寄存器设置为 trapframe 的地址，以确保进程在恢复时使用正确的栈。
    */
    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
                 copy_mm()用到

 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
                 当前用户态esp的值，copy_thread()用到

 * @tf:          the trapframe info, which will be copied to child process's proc->tf
                 父进程的trapframe，copy_thread()用到
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    // LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid

    //    1. call alloc_proc to allocate a proc_struct
    proc = alloc_proc(); // 分配prod
    if (proc == NULL)
        goto fork_out;
    proc->parent = current;           // 将当前进程设置为父进程
    assert(current->wait_state == 0); // 确保父进程不处于等待状态
    //    2. call setup_kstack to allocate a kernel stack for child process
    ret = setup_kstack(proc); // 分配kernel_stack
    if (ret != 0)
        goto fork_out;
    //    3. call copy_mm to dup OR share mm according clone_flag
    ret = copy_mm(clone_flags, proc); // 复制父进程内存，为新进程创建新的虚拟空间
    if (ret != 0)
        goto fork_out;
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc, stack, tf); // 设置trapframe和context

    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        //    5. insert proc_struct into hash_list && proc_list
        hash_proc(proc);
        // list_add(&proc_list,&(proc->list_link));
        set_links(proc); // 设置进程的链接关系，在函数内部会将进程插入proc_list
    }
    local_intr_restore(intr_flag);

    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid
    ret = proc->pid; // 父进程得到子进程的pid

    // LAB5 2212599 2212294 2212045 : (update LAB4 steps)
    // TIPS: you should modify your written code in lab4(step1 and step5), not add more code.
    /* Some Functions
     *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process
     *    -------------------
     *    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
     *    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
     */

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
// do_exit 函数用于处理进程退出的操作，确保资源释放、进程状态更新以及相关的父子进程关系调整。
int do_exit(int error_code)
{
    // 检查是否为空闲进程或初始化进程，如果是的话，调用 panic 报错并停止执行，因为空闲进程或初始化进程不应该退出。
    if (current == idleproc)
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
    {
        panic("initproc exit.\n");
    }
    // 1. 调用 exit_mmap & put_pgdir & mm_destroy 释放进程的内存空间
    struct mm_struct *mm = current->mm;
    if (mm != NULL)
    {
        //// 切换到内核页表，确保接下来的操作在内核空间执行
        lcr3(boot_cr3);
        // 如果mm引用计数减到0，说明没有其他进程共享此mm
        if (mm_count_dec(mm) == 0)
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        // 将当前进程的mm设置为NULL，表示资源已经释放
        current->mm = NULL;
    }
    // 2. 设置进程状态为 PROC_ZOMBIE（僵尸进程），然后调用 wakeup_proc(parent) 通知父进程回收自己
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code;
    // 处理中断标志并调整父进程关系：
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        // 获取当前进程的父进程
        proc = current->parent;
        // 如果父进程的 wait_state 是 WT_CHILD，表示父进程在等待子进程的退出，调用 wakeup_proc 唤醒父进程。
        if (proc->wait_state == WT_CHILD)
        {
            wakeup_proc(proc);
        }
        // 接着处理当前进程的所有子进程，将子进程的父进程指针调整为 initproc，并将它们链接到 initproc 的子进程链表中。
        while (current->cptr != NULL)
        {
            proc = current->cptr;
            current->cptr = proc->optr;
            // 设置子进程的父进程为initproc，并加入initproc的子进程链表
            proc->yptr = NULL;
            if ((proc->optr = initproc->cptr) != NULL)
            {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            // 如果子进程也处于退出状态，唤醒initproc，以便回收该子进程。
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
                {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    // 开中断
    local_intr_restore(intr_flag);
    // 调用 schedule() 函数开始调度，选择下一个要执行的进程。
    schedule();
    // do_exit 应该在此结束，但由于调用 schedule() 后控制权已经转移，后面的代码不应该再执行。如果真的执行到这里，调用 panic 报错，输出当前进程的 ID。
    panic("do_exit will not return!! %d.\n", current->pid);
}

/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
// load_icode 函数的主要功能是加载一个 ELF 格式的可执行文件到当前进程的虚拟内存空间中，并为其构建执行环境。
static int
load_icode(unsigned char *binary, size_t size)
{
    if (current->mm != NULL)
    {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    // 1.初始化内存管理结构

    // 完成新的进程内存空间的初始化
    //(1) create a new mm for current process
    //  创建一个新的内存空间
    if ((mm = mm_create()) == NULL)
    {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    // 创建页表
    if (setup_pgdir(mm) != 0)
    {
        goto bad_pgdir_cleanup_mm;
    }
    // 2.解析 ELF 文件
    // 将新的进程数据填入为其准备的内存空间中
    // 复制二进制程序的 TEXT/DATA 段，并在进程的内存空间中构建 BSS 部分
    struct Page *page;
    // 获取二进制程序（ELF 格式）的文件头
    struct elfhdr *elf = (struct elfhdr *)binary;
    // 获取二进制程序（ELF 格式）的程序段头入口
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    // 这个程序是有效的吗？
    if (elf->e_magic != ELF_MAGIC)
    {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    // 3. 加载程序段

    uint32_t vm_flags, perm;
    // 遍历程序头,
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph++)
    {
        // 遍历 ELF 的程序头（program header），定位需要加载的程序段（LOAD 段）。
        if (ph->p_type != ELF_PT_LOAD)
        {
            continue;
        }
        // 校验和映射虚拟内存,校验程序段大小，创建对应的虚拟内存区域（vma）。
        if (ph->p_filesz > ph->p_memsz)
        {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0)
        {
            // continue ;
        }
        //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph->p_flags & ELF_PF_X)
            vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W)
            vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R)
            vm_flags |= VM_READ;
        // modify the perm bits here for RISC-V
        if (vm_flags & VM_READ)
            perm |= PTE_R;
        if (vm_flags & VM_WRITE)
            perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC)
            perm |= PTE_X;
        // mm_map创建一个合法的vma空间
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
        {
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

        //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
        //(3.6.1) copy TEXT/DATA section of bianry program
        // 拷贝程序的代码 内容(.text)/数据段(.data ) 内容到进程空间中
        // data段存储初始化的全局变量和静态变量
        // text段存储程序的代码
        while (start < end)
        {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
            {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la)
            {
                size -= la - end;
            }
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }
        // 构建 .bss 段,为 .bss 段分配内存并清零，确保未初始化数据段正确初始化为 0
        // bss段存储未初始化的全局变量和静态变量

        //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
        if (start < la)
        {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end)
            {
                continue;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la)
            {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end)
        {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
            {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la)
            {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    // 4.构建用户栈,分配和映射用户栈，确保用户程序拥有独立的栈空间。
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
    {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);

    // 截止到(4)结束，ELF程序的内存空间以及建立完毕

    //(5) 更新进程环境
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir)); // 加载当前ELF的页表，ELF完成加载（目前在kernel空间）

    // 步骤(6)会创建trapframe，从而使当前程序能够从 kernel空间 加载到 user空间 中
    // 涉及从 ring0 到 ring3 的切换，使 kstack 切换为 用户栈
    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:EXERCISE1 2212599 2212294 2212045
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf->gpr.sp should be user stack top (the value of sp)
     *          tf->epc should be entry point of user program (the value of sepc)
     *          tf->status should be appropriate for user program (the value of sstatus)
     *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
     */

    /* 应设置 tf->gpr.sp、tf->epc、tf->status
     * 注意：如果我们正确设置了 trapframe，那么用户级进程就可以从内核返回 USER MODE。所以tf->gpr.sp 应该是用户栈顶（sp 的值）
     * tf->epc 应该是用户程序的入口（sepc 的值）。
     * tf->status 应适合用户程序（sstatus 的值）
     * 提示：检查 SSTATUS 中 SPP、SPIE 的含义，通过 SSTATUS_SPP、SSTATUS_SPIE（定义在 risv.h 中）使用它们。
     */
    // SSTATUS_SPP：Supervisor Previous Privilege（设置为 supervisor 模式）
    // SSTATUS_SPIE：Supervisor Previous Interrupt Enable（设置为启用中断）
    tf->gpr.sp = USTACKTOP;                                          // 设置f->gpr.sp为用户栈的顶部地址
    tf->epc = elf->e_entry;                                          // 设置tf->epc为用户程序的入口地址
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE); // 根据需要设置 tf->status 的值，清除 SSTATUS_SPP 和 SSTATUS_SPIE 位
                                                                     /*
                                                                        SSTATUS_SPP: 在ucore中，这个字段用于记录处理器从用户态(U)切换到内核态(S)时的特权级别。
                                                                        SSTATUS_SPIE: 在ucore中，这个字段用于记录处理器从用户态切换到内核态时的中断使能状态。
                                                                        */
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size)
{
    struct mm_struct *mm = current->mm;
    // 检查name的内存空间能否被访问
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
    {
        return -E_INVAL;
    }
    // 进程名字的长度有上限 PROC_NAME_LEN，在proc.h定义
    if (len > PROC_NAME_LEN)
    {
        len = PROC_NAME_LEN;
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
    memcpy(local_name, name, len);

    if (mm != NULL)
    {
        cputs("mm != NULL");
        lcr3(boot_cr3); // 加载内核页表
        // 如果引用计数为0，释放内存空间
        if (mm_count_dec(mm) == 0)
        {
            // 将进程内存管理对应的空间清空
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm); // 把进程当前占用的内存释放，之后重新分配内存
        }
        current->mm = NULL;
    }
    int ret;
    // //把新的程序加载到当前进程里的工作都在load_icode()函数里完成
    if ((ret = load_icode(binary, size)) != 0)
    {
        goto execve_exit; // 返回不为0，则加载失败
    }
    // 如果set_proc_name的实现不变, 为什么不能直接set_proc_name(current, name)? 为什么要用local_name?
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}

// do_yield - ask the scheduler to reschedule
int do_yield(void)
{
    current->need_resched = 1;
    return 0;
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
/*
等待特定子进程（通过 pid 指定）或任意子进程（如果 pid == 0）。
返回退出的子进程的状态码（如果 code_store 不为 NULL）。
如果没有子进程或者没有符合条件的退出子进程，则返回错误码。

code_store：指向一个存储退出码的用户态指针。
*/
int do_wait(int pid, int *code_store)
{
    struct mm_struct *mm = current->mm;
    // 检查 code_store 是否是用户态进程可访问的合法地址。
    if (code_store != NULL)
    {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
        {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:

    // 表示当前进程是否有子进程（不论是否符合等待条件）。
    haskid = 0;
    // 寻找指定进程:使用 find_proc(pid) 查找进程。
    if (pid != 0)
    {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current)
        {
            haskid = 1;
            // 果目标进程处于 PROC_ZOMBIE（僵尸状态），跳转到 found 进行后续处理
            if (proc->state == PROC_ZOMBIE)
            {
                goto found;
            }
        }
    }
    // 寻找任意子进程（pid == 0）
    // 遍历当前进程的子进程链表（从 cptr 开始，通过 optr 遍历）。找到第一个符合条件的 PROC_ZOMBIE 子进程，跳转到 found。
    else
    {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr)
        {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE)
            {
                goto found;
            }
        }
    }
    // 如果有子进程但未找到符合条件的僵尸进程：阻塞等待
    if (haskid)
    {
        // 将当前进程设置为 PROC_SLEEPING 状态。
        current->state = PROC_SLEEPING;
        // 设置 wait_state 为 WT_CHILD，标明该进程处于等待子进程的状态。
        current->wait_state = WT_CHILD;
        // 调用 schedule() 进行上下文切换，让出 CPU。
        schedule();
        // 如果进程在等待过程中收到强制退出信号（标记为 PF_EXITING），调用 do_exit 退出当前进程。
        if (current->flags & PF_EXITING)
        {
            do_exit(-E_KILLED);
        }
        // 等待结束后，重新检查子进程状态（跳转到 repeat）。
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleproc || proc == initproc)
    {
        panic("wait idleproc or initproc.\n");
    }
    // 如果 code_store 不为 NULL，将子进程的退出码写入到 code_store 指向的内存中。
    if (code_store != NULL)
    {
        *code_store = proc->exit_code;
    }
    // 清理子进程资源
    // 1. 关闭中断：保护以下操作的原子性。
    local_intr_save(intr_flag);
    {
        // 2. 解除进程引用：
        // 从哈希表中删除进程。
        unhash_proc(proc);
        // 从父进程和兄弟进程的链表中移除该子进程。
        remove_links(proc);
    }
    local_intr_restore(intr_flag);
    // 3. 释放子进程的内核栈和 proc 结构。
    put_kstack(proc);
    kfree(proc);
    return 0;
}

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int do_kill(int pid)
{
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL)
    {
        if (!(proc->flags & PF_EXITING))
        {
            proc->flags |= PF_EXITING;
            if (proc->wait_state & WT_INTERRUPTED)
            {
                wakeup_proc(proc);
            }
            return 0;
        }
        return -E_KILLED;
    }
    return -E_INVAL;
}

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
// 用于在内核中启动用户态程序。
/*
name：用户态程序的名称（字符串）。
binary：程序二进制的起始地址。
size：程序的大小（以字节为单位）。

ret：用于存储系统调用的返回值。
len：程序名称 name 的长度，计算后传递给系统调用。
*/
static int
kernel_execve(const char *name, unsigned char *binary, size_t size)
{
    int64_t ret = 0, len = strlen(name);
    // 在这里为什么不直接调用 do_execve 函数，而是通过内联汇编调用系统调用？
    /*
    do_execve() load_icode()里面只是构建了用户程序运行的上下文，但是并没有完成切换。
    上下文切换实际上要借助中断处理的返回来完成。直接调用do_execve()是无法完成上下文切换的。
    如果是在用户态调用exec(), 系统调用的ecall产生的中断返回时， 就可以完成上下文切换。

    为什么此时还在S态？kernel_execve用于在内核中启动用户态程序。

    由于目前我们在S mode下，所以不能通过ecall来产生中断。
    我们这里采取一个取巧的办法，用ebreak产生断点中断进行处理，通过设置a7寄存器的值为10说明这不是一个普通的断点中断，
    而是要转发到syscall(), 这样用一个不是特别优雅的方式，实现了在内核态使用系统调用。
    */
    //   ret = do_execve(name, len, binary, size);
    asm volatile(
        "li a0, %1\n"                                                // 加载常量 SYS_exec 到寄存器 a0
        "lw a1, %2\n"                                                // 加载程序名称的地址到寄存器 a1
        "lw a2, %3\n"                                                // 加载名称长度到寄存器 a2
        "lw a3, %4\n"                                                // 加载程序二进制起始地址到寄存器 a3
        "lw a4, %5\n"                                                // 加载程序大小到寄存器 a4
        "li a7, 10\n"                                                // 设置系统调用编号为 10 到寄存器 a7
        "ebreak\n"                                                   // 触发系统调用（通常通过软件中断或特殊指令实现）
        "sw a0, %0\n"                                                // 将系统调用返回值从寄存器 a0 存储到 ret
        : "=m"(ret)                                                  // 输出约束，ret 是输出变量
        : "i"(SYS_exec), "m"(name), "m"(len), "m"(binary), "m"(size) // 输入约束，
        /*
        "i"(SYS_exec),      输入：系统调用号 SYS_exec
        "m"(name),          输入：程序名称的地址
        "m"(len),           输入：程序名称的长度
        "m"(binary),        输入：程序二进制起始地址
        "m"(size)           输入：程序二进制大小
         */

        : "memory"); // 修饰符：告知编译器汇编代码会修改内存
    cprintf("ret = %d\n", ret);
    return ret;
}
//__KERNEL_EXECVE 是最底层的核心宏
// 用于调用 kernel_execve 函数执行指定的用户态程序。
// kernel_execve(name, binary, size)：核心执行函数，启动指定的用户态程序。
#define __KERNEL_EXECVE(name, binary, size) ({           \
    cprintf("kernel_execve: pid = %d, name = \"%s\".\n", \
            current->pid, name);                         \
    kernel_execve(name, binary, (size_t)(size));         \
})
// 用于执行内核预定义的用户态程序。
/*
extern unsigned char _binary_obj___user_##x##_out_start[], _binary_obj___user_##x##_out_size[];：
声明链接器生成的全局符号。
_binary_obj___user_##x##_out_start：用户态程序二进制文件的起始地址。
_binary_obj___user_##x##_out_size：用户态程序二进制文件的大小。
*/
#define KERNEL_EXECVE(x) ({                                    \
    extern unsigned char _binary_obj___user_##x##_out_start[], \
        _binary_obj___user_##x##_out_size[];                   \
    __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,    \
                    _binary_obj___user_##x##_out_size);        \
})
// 用于启动任意指定的用户态程序，通过自定义的二进制起始地址和大小。
/*
x：程序名称（一个标识符）。
xstart：程序二进制文件的起始地址。
xsize：程序二进制文件的大小。
指定起始地址 xstart 和大小 xsize，这比 KERNEL_EXECVE 更灵活。
*/
#define __KERNEL_EXECVE2(x, xstart, xsize) ({   \
    extern unsigned char xstart[], xsize[];     \
    __KERNEL_EXECVE(#x, xstart, (size_t)xsize); \
})

#define KERNEL_EXECVE2(x, xstart, xsize) __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
    // 如果定义了 TEST，调用 KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE)，尝试加载和执行一个测试程序。
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    // 否则，调用 KERNEL_EXECVE(exit)，执行 exit 程序。
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
    // nr_free_pages()：获取当前系统的空闲页数量。
    // kallocated()：获取内核已分配内存的大小。
    size_t nr_free_pages_store = nr_free_pages();
    size_t kernel_allocated_store = kallocated();

    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0)
    {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
    assert(nr_process == 2);
    assert(list_next(&proc_list) == &(initproc->list_link));
    assert(list_prev(&proc_list) == &(initproc->list_link));

    cprintf("init check memory pass.\n");
    return 0;
}

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
    set_proc_name(idleproc, "idle");
    nr_process++;

    current = idleproc;

    int pid = kernel_thread(init_main, NULL, 0);
    if (pid <= 0)
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
    while (1)
    {
        if (current->need_resched)
        {
            schedule();
        }
    }
}
