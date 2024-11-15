#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>

// pre define
struct mm_struct;

// the virtual continuous memory area(vma), [vm_start, vm_end),
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end
struct vma_struct
{
    // 进程的内存管理结构
    struct mm_struct *vm_mm; // the set of vma using the same PDT
    // VMA 起始地址
    uintptr_t vm_start; // start addr of vma
    // VMA 结束地址（不包括该地址）
    uintptr_t vm_end; // end addr of vma, not include the vm_end itself
    // VMA 的标志（如读写权限）
    uint_t vm_flags; // flags of vma
    // 链表链接，用于将 VMA 排序和连接
    list_entry_t list_link; // linear list link which sorted by start addr of vma
};
// 这个宏用于在链表中遍历虚拟内存区域（VMA）时，将链表节点（list_entry_t）转化为对应的 VMA 结构，以便访问其中的字段。
#define le2vma(le, member) \
    to_struct((le), struct vma_struct, member)

#define VM_READ 0x00000001
#define VM_WRITE 0x00000002
#define VM_EXEC 0x00000004

// the control struct for a set of vma using the same PDT
// mm_struct是进程的内存管理结构，用于管理进程的虚拟内存空间
struct mm_struct
{
    // 一个线性链表（通常通过 list_entry_t 类型来实现），用于存储与进程相关的所有 虚拟内存区域（VMA）
    list_entry_t mmap_list; // linear list link which sorted by start addr of vma
    // 存储当前访问的 虚拟内存区域（VMA） 的指针
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose
    // 进程的 页目录（Page Directory） 的指针。每个进程都可以有一个独立的页目录，存储该进程的虚拟地址到物理地址的映射。
    pde_t *pgdir; // the PDT of these vma
    // 记录了进程的虚拟内存区域（VMA）的数量。
    int map_count; // the count of these vma
    // 一个指向私有数据的指针，通常用于存储与 交换管理（swap manager） 相关的数据。
    void *sm_priv; // the private data for swap manager
};

struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void vmm_init(void);

int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

#endif /* !__KERN_MM_VMM_H__ */
