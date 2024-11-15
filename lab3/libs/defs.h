#ifndef __LIBS_DEFS_H__
#define __LIBS_DEFS_H__

#ifndef NULL
#define NULL ((void *)0)
#endif

#define __always_inline inline __attribute__((always_inline))
#define __noinline __attribute__((noinline))
#define __noreturn __attribute__((noreturn))

/* Represents true-or-false values */
typedef int bool;

#define true (1)
#define false (0)

/* Explicitly-sized versions of integer types */
typedef char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;

/* *
 * Pointers and addresses are 32 bits or 64 bits.
 * We use pointer types to represent addresses,
 * uintptr_t to represent the numerical values of addresses.
 * */
#if __riscv_xlen == 64
typedef int64_t sint_t;
typedef uint64_t uint_t;
#elif __riscv_xlen == 32
typedef int32_t sint_t;
typedef uint32_t uint_t;
#endif
typedef sint_t intptr_t;
typedef uint_t uintptr_t;

/* size_t is used for memory object sizes */
typedef uintptr_t size_t;

/* used for page numbers */
typedef size_t ppn_t;

/* *
 * Rounding operations (efficient when n is a power of 2)
 * Round down to the nearest multiple of n
 * */
// ROUNDDOWN(a, n) 是一个宏，用于将给定的地址或数值 a 向下取到 n 的倍数。
#define ROUNDDOWN(a, n) ({      \
  size_t __a = (size_t)(a);     \
  (typeof(a))(__a - __a % (n)); \
})

/* Round up to the nearest multiple of n */
// ROUNDUP(a, n) 是一个宏，用于将给定的地址或数值 a 向上取到 n 的倍数。
#define ROUNDUP(a, n) ({                              \
  size_t __n = (size_t)(n);                           \
  (typeof(a))(ROUNDDOWN((size_t)(a) + __n - 1, __n)); \
})

/* Return the offset of 'member' relative to the beginning of a struct type */
// offsetof 宏的作用是 计算结构体成员相对于结构体起始地址的偏移量
#define offsetof(type, member) \
  ((size_t)(&((type *)0)->member))

/* *
 * to_struct - get the struct from a ptr
 * @ptr:    a struct pointer of member
 * @type:   the type of the struct this is embedded in
 * @member: the name of the member within the struct
 * */
/*
ptr：是指向结构体成员的指针，也就是结构体某个成员的地址。
type：是结构体的类型。
member：是结构体中的成员名，表示该成员在结构体中的位置。
*/
// to_struct 宏的作用是 将一个结构体成员的地址转换为包含该成员的结构体的指针。它通过计算结构体成员的偏移量，从而获得包含该成员的整个结构体的地址。
#define to_struct(ptr, type, member) \
  ((type *)((char *)(ptr) - offsetof(type, member)))

#endif /* !__LIBS_DEFS_H__ */
