#ifndef __LIBS_UNISTD_H__
#define __LIBS_UNISTD_H__
// 这个常量可能用于标识系统调用相关的中断。
#define T_SYSCALL 0x80

/* syscall number */
// 退出当前进程并返回给父进程一个退出状态。
#define SYS_exit 1
// 创建一个新进程（子进程），子进程是当前进程的副本。
#define SYS_fork 2
// 当前进程等待一个子进程结束，并返回其退出状态。
#define SYS_wait 3
// 加载并执行一个新的程序，替换当前进程的映像。
#define SYS_exec 4
// 创建一个新进程，但与 fork 的行为略有不同，通常用于创建线程等。
#define SYS_clone 5
// 使当前进程主动放弃 CPU 使用权，进行调度，允许其他进程运行。
#define SYS_yield 10
// 使当前进程休眠一段时间。
#define SYS_sleep 11
//
#define SYS_kill 12
// 获取当前系统时间。
#define SYS_gettime 17
// 获取当前进程的进程 ID。
#define SYS_getpid 18

// 设置进程的数据段结束位置，用于扩展或缩小进程的堆内存。
#define SYS_brk 19
// 内存映射文件或设备，通常用于进程之间共享内存或对文件进行内存映射。
#define SYS_mmap 20
// 解除内存映射，释放通过 mmap 映射的内存区域。
#define SYS_munmap 21
// 操作共享内存，通常用于不同进程之间的内存共享。
#define SYS_shmem 22
// 输出一个字符到终端或控制台。
#define SYS_putc 30
// 获取或操作页目录，通常用于虚拟内存管理。
#define SYS_pgdir 31

/* SYS_fork flags */
/*
CLONE_VM 和 CLONE_THREAD 常量，
它们通常用于系统调用 clone 中，指示新创建的进程（或线程）如何共享资源（如虚拟内存和线程组等）。
*/
// 如果设置了 CLONE_VM，则新创建的进程与父进程共享虚拟内存空间。
#define CLONE_VM 0x00000100 // set if VM shared between processes
// 如果设置了 CLONE_THREAD，则新创建的进程会与父进程共享线程组。
#define CLONE_THREAD 0x00000200 // thread group

#endif /* !__LIBS_UNISTD_H__ */
