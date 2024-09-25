#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__
//防止头文件被重复包含。
#define PGSIZE          4096                    // bytes mapped by a page
#define PGSHIFT         12                      // log2(PGSIZE)
//定义了 PGSIZE，表示页的大小为 4096 字节（即 4KB）
//定义了 PGSHIFT，表示页大小的偏移量, 4KB 的页大小可以通过移位 12 位来表示。
#endif /* !__KERN_MM_MMU_H__ */
//结束 #ifndef 块
