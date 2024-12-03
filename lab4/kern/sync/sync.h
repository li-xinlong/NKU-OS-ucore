#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>

// 关闭中断

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
    {
        intr_disable();
        return 1;
    }
    return 0;
}

/**
 * 根据给定的标志位恢复中断状态。
 *
 * @param flag - 表示保存前中断是否已启用的标志位。
 */
static inline void __intr_restore(bool flag)
{
    if (flag)
    {
        intr_enable();
    }
}

/**
 * 保存中断状态并将其赋值给变量 `x`。
 *
 * 此宏用于将中断状态保存在变量 `x` 中。它通常在同步代码中用于临时禁用中断。
 *
 * @param x 用于保存中断状态的变量
 */
// do { ... } while (0) 是一种常见的宏设计模式，目的是增强宏的安全性和可用性，例如在允许在单行代码后安全加分号
#define local_intr_save(x) \
    do                     \
    {                      \
        x = __intr_save(); \
    } while (0)

/**
 * 根据给定的变量恢复中断状态。
 *
 * @param x - 表示保存前中断是否已启用的变量。
 */
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
