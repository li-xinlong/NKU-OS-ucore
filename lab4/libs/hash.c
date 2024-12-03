#include <stdlib.h>

/* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
#define GOLDEN_RATIO_PRIME_32 0x9e370001UL
// 0x9e370001UL 是一个基于黄金分割比设计的特殊常数，被广泛用于计算哈希值。
/* *
 * hash32 - generate a hash value in the range [0, 2^@bits - 1]
 * @val:    the input value
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits)
{
    // 乘以黄金分割比常数，得到一个32位数
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
    return (hash >> (32 - bits));
    // 保留高10位
}
