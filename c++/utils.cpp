#include <cstdint>
#include <iostream>
#pragma once
const float PI = 3.14159265358979323;

/**
 * Prints elements of array of size N, with given separator
 * @param arr Input array
 * @param N array size
 * @param sep separator
 */
template <typename T>
void print_arr(T* arr, size_t N, char sep = ',') {
  for (size_t i = 0; i < N; i++) {
    std::cout << arr[i] << ",";
  }
  std::cout << std::endl;
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
template <typename T>
void rearrange_bit_reverse(T* src, T* dest, size_t N, uint8_t exp) {
  for (size_t i = 0; i < N; i++) {
    dest[bit_reverse(i, exp)] = src[i];
  }
}

/**
 * computes:
 *
 * ```txt
 *     D       = A + B * C
 *             = (Ar + j*Ai) + (Br + j*Bi)(Cr + j*Ci)
 * (Dr + j*Di) = (Ar + Br*Cr - Bi*Ci) + j(Ai + Br*Ci + Bi*Cr)
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
inline void complexMulAdd(
    float Ar, float Ai, float Br, float Bi, float Cr, float Ci, float* Dr,
    float* Di
) {
  *Dr = Ar + Br * Cr - Bi * Ci;
  *Di = Ai + Br * Ci + Bi * Cr;
}
/**
 * Does multiplication of 2 numbers, adds another number and add result to
 * another variable:
 * ```txt
 *     D       += A + B * C
 *             += (Ar + j*Ai) + (Br + j*Bi)(Cr + j*Ci)
 * (Dr + j*Di) += (Ar + Br*Cr - Bi*Ci) + j(Ai + Br*Ci + Bi*Cr)
 * ```
 * @param Ar input real
 * @param Ai input imaginary
 * @param Br input real
 * @param Bi input imaginary
 * @param Cr input real
 * @param Ci input imaginary
 * @param Dr real part of output written to this mem space
 * @param Di imag part of output written to this mem space
 */
inline void complexMulAddAcc(
    float Ar, float Ai, float Br, float Bi, float Cr, float Ci, float* Dr,
    float* Di
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
inline void complexMulAcc(
    float Ar, float Ai, float Br, float Bi, float* Cr, float* Ci
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
inline void complexMulSelf(float* Ar, float* Ai, float Br, float Bi) {
  float _Ar = *Ar * Br - *Ai * Bi;
  *Ai = *Ar * Bi + *Ai * Br;
  *Ar = _Ar;
}

inline float WNk_re(float k, float N) { return std::cos(2 * PI * k / N); }
inline float WNk_im(float k, float N) { return -std::sin(2 * PI * k / N); }
