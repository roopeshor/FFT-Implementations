#include <stdio.h>
#include <stdlib.h>
#include "dft/structs.h"
#include "dft/dft_CT.h"
#include "dft/dft_radix2.h"
#include "dft/dft_usual.h"

int main() {
  const size_t N1 = 4, N2 = 4;
  const size_t N = N1 * N2;

  /**Arrays */

  num_t* arr_re = (num_t*)malloc(N * sizeof(num_t));
  num_t* arr_im = (num_t*)malloc(N * sizeof(num_t));

  num_t* out_re = (num_t*)malloc(N * sizeof(num_t));
  num_t* out_im = (num_t*)malloc(N * sizeof(num_t));
  num_t* out_ct_re = (num_t*)malloc(N * sizeof(num_t));
  num_t* out_ct_im = (num_t*)malloc(N * sizeof(num_t));


  for (size_t i = 0; i < N; i++) {
    arr_re[i] = i;
    arr_im[i] = 0;
  }

  /** Implementations */
  dft(arr_re, arr_im, N, out_re, out_im); // for reference

  // pick the algorithm
  dft_radix2_single_loop(arr_re, arr_im, N, out_ct_re, out_ct_im);
  printf("Array: ");
  for (size_t i = 0; i < N; i++) {
    printf("\n%f%s%fi", arr_re[i], (arr_im[i] >= 0 ? " +" : " "), arr_im[i]);
  }

  printf("\nDFT(re)\tDFT_CT(re)\tDFT(im)\tDFT_CT(im)\n");
  for (size_t i = 0; i < N; i++) {
    printf("%.2f\t%.2f\t%.2f\t%.2f\n", out_re[i], out_ct_re[i], out_im[i], out_ct_im[i]);
  }
  free(arr_re);
  free(arr_im);
  free(out_re);
  free(out_im);
  free(out_ct_re);
  free(out_ct_im);
}
