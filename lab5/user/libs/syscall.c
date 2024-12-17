#include <defs.h>
#include <unistd.h>
#include <stdarg.h>
#include <syscall.h>

#define MAX_ARGS 5
// syscall 函数，它通过汇编语言实现了一个系统调用的机制。
/*
num：系统调用的编号（通常是操作系统内核定义的一个常量），它指定了调用的系统服务类型。例如，SYS_exit、SYS_fork 等。
后面的 ... 表示可变参数，可以传递多个参数，作为系统调用的输入。
*/
static inline int
syscall(int64_t num, ...)
{
    // va_list ap：用于访问可变参数的类型。
    va_list ap;
    // va_start(ap, num)：初始化 ap，以便在后续的代码中访问可变参数。
    va_start(ap, num);
    // a[MAX_ARGS]：一个数组，用来存储从可变参数列表中读取的系统调用参数。MAX_ARGS 是系统调用最大参数的个数。
    uint64_t a[MAX_ARGS];
    // ret：用于存储系统调用的返回值。
    int i, ret;
    for (i = 0; i < MAX_ARGS; i++)
    {
        // //把参数依次取出来
        a[i] = va_arg(ap, uint64_t);
    }
    va_end(ap);

    asm volatile(
        // 系统调用的参数加载到 RISC-V 寄存器 a0 到 a5 中。
        "ld a0, %1\n"
        "ld a1, %2\n"
        "ld a2, %3\n"
        "ld a3, %4\n"
        "ld a4, %5\n"
        "ld a5, %6\n"
        // 这条指令触发一个系统调用。它会导致程序从用户模式切换到内核模式，
        "ecall\n"
        // 将系统调用返回值从 a0 存储到 ret 变量中。ecall的返回值存到ret
        "sd a0, %0"
        : "=m"(ret) // 表示输出参数，将寄存器 a0 中的返回值存储到 ret 变量中。
        // 表示输入参数，分别将系统调用的编号和参数存储到指定的内存位置（即 num 和 a[]）中。
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        : "memory");
    //"memory" 是作为编译器的输出约束（output constraint）的一部分。它告诉编译器，在执行这段代码时，程序会修改内存的状态，因此编译器需要避免对内存进行不恰当的优化，特别是与寄存器相关的优化。
    return ret;
}
// 这个系统调用用于退出当前进程。
int sys_exit(int64_t error_code)
{
    return syscall(SYS_exit, error_code);
}
// 这个系统调用用于创建一个新的进程
int sys_fork(void)
{
    return syscall(SYS_fork);
}
// 等待子进程结束，并获取子进程的退出状态。
int sys_wait(int64_t pid, int *store)
{
    return syscall(SYS_wait, pid, store);
}
// 放弃当前 CPU 时间片，交给其他就绪进程。
int sys_yield(void)
{
    return syscall(SYS_yield);
}
// 向指定进程发送信号，通常用于终止进程。
int sys_kill(int64_t pid)
{
    return syscall(SYS_kill, pid);
}
// 获取当前进程的 PID。
int sys_getpid(void)
{
    return syscall(SYS_getpid);
}
// 向控制台输出一个字符。
int sys_putc(int64_t c)
{
    return syscall(SYS_putc, c);
}
// 获取当前进程的页目录（page directory）。
int sys_pgdir(void)
{
    return syscall(SYS_pgdir);
}
