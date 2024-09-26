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

int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
void test_breakpoint() {
    asm volatile("ebreak"); // 这将产生一个断点异常
}

void test_illegal_instruction() {
    asm volatile(".4byte 0x80200053");
    asm volatile ("mret");
    //asm volatile ("sret");
}

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
    cprintf("断点异常测试开始\n ");
    test_breakpoint(); // 这将触发断点异常

    cprintf("非法指令异常测试开始\n ");
    test_illegal_instruction(); // 这将触发非法指令异常
    
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



