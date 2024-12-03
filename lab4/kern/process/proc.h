#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>

// process's state in his life cycle
enum proc_state
{
    PROC_UNINIT = 0, // uninitialized
    PROC_SLEEPING,   // sleeping
    PROC_RUNNABLE,   // runnable(maybe running)
    PROC_ZOMBIE,     // almost dead, and wait parent proc to reclaim his resource
};

// 一共14个寄存器，寄存器可以分为调用者保存（caller-saved）寄存器和被调用者保存（callee-saved）寄存器。
// 实际的进程切换过程中我们只需要保存被调用者保存寄存器
struct context
{
    uintptr_t ra;
    uintptr_t sp;
    uintptr_t s0;
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

/**
 * @brief 进程名称的最大长度
 */
#define PROC_NAME_LEN 15

/**
 * @brief 最大进程数量
 */
#define MAX_PROCESS 4096

/**
 * @brief 最大进程ID
 */
#define MAX_PID (MAX_PROCESS * 2)

extern list_entry_t proc_list; // 所有进程控制块的双向线性列表，proc_struct中的成员变量list_link将链接入这个链表中。

// 进程结构体
struct proc_struct
{
    /**
     * 枚举类型，表示进程所处的状态。uCore中进程状态有四种：
     * - PROC_UNINIT: 进程未初始化状态，表示进程还未被创建或初始化。
     * - PROC_SLEEPING: 进程睡眠状态，表示进程正在等待某个事件的发生。
     * - PROC_RUNNABLE: 进程可运行状态，表示进程已经准备好运行，但还未被调度执行。
     * - PROC_ZOMBIE: 进程僵尸状态，表示进程已经执行完毕，但其父进程还未对其进行善后处理。
     */
    enum proc_state state;        // 进程状态，进程所处的状态。uCore中进程状态有四种：分别是PROC_UNINIT、PROC_SLEEPING、PROC_RUNNABLE、PROC_ZOMBIE。
    int pid;                      // 进程ID
    int runs;                     // 运行次数
    uintptr_t kstack;             // 进程内核栈，kstack 是中断发生后切换到的栈，用于处理内核逻辑。，内核栈不受mm管理，是直接在内核空间分配的。
    volatile bool need_resched;   // 是否需要重新调度释放CPU？
    struct proc_struct *parent;   // 父进程
    struct mm_struct *mm;         // 进程的内存管理字段，里面保存了内存管理的信息，包括内存映射，虚存管理等内容。
    struct context context;       // 切换到此处以运行进程，context中保存了进程执行的上下文，也就是几个关键的寄存器的值。
    struct trapframe *tf;         // 中断帧，用于保存当前进程中断发生时的寄存器状态。
    uintptr_t cr3;                // CR3寄存器：页目录表（PDT）的基地址
    uint32_t flags;               // 进程标志
    char name[PROC_NAME_LEN + 1]; // 进程名称
    list_entry_t list_link;       // 进程链表链接
    list_entry_t hash_link;       // 进程哈希链表链接
};

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

// static struct proc *current：当前占用CPU且处于“运行”状态进程控制块指针。
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

#endif /* !__KERN_PROCESS_PROC_H__ */
