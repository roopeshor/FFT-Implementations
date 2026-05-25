#include <math.h>

#include <cstdint>

#include "utils.cpp"
#pragma once
/**
 * Iterative FFT radix 2
 * @param xr pointer to input array of real part
 * @param xi pointer to input array of imaginary part
 * @param N size of array, expects
 * @param X_re pointer to output real part
 * @param X_im pointer to output imaginary part
 */
void dft_radix2(float* _x_re, float* _x_im, size_t N, float* xr, float* xi) {
  uint16_t bits = std::ceil(std::log2(N));
  rearrange_bit_reverse(_x_re, xr, N, bits);
  rearrange_bit_reverse(_x_im, xi, N, bits);

  float wr;  // ℜ(exp(-2πjn/N))
  float wi;  // ℑ(exp(-2πjn/N))
  float xra, xia, xrb, xib;
  /**
   * size of each butterfly group
   * N/k in k-pt sub DFt
   */
  size_t groupSize = 2;
  size_t groupOperations = 1;  // number of butterfly in a group
  size_t idxTop;               // index of top part
  size_t idxBottom;            // index of bottom part

  // stage: 2pt, 4pt, 8pt dft
  for (uint8_t stage = 0; stage < bits; stage++) {
    // group -> group of butterfly
    for (size_t startIndex = 0; startIndex < N; startIndex += groupSize) {
      for (size_t j = 0; j < groupOperations; j++) {
        idxTop = startIndex + j;
        idxBottom = idxTop + groupOperations;

        wr = std::cos(2 * PI * j / ((float)groupSize));
        wi = -std::sin(2 * PI * j / ((float)groupSize));

        // clang-format off
        complexMulAdd(
            xr[idxTop]   , xi[idxTop],
            wr           , wi,
            xr[idxBottom], xi[idxBottom],
            &xra         , &xia
        );
        complexMulAdd(
            xr[idxTop]   , xi[idxTop],
            -wr          , -wi,
            xr[idxBottom], xi[idxBottom],
            &xrb         , &xib
        );
        // clang-format on
        xr[idxTop] = xra;
        xi[idxTop] = xia;
        xr[idxBottom] = xrb;
        xi[idxBottom] = xib;
      }
    }
    groupSize *= 2;
    groupOperations *= 2;
  }
}

/**
 * Iterative FFT radix 2, but uses bitwise operation for indexing
 * @param xr pointer to input array of real part
 * @param xi pointer to input array of imaginary part
 * @param N size of array, expects
 * @param X_re pointer to output real part
 * @param X_im pointer to output imaginary part
 */
void dft_radix2_single_loop(float* _x_re, float* _x_im, size_t N, float* xr, float* xi) {
  uint16_t bits = std::ceil(std::log2(N));
  rearrange_bit_reverse(_x_re, xr, N, bits);
  rearrange_bit_reverse(_x_im, xi, N, bits);

  float wr;  // ℜ(exp(-2πjn/N))
  float wi;  // ℑ(exp(-2πjn/N))
  float xra, xia, xrb, xib;
  size_t groupOperations = 1;  // number of butterfly in a group
  size_t idxTop;               // index of top part
  size_t idxBottom;            // index of bottom part
  size_t j, mask;
  // stage: 2pt, 4pt, 8pt dft
  for (uint8_t stage = 0; stage < bits; stage++) {
    mask = (1 << stage) - 1;
    for (size_t i = 0; i < N/2; i++) {
        idxTop = ((i & ~mask) << 1) | (i & mask);
        j = (i & mask) << (bits - 1 - stage);;
        idxBottom = idxTop + groupOperations;
        
        wr = std::cos(2 * PI * j / ((float)N));
        wi = -std::sin(2 * PI * j / ((float)N));
        // clang-format off
        complexMulAdd(
            xr[idxTop]   , xi[idxTop],
            wr           , wi,
            xr[idxBottom], xi[idxBottom],
            &xra         , &xia
        );
        complexMulAdd(
            xr[idxTop]   , xi[idxTop],
            -wr          , -wi,
            xr[idxBottom], xi[idxBottom],
            &xrb         , &xib
        );
        // clang-format on
        xr[idxTop] = xra;
        xi[idxTop] = xia;
        xr[idxBottom] = xrb;
        xi[idxBottom] = xib;
    }
    groupOperations *= 2;
  }
}