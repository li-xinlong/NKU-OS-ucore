#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

/**
 * 将进程的状态更改为 PROC_RUNNABLE，唤醒一个进程。
 *
 * @param proc 要唤醒的进程。
 */
void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

/**
 * 调度函数
 */
void schedule(void)
{
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag); // 关闭中断
    {
        current->need_resched = 0;                                         // 当前进程不需要调度
        last = (current == idleproc) ? &proc_list : &(current->list_link); // 如果当前进程是空闲进程，则将last指向进程列表的头节点，否则将last指向当前进程的list_link成员
        le = last;                                                         // 将le指向last
        do
        {
            if ((le = list_next(le)) != &proc_list) // 如果le指向的下一个节点不是进程列表的头节点
            {
                next = le2proc(le, list_link);    // 将next指向le所在的进程结构体
                if (next->state == PROC_RUNNABLE) // 如果next的状态是可运行状态
                {
                    break; // 跳出循环
                }
            }
        } while (le != last); // 当le不等于last时循环
        if (next == NULL || next->state != PROC_RUNNABLE) // 如果next为空或者next的状态不是可运行状态
        {
            next = idleproc; // 将next指向空闲进程
        }
        next->runs++;        // next的运行次数加1
        if (next != current) // 如果next不等于当前进程
        {
            proc_run(next); // 运行next进程
        }
    }
    local_intr_restore(intr_flag); // 恢复中断
}
