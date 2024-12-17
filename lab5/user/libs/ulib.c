#include <defs.h>
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void exit(int error_code)
{
    sys_exit(error_code);
    // 执行完sys_exit后，按理说进程就结束了，后面的语句不应该再执行，
    // 所以执行到这里就说明exit失败了
    cprintf("BUG: exit failed.\n");
    while (1)
        ;
}

int fork(void)
{
    return sys_fork();
}

int wait(void)
{
    return sys_wait(0, NULL);
}

int waitpid(int pid, int *store)
{
    return sys_wait(pid, store);
}

void yield(void)
{
    sys_yield();
}

int kill(int pid)
{
    return sys_kill(pid);
}

int getpid(void)
{
    return sys_getpid();
}

// print_pgdir - print the PDT&PT
void print_pgdir(void)
{
    sys_pgdir();
}
