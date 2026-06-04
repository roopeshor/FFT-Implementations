#ifndef SIDE_QUESTS_H
#define SIDE_QUESTS_H

#include <stddef.h>

size_t bit_reverse(size_t num, int N);
size_t bit_reverse_swar(size_t num, int N);
size_t bit_reverse_intrinsic(size_t num, int N);

#endif