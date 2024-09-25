#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__
//防止头文件被重复包含。
#define KSTACKPAGE          2                           // # of pages in kernel stack
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack
//定义 KSTACKPAGE，表示内核栈所占的页数为 2 页。
//定义 KSTACKSIZE，表示内核栈的大小为 KSTACKPAGE（2 页）乘以 PGSIZE（4KB），总共是 8192 字节（即 8KB）
#endif /* !__KERN_MM_MEMLAYOUT_H__ */

