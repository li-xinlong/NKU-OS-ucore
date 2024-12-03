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
// proc_list 是一个全局变量，用来管理当前所有的进程。
list_entry_t proc_list;

// 哈希表的大小
#define HASH_SHIFT 10
// 1024，哈希表大小
#define HASH_LIST_SIZE (1 << HASH_SHIFT)
// 获取hash后的值
#define pid_hashfn(x) (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
// 指向一个特殊的进程结构，用来表示系统的空闲进程（idle）
struct proc_struct *idleproc = NULL;
// init proc
// 指向系统的第一个用户态进程（init），由内核在启动阶段创建。initproc 通常是用户态所有进程的祖先（它是 PID=1 的进程）。
struct proc_struct *initproc = NULL;
// current proc
// 指向当前正在 CPU 上运行的进程。每次进程切换时，current 会更新为切换后的目标进程。
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);

/*将当前进程（由 from 指向的进程）的寄存器（如 ra、sp、s0、s1 等）保存在内存中。(一共14个寄存器)
从目标进程（由 to 指向的进程）对应的内存位置加载寄存器状态。
ra（返回地址）寄存器用于存储函数调用的返回地址，确保在上下文切换后可以返回到正确的位置。
sp（栈指针）寄存器用于指示栈的顶部，栈用于存储函数调用的局部变量等数据。

这些寄存器被加载到处理器的相应寄存器中，以便目标进程可以恢复到它之前的状态并继续执行。
*/
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        // LAB4:EXERCISE1 2212599 2212294 2212045
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
        proc->pid = -1; //-1表示尚未分配pid
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN);
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

// get_proc_name - 获取进程的名称
char *
get_proc_name(struct proc_struct *proc)
{
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// get_pid - 为进程分配一个唯一的pid
static int
get_pid(void)
{
    // 确保进程 ID（PID）的最大值大于系统中允许的最大进程数。这样可以保证每个进程都能分配到一个唯一的 PID
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
        // 遍历全局进程链表 proc_list，检查当前所有进程是否正在使用 last_pid。
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

// proc_run - 使进程 "proc" 在 CPU 上运行
// 注意：在调用 switch_to 之前，应加载 "proc" 的新 PDT 的基地址
void proc_run(struct proc_struct *proc)
{
    // 判断目标进程是否是当前正在运行的进程
    if (proc != current)
    {
        // LAB4:EXERCISE3 2212599 2212294 2212045
        /*
         * 一些有用的宏、函数和定义，你可以在下面的实现中使用它们。
         * 宏或函数：
         *   local_intr_save()：       禁用中断
         *   local_intr_restore()：    启用中断
         *   lcr3()：                  修改 CR3 寄存器的值
         *   switch_to()：             在两个进程之间进行上下文切换
         */
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag);
        {
            current = proc;
            /*RISC-V 中的 SATP 寄存器用于存储当前进程的页表基址。
            当操作系统进行进程切换时，目标进程的页表基址需要被加载到 SATP 寄存器中。
            这样，新的进程在执行时，CPU 会使用目标进程的页表来进行虚拟地址到物理地址的映射，从而确保新进程的内存访问是正确的。
            */
            lcr3(proc->cr3);

            switch_to(&(prev->context), &(next->context));
        }
        local_intr_restore(intr_flag);
    }
}

// forkret -- 新线程/进程的第一个内核入口点
// 注意：forkret的地址在copy_thread函数中设置
//       在切换到新进程后，当前进程将从这里开始执行。
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

// find_proc - find proc frome proc hash_list according to pid
// 在hash链表中查找
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

// kernel_thread - 使用 "fn" 函数创建一个内核线程
// 注意：临时 trapframe tf 的内容将被复制到 do_fork-->copy_thread 函数中的 proc->tf
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    // 初始化一个进程的栈
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    // 设置内核线程的参数和函数指针
    tf.gpr.s0 = (uintptr_t)fn;  // s0 寄存器保存函数指针
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数

    // 设置 trapframe 中的 status 寄存器（SSTATUS）
    // SSTATUS_SPP：Supervisor Previous Privilege（设置为 supervisor 模式，因为这是一个内核线程）
    // SSTATUS_SPIE：Supervisor Previous Interrupt Enable（设置为启用中断，因为这是一个内核线程）
    // SSTATUS_SIE：Supervisor Interrupt Enable（设置为禁用中断，因为我们不希望该线程被中断）
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    // 将入口点（epc）设置为 kernel_thread_entry 函数，作用实际上是将pc指针指向它(*trapentry.S会用到)
    // tf.epc 是 trapframe 结构中的程序计数器寄存器，它指定了内核线程执行时的入口地址。
    tf.epc = (uintptr_t)kernel_thread_entry;
    // 使用 do_fork 创建一个新进程（内核线程），这样才真正用设置的tf创建新进程。
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
// 为进程分配内核栈空间
static int
setup_kstack(struct proc_struct *proc)
{
    // 分配一页内存作为内核栈
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL)
    {
        // 将分配的页转换为内核虚拟地址
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc)
{
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// copy_mm - 根据 clone_flags，将进程 "proc" 复制或共享进程 "current" 的内存管理信息
//         - 如果 clone_flags & CLONE_VM，则 "共享" ；否则 "复制"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    assert(current->mm == NULL);
    /* 在这个项目中不做任何操作 */
    return 0;
}

// copy_thread - 在进程的内核栈顶设置 trapframe，并设置进程的内核入口点和栈
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
    // 将 trapframe 复制到进程的内核栈顶
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    *(proc->tf) = *tf;

    // 将 a0 设置为 0，以便子进程知道它刚刚被 fork
    proc->tf->gpr.a0 = 0;
    // 如果 esp 为 0，则将 sp 设置为进程的 trapframe 地址，否则设置为 esp
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    // 设置进程的返回地址为 forkret
    proc->context.ra = (uintptr_t)forkret;
    // 设置进程的栈指针为 trapframe 的地址
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork -     父进程创建一个新的子进程
 * @clone_flags: 用于指导如何克隆子进程
 * @stack:       父进程的用户栈指针。如果stack==0，则表示fork一个内核线程。
 * @tf:          trapframe信息，将被复制到子进程的proc->tf中
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
    // LAB4:EXERCISE2 2212599 2212294 2212045
    /*
     * 一些有用的宏、函数和定义，你可以在下面的实现中使用它们。
     * 宏或函数：
     *   alloc_proc:   创建一个proc结构并初始化字段（lab4:exercise1）
     *   setup_kstack: 为进程分配大小为KSTACKPAGE的内核栈的页
     *   copy_mm:      根据clone_flags，进程"proc"复制或共享进程"current"的mm
     *                 如果clone_flags & CLONE_VM，则"共享"；否则"复制"
     *   copy_thread:  在进程的内核栈顶设置trapframe，并设置进程的内核入口点和栈
     *   hash_proc:    将proc添加到proc hash_list中
     *   get_pid:      为进程分配一个唯一的pid
     *   wakeup_proc:  设置proc->state = PROC_RUNNABLE
     * 变量：
     *   proc_list:    进程集合的列表
     *   nr_process:   进程集合的数量
     */

    //    1. 调用alloc_proc分配一个proc_struct
    //    2. 调用setup_kstack为子进程分配一个内核栈
    //    3. 调用copy_mm根据clone_flag复制或共享mm
    //    4. 调用copy_thread在proc_struct中设置tf和context
    //    5. 将proc_struct插入到hash_list和proc_list中
    //    6. 调用wakeup_proc使新的子进程变为RUNNABLE状态
    //    7. 使用子进程的pid设置ret值

    // 1. 调用 alloc_proc 分配一个进程控制块
    if ((proc = alloc_proc()) == NULL)
    {
        goto fork_out;
    }

    // 2. 调用 setup_kstack 为进程分配一个内核栈
    if (setup_kstack(proc) != 0)
    {
        goto bad_fork_cleanup_proc;
    }

    // 3. 调用 copy_mm 根据 clone_flags 复制或共享内存管理信息
    if (copy_mm(clone_flags, proc) != 0)
    {
        goto bad_fork_cleanup_kstack;
    }

    // 4. 调用 copy_thread 复制原进程的上下文信息
    copy_thread(proc, stack, tf);

    // 5. 将新进程插入到进程hash列表和进程列表中
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);
        list_add(&proc_list, &(proc->list_link));
        nr_process++;
    }
    local_intr_restore(intr_flag);

    // 6. 将新进程设置为就绪状态
    wakeup_proc(proc);

    // 7. 返回新进程的pid
    ret = proc->pid;

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
int do_exit(int error_code)
{
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// proc_init - 设置第一个内核线程 idleproc "idle" 并创建第二个内核线程 init_main
void proc_init(void)
{
    int i;

    list_init(&proc_list); // 初始化进程列表

    for (i = 0; i < HASH_LIST_SIZE; i++)
    {
        list_init(hash_list + i); // 初始化哈希链表中每一个块
    }

    if ((idleproc = alloc_proc()) == NULL)
    {
        panic("cannot alloc idleproc.\n"); // 分配空闲进程失败，发生错误
    }

    // 检查进程结构
    int *context_mem = (int *)kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    if (idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
    {
        cprintf("alloc_proc() correct!\n"); // 分配进程控制块正确
    }

    idleproc->pid = 0;                       // 设置空闲进程的pid为0
    idleproc->state = PROC_RUNNABLE;         // 设置空闲进程的状态为可运行
    idleproc->kstack = (uintptr_t)bootstack; // 设置空闲进程的内核栈
    idleproc->need_resched = 1;              // 设置空闲进程需要重新调度
    set_proc_name(idleproc, "idle");         // 设置空闲进程的名称为"idle"
    nr_process++;                            // 进程数加1

    current = idleproc; // 当前进程设置为空闲进程

    int pid = kernel_thread(init_main, "Hello world!!", 0); // 创建第二个内核线程
    if (pid <= 0)
    {
        panic("create init_main failed.\n"); // 创建init_main失败，发生错误
    }

    initproc = find_proc(pid);       // 根据pid查找进程
    set_proc_name(initproc, "init"); // 设置init进程的名称为"init"

    assert(idleproc != NULL && idleproc->pid == 0); // 断言空闲进程不为空且pid为0
    assert(initproc != NULL && initproc->pid == 1); // 断言init进程不为空且pid为1
}

// cpu_idle - 在 kern_init 结束时，第一个内核线程 idleproc 将执行以下工作
// cpu_idle 函数，它是一个无限循环的空闲线程。当系统没有其他需要运行的任务时，cpu_idle 会被执行。
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
