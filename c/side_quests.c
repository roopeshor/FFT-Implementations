#include "side_quests.h"
/**
 * Reverses bit order of given number of with given number of bits
 * Time: ~11.1s for 6553610000 numbers in g++
 * @param num number to reverse
 * @param N number of bits in the number
 */
size_t bit_reverse(size_t num, int N) {
  size_t _n = 0;
  for (int i = 0; i < N && i < 64; i++) {
    _n = (_n << 1) + ((num >> i) % 2);
  }
  return _n;
}
/**
 * Reverses bit order of given number of with given number of bits
 * Time: ~6.6s for 6553610000 numbers in g++
 * @param num number to reverse
 * @param N number of bits in the number
 */

size_t bit_reverse_swar(size_t num, int N) {
  num = ((num & 0xAAAAAAAAAAAAAAAA) >> 1) | ((num & 0x5555555555555555) << 1);
  num = ((num & 0xCCCCCCCCCCCCCCCC) >> 2) | ((num & 0x3333333333333333) << 2);
  num = ((num & 0xF0F0F0F0F0F0F0F0) >> 4) | ((num & 0x0F0F0F0F0F0F0F0F) << 4);
  num = ((num & 0xFF00FF00FF00FF00) >> 8) | ((num & 0x00FF00FF00FF00FF) << 8);
  num = ((num & 0xFFFF0000FFFF0000) >> 16) | ((num & 0x0000FFFF0000FFFF) << 16);
  num = (num >> 32) | (num << 32);
  return num >> (64 - N);
}

/**
 * Reverses bit order of given number of with given number of bits
 * Time: ~3.9s for 6553610000 numbers in clang++
 * @param num number to reverse
 * @param N number of bits in the number
 */
size_t bit_reverse_intrinsic(size_t num, int N) {
  // Clang only feature
  size_t reversed = __builtin_bitreverse64(num);
  // Shift down to extract only the N bits we care about
  // (Note: behavior is undefined if N == 0, ensure N > 0)
  return reversed >> (64 - N);
}
