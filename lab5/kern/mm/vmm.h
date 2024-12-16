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
    struct mm_struct *vm_mm; // the set of vma using the same PDT
    uintptr_t vm_start;      // start addr of vma
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
    uint32_t vm_flags;       // flags of vma
    list_entry_t list_link;  // linear list link which sorted by start addr of vma
};

#define le2vma(le, member) \
    to_struct((le), struct vma_struct, member)

#define VM_READ 0x00000001
#define VM_WRITE 0x00000002
#define VM_EXEC 0x00000004
#define VM_STACK 0x00000008

// the control struct for a set of vma using the same PDT
struct mm_struct
{
    list_entry_t mmap_list;        // 这是一个线性链表（list_entry_t 是链表的结构类型），用于存储与进程虚拟内存区域（VMA）相关的信息。
    struct vma_struct *mmap_cache; // 指向当前访问的虚拟内存区域（VMA）的指针。
    pde_t *pgdir;                  // 指向进程的页目录（PDT）。在分页系统中，页目录用于映射进程的虚拟地址空间到物理内存。
    int map_count;                 // 记录进程中虚拟内存区域（VMA）的数量。
    void *sm_priv;                 // 指向交换管理器的私有数据。
    int mm_count;                  // 记录共享该内存管理结构（mm_struct）的进程数量。
    lock_t mm_lock;                //  一个锁（lock_t 类型），用于保护内存管理结构的并发访问。
};

struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void vmm_init(void);
int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store);
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr);

int mm_unmap(struct mm_struct *mm, uintptr_t addr, size_t len);
int dup_mmap(struct mm_struct *to, struct mm_struct *from);
void exit_mmap(struct mm_struct *mm);
uintptr_t get_unmapped_area(struct mm_struct *mm, size_t len);
int mm_brk(struct mm_struct *mm, uintptr_t addr, size_t len);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm)
{
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
    return mm->mm_count;
}

static inline int
mm_count_dec(struct mm_struct *mm)
{
    mm->mm_count -= 1;
    return mm->mm_count;
}

static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
    }
}

static inline void
unlock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        unlock(&(mm->mm_lock));
    }
}

#endif /* !__KERN_MM_VMM_H__ */
