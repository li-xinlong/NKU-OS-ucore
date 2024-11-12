#include <swap.h>
#include <swapfs.h>
#include <mmu.h>
#include <fs.h>
#include <ide.h>
#include <pmm.h>
#include <assert.h>

/**
 * @brief 初始化交换文件系统
 * 
 * 这个函数会检查交换设备是否有效，并计算出交换设备上最大的交换偏移量
 */
void
swapfs_init(void) {
    // 确保页面大小是扇区大小的整数倍
    static_assert((PGSIZE % SECTSIZE) == 0);
    // 如果交换设备无效，则panic
    if (!ide_device_valid(SWAP_DEV_NO)) {
        panic("swap fs isn't available.\n");
    }
    // 计算最大交换偏移量
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
}

/**
 * @brief 从交换文件系统中读取一个页面
 * 
 * @param entry 要读取的页面的索引
 * @param page 读取到的页面将存储在这个Page结构体中
 * @return 成功返回0，失败返回负值
 */
int
swapfs_read(swap_entry_t entry, struct Page *page) {
    // 从交换设备中读取数据
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

/**
 * @brief 将一个页面写入到交换文件系统中
 * 
 * @param entry 要写入的页面的索引
 * @param page 要写入的页面
 * @return 成功返回0，失败返回负值
 */
int
swapfs_write(swap_entry_t entry, struct Page *page) {
    // 将数据写入到交换设备中
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

