#ifndef __LIBS_ERROR_H__
#define __LIBS_ERROR_H__

/* kernel error codes -- keep in sync with list in lib/printfmt.c */
/*
这些宏定义是用于表示操作系统中不同类型的错误码，通常用于函数返回值或错误处理流程中，
指示发生了什么类型的错误。它们通常会在操作系统的内核代码中用于管理异常或错误情况。具体解释如下：
*/
// E_UNSPECIFIED (1): 未指定的错误或未知问题。用于表示一个没有明确描述的错误，或者是无法分类的通用错误。
#define E_UNSPECIFIED 1 // Unspecified or unknown problem
// E_BAD_PROC (2): 进程错误。表示某个进程不存在或以某种方式出错，通常发生在尝试操作一个无效的进程时。
#define E_BAD_PROC 2 // Process doesn't exist or otherwise
// E_INVAL (3): 无效参数错误。表示传递给函数的参数无效或不合适，通常在系统调用或函数检查参数时出现。
#define E_INVAL 3 // Invalid parameter
// E_NO_MEM (4): 内存不足错误。表示系统无法满足内存分配请求，通常由于系统内存资源耗尽或者无法提供足够的内存。
#define E_NO_MEM 4 // Request failed due to memory shortage
// E_NO_FREE_PROC (5): 无可用进程错误。表示尝试创建一个新的进程时，系统没有足够的资源来创建新进程，通常是因为达到了进程数的上限。
#define E_NO_FREE_PROC 5 // Attempt to create a new process beyond
// E_FAULT (6): 内存访问错误（内存故障）。通常指发生了非法内存访问或访问了没有映射的内存页（如页错误、段错误等）
#define E_FAULT 6 // Memory fault

/* the maximum allowed */
#define MAXERROR 6

#endif /* !__LIBS_ERROR_H__ */
