#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>

// process's state in his life cycle
enum proc_state
{
    PROC_UNINIT = 0, // 未初始化状态。
    PROC_SLEEPING,   // 睡眠状态。进程正在等待某个事件或资源，无法继续运行。处于此状态的进程不会被调度，直到等待的事件被触发或资源变得可用。
    PROC_RUNNABLE,   // 可运行状态。表示进程已经准备好运行，可以被调度器选择并运行在 CPU 上。
    PROC_ZOMBIE,     // 僵尸状态。表示进程已结束执行，但其父进程尚未回收其资源（如退出码、进程描述符等）。
};
// 一共14个寄存器，寄存器可以分为调用者保存（caller-saved）寄存器和被调用者保存（callee-saved）寄存器。
// 实际的进程切换过程中我们只需要保存被调用者保存寄存器
struct context
{
    uintptr_t ra; // 保存函数调用的返回地址。
    uintptr_t sp; // 指向当前任务或进程的栈顶。
    uintptr_t s0; // 通常用作函数的帧指针，指向当前函数栈帧的基地址。
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};
// 进程名称的最大长度
#define PROC_NAME_LEN 15
// 最大进程数量
#define MAX_PROCESS 4096
// 最大进程ID
#define MAX_PID (MAX_PROCESS * 2)
// 所有进程控制块的双向线性列表，proc_struct中的成员变量list_link将链接入这个链表中。
extern list_entry_t proc_list;
// 进程结构体
struct proc_struct
{
    /**
     * 进程的生命周期中的状态枚举。
     * - PROC_UNINIT：未初始化状态，表示进程还未被创建或初始化。
     * - PROC_SLEEPING：睡眠状态，表示进程正在等待某个事件的发生。
     * - PROC_RUNNABLE：可运行状态，表示进程已经准备好运行，但还未被调度执行。
     * - PROC_ZOMBIE：僵尸状态，表示进程已经执行完毕，但其父进程还未对其进行善后处理。
     */
    enum proc_state state;        // 进程状态
    int pid;                      // 进程ID
    int runs;                     // 运行次数
    uintptr_t kstack;             // 进程内核栈
    volatile bool need_resched;   // 是否需要重新调度释放CPU？
    struct proc_struct *parent;   // 父进程
    struct mm_struct *mm;         // 进程的内存管理字段
    struct context context;       // 进程执行的上下文
    struct trapframe *tf;         // 中断帧
    uintptr_t cr3;                // CR3寄存器：页目录表（PDT）的基地址
    uint32_t flags;               // 进程标志
    char name[PROC_NAME_LEN + 1]; // 进程名称
    list_entry_t list_link;       // 进程链表链接
    list_entry_t hash_link;       // 进程哈希链表链接
    int exit_code;                // 退出码（发送给父进程）
    uint32_t wait_state;          // 等待状态
    // proc->yptr 是当前进程的“年幼兄弟”指针，指向当前进程的下一个兄弟进程。
    struct proc_struct *cptr, *yptr, *optr; // 进程之间的关系
};
// 表示该进程正在退出（shutting down），通常在 do_exit 或类似的退出流程中设置。
#define PF_EXITING 0x00000001 // getting shutdown

// 表示进程的等待状态，用于标记进程当前在等待子进程退出。它是一个组合标志，由 0x00000001 和 WT_INTERRUPTED 共同组成。
#define WT_CHILD (0x00000001 | WT_INTERRUPTED)
// 表示进程的等待状态是可以被中断的。
#define WT_INTERRUPTED 0x80000000 // the wait state could be interrupted

/**
 * 将链表节点转换为进程结构体的宏
 *
 * 该宏用于将链表节点转换为进程结构体，通过给定的链表节点指针和进程结构体成员的偏移量，
 * 返回对应的进程结构体指针。
 *
 * @param le 链表节点指针
 * @param member 进程结构体成员的偏移量
 * @return 对应的进程结构体指针
 */
#define le2proc(le, member) \
    to_struct((le), struct proc_struct, member)

extern struct proc_struct *idleproc, *initproc, *current;

void proc_init(void);
void proc_run(struct proc_struct *proc);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
void cpu_idle(void) __attribute__((noreturn));

struct proc_struct *find_proc(int pid);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_exit(int error_code);
int do_yield(void);
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size);
int do_wait(int pid, int *code_store);
int do_kill(int pid);
#endif /* !__KERN_PROCESS_PROC_H__ */
