#include "dft_usual.cpp"
#include "utils.cpp"
#pragma once
/**
 * Iterative Cooley Tukey FFT
 * @param xr pointer to input array of real part
 * @param xi pointer to input array of imaginary part
 * @param N1 size factor 1
 * @param N2 size factor 2
 * @param X_re pointer to array of output real part
 * @param X_im pointer to array of output imaginaby part
 */
void dft_CT(
    float* x_re, float* x_im, const size_t N1, const size_t N2, float* X_re,
    float* X_im
) {
  /**
   * N = N1*N2
   * X[k] = FFT{x(n)}
   * k = N2*a + b
   * n = N1*i + j
   * i,b ∈ 0..N2-1
   * j,a ∈ 0..N1-1
   *
   */

  float colDFT_re[N2 * N1];
  float colDFT_im[N2 * N1];
  float rowDFT_re[N1 * N2];
  float rowDFT_im[N1 * N2];

  /**
   * find DFT along columns:
   */
  for (size_t j = 0; j < N1; j++) {
    // for (size_t i = 0; i < N2; i++) {
    //   col_re[i] = x_re[N1 * i + j];
    //   col_im[i] = x_im[N1 * i + j];
    // }
    dft_input_reindexed(
        x_re,
        x_im,
        N2,
        colDFT_re + j * N2,
        colDFT_im + j * N2,
        N1,
        j
    );
  }
  // mul by twiddle:
  // WN^(bj)
  size_t bj;
  for (size_t j = 0; j < N1; j++) {
    for (size_t b = 0; b < N2; b++) {
      bj = j * N2 + b;
      complexMulSelf(
          colDFT_re + bj,
          colDFT_im + bj,
          WNk_re(b * j, N1 * N2),
          WNk_im(b * j, N1 * N2)
      );
    }
  }

  /**
   * find DFT along rows:
   */
  for (size_t i = 0; i < N2; i++) {
    // for (size_t j = 0; j < N1; j++) {
    //   row_re[j] = colDFT_re[N2 * j + i];
    //   row_im[j] = colDFT_im[N2 * j + i];
    // }
    dft_input_reindexed(
        colDFT_re,
        colDFT_im,
        N1,
        rowDFT_re + i * N1,
        rowDFT_im + i * N1,
        N2,
        i
    );
  }

  /**
   * reshape:
   * k = N2*a + b
   * n = N1*i + j
   * i,b ∈ 0..N2-1
   * j,a ∈ 0..N1-1
   */
  size_t k;
  size_t n;
  for (size_t a = 0; a < N2; a++) {
    for (size_t b = 0; b < N1; b++) {
      k = N2 * b + a;
      n = N1 * a + b;
      X_re[k] = rowDFT_re[n];
      X_im[k] = rowDFT_im[n];
    }
  }
}