#include <cstddef>
#include "structs.h"

#ifndef DFT_USUAL_H
#define DFT_USUAL_H
void dft(num_t* x_re, num_t* x_im, size_t N, num_t* X_re, num_t* X_im);
void dft_input_reindexed(
    num_t* x_re, num_t* x_im, size_t N, num_t* X_re, num_t* X_im,
    size_t skip = 1, size_t start = 0
);
#endif