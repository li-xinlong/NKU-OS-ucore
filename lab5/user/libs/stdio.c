#include <defs.h>
#include <stdio.h>
#include <syscall.h>

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
    sys_putc(c); // 系统调用，将字符 c 输出到控制台
    (*cnt)++;
}

/* *
 * vcprintf - format a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    return cnt;
}

/* *
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);           // // 初始化 va_list，指向 fmt 后面的第一个可变参数
    int cnt = vcprintf(fmt, ap); //// 调用 vcprintf 执行格式化输出
    va_end(ap);                  //// 结束 va_list 的使用

    return cnt;
}

/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
