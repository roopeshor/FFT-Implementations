#include <math.h>

#include <stdint.h>
#include <stdio.h>

#include "structs.h"
#include "utils.h"

/**
 * Prints elements of array of size N, with given separator
 * @param arr Input array
 * @param N array size
 * @param sep separator
 */
void print_arr(num_t* arr, size_t N, char sep) {
  for (size_t i = 0; i < N; i++) {
    printf("%f%c", arr[i], sep);
  }
  printf("\n");
}

/**
 * Reverses bit order of given number of with given number of bits
 * Time: ~6.6s for 6553610000 numbers in g++
 * @param num number to reverse
 * @param N number of bits in the number
 */
size_t bit_reverse(size_t num, uint8_t N) {
  num = ((num & 0xAAAAAAAAAAAAAAAA) >> 1) | ((num & 0x5555555555555555) << 1);
  num = ((num & 0xCCCCCCCCCCCCCCCC) >> 2) | ((num & 0x3333333333333333) << 2);
  num = ((num & 0xF0F0F0F0F0F0F0F0) >> 4) | ((num & 0x0F0F0F0F0F0F0F0F) << 4);
  num = ((num & 0xFF00FF00FF00FF00) >> 8) | ((num & 0x00FF00FF00FF00FF) << 8);
  num = ((num & 0xFFFF0000FFFF0000) >> 16) | ((num & 0x0000FFFF0000FFFF) << 16);
  num = (num >> 32) | (num << 32);
  return num >> (64 - N);
}

/**
 *
 * rearranges elements in bit reversed fasion
 * @param N number of elements in array.
 * @param exp number of bits in size of array. < 255
 */
void rearrange_bit_reverse(num_t* src, num_t* dest, size_t N, uint8_t exp) {
  for (size_t i = 0; i < N; i++) {
    dest[bit_reverse(i, exp)] = src[i];
  }
}

/**
 * computes:
 *
 * ```txt
 *    D      = A + B * C
 *           = (Ar + j*Ai) + (Br + j*Bi)(Cr + j*Ci)
 * Dr + j*Di = (Ar + Br*Cr - Bi*Ci) + j(Ai + Br*Ci + Bi*Cr)
 *  ```
 * @param Ar input real
 * @param Ai input imaginary
 * @param Br input real
 * @param Bi input imaginary
 * @param Cr input real
 * @param Ci input imaginary
 * @param Dr real part of output written to this mem space
 * @param Di imag part of output written to this mem space
 */
void complexMulAdd(
    num_t Ar, num_t Ai, num_t Br, num_t Bi, num_t Cr, num_t Ci, num_t* Dr,
    num_t* Di
) {
  *Dr = Ar + Br * Cr - Bi * Ci;
  *Di = Ai + Br * Ci + Bi * Cr;
}
/**
 * Does multiplication of 2 numbers, adds another number and add result to
 * another variable:
 * ```txt
 *    D      += A + B * C
 *           += (Ar + j*Ai) + (Br + j*Bi)(Cr + j*Ci)
 * Dr + j*Di += (Ar + Br*Cr - Bi*Ci) + j(Ai + Br*Ci + Bi*Cr)
 * ```
 * @param Ar input real
 * @param Ai input imaginary
 * @param Br input real
 * @param Bi input imaginary
 * @param Cr input real
 * @param Ci input imaginary
 * @param Dr real part of output. Output written to this mem space
 * @param Di imag part of output. Output written to this mem space
 */
void complexMulAddAcc(
    num_t Ar, num_t Ai, num_t Br, num_t Bi, num_t Cr, num_t Ci, num_t* Dr,
    num_t* Di
) {
  *Dr += Ar + Br * Cr - Bi * Ci;
  *Di += Ai + Br * Ci + Bi * Cr;
}
/**
 * Does multiplication of 2 numbers and add result to another variable:
 * ```txt
 *    C      += A * B
 * Cr + j*Ci += (Ar + j*Ai)(Br + j*Bi)
 * Cr + j*Ci += (Ar*Br - Ai*Bi) + j(Ar*Bi + Ai*Br)
 * ```
 * @param Ar input real
 * @param Ai input imaginary
 * @param Br input real
 * @param Bi input imaginary
 * @param Cr real part of output written to this mem space
 * @param Ci imag part of output written to this mem space
 */
void complexMulAcc(
    num_t Ar, num_t Ai, num_t Br, num_t Bi, num_t* Cr, num_t* Ci
) {
  *Cr += Ar * Br - Ai * Bi;
  *Ci += Ar * Bi + Ai * Br;
}
/**
 * Multiplies a number with itself
 * ```txt
 *    A     = A * B
 * Ar + jAi = (Ar + jAi)(Br + jBi)
 * Ar + jAi = (Ar*Br - Ai*Bi) + j(Ar*Bi + Ai*Br)
 *  ```
 * @param Ar input real (output written to this mem spaces)
 * @param Ai input imaginary (output written to this mem spaces)
 * @param Br input real
 * @param Bi input imaginary
 */
void complexMulSelf(num_t* Ar, num_t* Ai, num_t Br, num_t Bi) {
  num_t _Ar = *Ar * Br - *Ai * Bi;
  *Ai = *Ar * Bi + *Ai * Br;
  *Ar = _Ar;
}

num_t WNk_re(num_t k, num_t N) { return cos(2 * PI * k / N); }
num_t WNk_im(num_t k, num_t N) { return -sin(2 * PI * k / N); }
