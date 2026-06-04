#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "dft/dft_CT.h"
#include "dft/dft_radix2.h"
#include "dft/dft_usual.h"
#include "dft/utils.h"

// Architecture-specific header for cycle counting
#if defined(_MSC_VER)
#include <intrin.h>
#elif defined(__i386__) || defined(__x86_64__)
#include <x86intrin.h>
#endif

size_t N = 1 << 16;
size_t N1 = 1 << 8;
size_t N2 = 1 << 8;

const size_t algos = 4;
size_t algo_idx = 0;
uint64_t start_cycle, end_cycle;
struct timespec start_time, end_time;

const char* algo_names[4];

void printCell(const char* t, int width, char sep) {
  if (sep == ' ') {
    printf("%-*s", width, t);
  } else {
    int len = strlen(t);
    printf("%s", t);
    for (int i = len; i < width; i++) putchar(sep);
  }
}

const int C1W = 40, C2W = 20, C3W = 15, C4W = 18, C5W = 15;
void show_res_head() {
  printCell("Algo", C1W, ' ');
  printCell("Exec Time (ns)", C2W, ' ');
  printCell("CPU Cycles", C3W, ' ');
  printCell("Cycles/Element", C4W, ' ');
  printCell("ns/Cycle", C5W, ' ');
  printf("\n");
  printCell("", C1W + C2W + C3W + C4W + C5W, '-');
  printf("\n");
}

void show_res(const char* algo, uint64_t times, uint64_t cycles) {
  char buf[64];
  
  printCell(algo, C1W, ' ');
  snprintf(buf, sizeof(buf), "%llu", (unsigned long long)times);
  printCell(buf, C2W, ' ');
  snprintf(buf, sizeof(buf), "%llu", (unsigned long long)cycles);
  printCell(buf, C3W, ' ');
  snprintf(buf, sizeof(buf), "%f", (double)(cycles) / N);
  printCell(buf, C4W, ' ');
  snprintf(buf, sizeof(buf), "%f", (double)(cycles) / (times ? times : 1));
  printCell(buf, C5W, ' ');
  printf("\n");
}

uint64_t diff_ns(struct timespec start, struct timespec end) {
  return (end.tv_sec - start.tv_sec) * 1000000000ULL + (end.tv_nsec - start.tv_nsec);
}

int main() {
  num_t* x_re = (num_t*)malloc(N * sizeof(num_t));
  num_t* x_im = (num_t*)malloc(N * sizeof(num_t));
  num_t* X_re = (num_t*)malloc(N * sizeof(num_t));
  num_t* X_im = (num_t*)malloc(N * sizeof(num_t));

  for (size_t i = 0; i < N; i++) {
    x_re[i] = 1.0;
    x_im[i] = 0.0;
    X_re[i] = 0.0;
    X_im[i] = 0.0;
  }

  unsigned int aux;

  show_res_head();

  uint64_t times = 0, cycles = 0;
  const int TESTS = 15;
  for (int i = 0; i < TESTS; i++) {
    clock_gettime(CLOCK_MONOTONIC, &start_time);
    start_cycle = __rdtscp(&aux);
    dft_radix2_single_loop(
        x_re,
        x_im,
        N,
        X_re,
        X_im
    );
    end_cycle = __rdtscp(&aux);
    clock_gettime(CLOCK_MONOTONIC, &end_time);
    times += diff_ns(start_time, end_time);
    cycles += (end_cycle - start_cycle);
  }

  show_res("dft_radix2_single_loop (15 avg)", times / TESTS, cycles / TESTS);

  times = 0;
  cycles = 0;
  for (int i = 0; i < TESTS; i++) {
    clock_gettime(CLOCK_MONOTONIC, &start_time);
    start_cycle = __rdtscp(&aux);
    dft_radix2(x_re, x_im, N, X_re, X_im);
    end_cycle = __rdtscp(&aux);
    clock_gettime(CLOCK_MONOTONIC, &end_time);
    times += diff_ns(start_time, end_time);
    cycles += (end_cycle - start_cycle);
  }
  show_res("DFT_radix2", times / TESTS, cycles / TESTS);

  free(x_re);
  free(x_im);
  free(X_re);
  free(X_im);

  return 0;
}