#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

// 初始化 IDE 设备
void ide_init(void) {}

// 定义最大支持的 IDE 设备数量
#define MAX_IDE 2
// 定义每个磁盘最大的扇区数量
#define MAX_DISK_NSECS 56
// 静态字符数组，用于模拟磁盘存储空间
static char ide[MAX_DISK_NSECS * SECTSIZE];

// 检查给定的 IDE 设备编号是否有效
bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }

// 返回给定 IDE 设备的大小（扇区数量）
size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }

// 从指定的 IDE 设备读取扇区数据到指定的缓冲区
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    // 计算读取数据的起始偏移量
    int iobase = secno * SECTSIZE;
    // 从模拟的磁盘存储空间中拷贝数据到目标缓冲区
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

// 将数据从指定的缓冲区写入到指定的 IDE 设备扇区
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    // 计算写入数据的起始偏移量
    int iobase = secno * SECTSIZE;
    // 将数据从源缓冲区拷贝到模拟的磁盘存储空间
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;
}
