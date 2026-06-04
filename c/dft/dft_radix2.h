#include <stddef.h>

#include "structs.h"
void dft_radix2(num_t* _x_re, num_t* _x_im, size_t N, num_t* xr, num_t* xi);
void dft_radix2_single_loop(
    num_t* _x_re, num_t* _x_im, size_t N, num_t* xr, num_t* xi
);