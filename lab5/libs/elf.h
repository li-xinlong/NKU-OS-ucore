#ifndef __LIBS_ELF_H__
#define __LIBS_ELF_H__

#include <defs.h>

#define ELF_MAGIC 0x464C457FU // ELF魔数，即"\x7FELF"，它是用来标识一个文件是否是有效的 ELF 格式文件的特征标志。

/* 文件头 */
struct elfhdr
{
    uint32_t e_magic; // 必须等于ELF_MAGIC
    uint8_t e_elf[12];
    uint16_t e_type;      // 1=可重定位文件, 2=可执行文件, 3=共享对象, 4=核心映像
    uint16_t e_machine;   // 3=x86, 4=68K, 等等
    uint32_t e_version;   // 文件版本，始终为1
    uint64_t e_entry;     // 可执行文件的入口点
    uint64_t e_phoff;     // 程序头的文件位置或0
    uint64_t e_shoff;     // 节头的文件位置或0
    uint32_t e_flags;     // 架构特定的标志，通常为0
    uint16_t e_ehsize;    // ELF头的大小
    uint16_t e_phentsize; // 程序头中每个条目的大小
    uint16_t e_phnum;     // 程序头中的条目数或0
    uint16_t e_shentsize; // 节头中每个条目的大小
    uint16_t e_shnum;     // 节头中的条目数或0
    uint16_t e_shstrndx;  // 包含节名字符串的节号
};

/* program section header */
struct proghdr
{
    uint32_t p_type;   // loadable code or data, dynamic linking info,etc.
    uint32_t p_flags;  // read/write/execute bits
    uint64_t p_offset; // file offset of segment
    uint64_t p_va;     // virtual address to map segment
    uint64_t p_pa;     // physical address, not used
    uint64_t p_filesz; // size of segment in file
    uint64_t p_memsz;  // size of segment in memory (bigger if contains bss）
    uint64_t p_align;  // required alignment, invariably hardware page size
};

/* values for Proghdr::p_type */
#define ELF_PT_LOAD 1

/* flag bits for Proghdr::p_flags */
#define ELF_PF_X 1
#define ELF_PF_W 2
#define ELF_PF_R 4

#endif /* !__LIBS_ELF_H__ */
