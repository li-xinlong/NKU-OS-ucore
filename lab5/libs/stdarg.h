#ifndef __LIBS_STDARG_H__
#define __LIBS_STDARG_H__

/* compiler provides size of save area */
typedef __builtin_va_list va_list;
// 初始化 va_list 类型的变量 ap，并设置它指向函数参数列表的第一个可变参数。
#define va_start(ap, last) (__builtin_va_start(ap, last))
// 读取 va_list 中的下一个参数，并将其转换为指定的类型。
#define va_arg(ap, type) (__builtin_va_arg(ap, type))
// 清理 va_list 类型的变量 ap，释放其占用的资源。
#define va_end(ap) /*nothing*/

#endif /* !__LIBS_STDARG_H__ */
