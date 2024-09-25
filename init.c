#include <clock.h>
#include <console.h>
#include <defs.h>
#include <intr.h>
#include <kdebug.h>
#include <kmonitor.h>
#include <pmm.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>

// 测试断点异常的函数
void test_breakpoint() {
    asm volatile("ebreak"); // 这将产生一个断点异常
}

void test_illegal_instruction() {
    // 使用一个无效的操作码来触发非法指令异常
    // 这里的 0x0067a023 是一个示例操作码，它不是任何有效的 RISC-V 指令
    asm volatile(".4byte 0x1117a023");
}


int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    cons_init();  // init the console

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);

    print_kerninfo();

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    // 初始化完成后，调用测试函数
    cprintf("Testing breakpoint exception... ");
    test_breakpoint(); // 这将触发断点异常

    cprintf("Testing illegal instruction exception... ");
    test_illegal_instruction(); // 这将触发非法指令异常

    // 由于这些函数会触发异常，正常情况下代码不会执行到这里
    // 如果异常处理正常工作，控制权会在异常处理后返回到这里
    cprintf("This should not be reached.n");
    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt

    intr_enable();  // enable irq interrupt



    while (1)
        ;
}

void __attribute__((noinline))
grade_backtrace2(unsigned long long arg0, unsigned long long arg1, unsigned long long arg2, unsigned long long arg3) {
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline)) grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (unsigned long long)&arg0, arg1, (unsigned long long)&arg1);
}

void __attribute__((noinline)) grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void grade_backtrace(void) { grade_backtrace0(0, (unsigned long long)kern_init, 0xffff0000); }

static void lab1_print_cur_status(void) {
    static int round = 0;
    round++;
}



