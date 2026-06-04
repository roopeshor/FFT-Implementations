#include <stddef.h>
#include <stdint.h>
#include "structs.h"

#ifndef UTILS_H
#define UTILS_H

#define PI 3.14159265358979323

void print_arr(num_t* arr, size_t N, char sep);

size_t bit_reverse(size_t num, uint8_t N);

void rearrange_bit_reverse(num_t* src, num_t* dest, size_t N, uint8_t exp);

void complexMulAdd(
    num_t Ar, num_t Ai, num_t Br, num_t Bi, num_t Cr, num_t Ci, num_t* Dr,
    num_t* Di
);

void complexMulAddAcc(
    num_t Ar, num_t Ai, num_t Br, num_t Bi, num_t Cr, num_t Ci, num_t* Dr,
    num_t* Di
);

void complexMulAcc(
    num_t Ar, num_t Ai, num_t Br, num_t Bi, num_t* Cr, num_t* Ci
);

void complexMulSelf(num_t* Ar, num_t* Ai, num_t Br, num_t Bi);
num_t WNk_re(num_t k, num_t N);
num_t WNk_im(num_t k, num_t N);

#endif