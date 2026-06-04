#include <math.h>

#include "structs.h"
#include "utils.h"

/**
 * Usual DFT
 * @param x_re Pointer array of real part of input of size N
 * @param x_im Pointer array of imaginary part of input of size N
 * @param N size of array
 * @param X_re pointer to array of real part output of size N
 * @param X_im pointer to array of imaginary part output of size N
 */
void dft(num_t* x_re, num_t* x_im, size_t N, num_t* X_re, num_t* X_im) {
  for (size_t k = 0; k < N; k++) {
    X_re[k] = 0;
    X_im[k] = 0;
    for (size_t n = 0; n < N; n++) {
      complexMulAcc(
          x_re[n],
          x_im[n],
          WNk_re(k * n, N),
          WNk_im(k * n, N),
          X_re + k,
          X_im + k
      );
    }
  }
}

/**
 * Usual DFT but with input reindexed before computation
 * the Dft in CT requires column/row access, for that input has to be reindexed,
 * and have to be formed new array and passing onto function. Here the required
 * number is picked starting from `start` and spaced by `skip`. The output is
 * written onto continous space of size `N`
 *
 * Here
 * ```txt
 *            N-1
 *     X[k] =  ∑ x[n * skip + start] * W(k*n/N)
 *            n=0
 * ```
 * @param x_re Real part of Input array of size N
 * @param x_im Imaginary part of Input array of size N
 * @param N size of array
 * @param X_re pointer to output real part
 * @param X_im pointer to output imaginary part
 * @param skip skip distance
 * @param start starting positon of input
 */
void dft_input_reindexed(
    num_t* x_re, num_t* x_im, size_t N, num_t* X_re, num_t* X_im,
    size_t skip, size_t start
) {
  size_t np;
  for (size_t k = 0; k < N; k++) {
    X_re[k] = 0;
    X_im[k] = 0;
    for (size_t n = 0; n < N; n++) {
      np = n * skip + start;
      complexMulAcc(
          x_re[np],
          x_im[np],
          WNk_re(k * n, N),
          WNk_im(k * n, N),
          X_re + k,
          X_im + k
      );
    }
  }
}
