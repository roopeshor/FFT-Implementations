#include <chrono>
#include <iomanip>
#include <iostream>
#include <vector>

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

typedef std::chrono::_V2::system_clock::time_point time_point_t;
typedef std::chrono::duration<double, std::milli> elapsed_t;
typedef std::chrono::_V2::system_clock::rep elapsed_diff_t;

size_t N = 1 << 16;
size_t N1 = 1 << 8;
size_t N2 = 1 << 8;

const size_t algos = 4;
size_t algo_idx = 0;
uint64_t start_cycle, end_cycle;
time_point_t start_time, end_time;

std::string algo_names[algos];

template <typename T>
void printCell(T t, const int& width, char sep = ' ') {
  std::cout << std::left << std::setw(width) << std::setfill(sep) << t;
}

const int C1W = 40, C2W = 20, C3W = 15, C4W = 18, C5W = 15;
void show_res_head() {
  printCell("Algo", C1W);
  printCell("Exec Time (ns)", C2W);
  printCell("CPU Cycles", C3W);
  printCell("Cycles/Element", C4W);
  printCell("ns/Cycle", C5W);
  std::cout << "\n";
  printCell("", C1W + C2W + C3W + C4W + C5W, '-');
  std::cout << "\n";
}

void show_res(std::string algo, uint64_t times, uint64_t cycles) {
  printCell(algo, C1W);
  printCell(std::to_string(times), C2W);
  printCell(std::to_string(cycles), C3W);
  printCell(std::to_string((double)(cycles) / N), C4W);
  printCell(std::to_string((double)(cycles / times)), C5W);
  std::cout << "\n";
}

void show_res(std::string algo) {
  show_res(algo, (end_time - start_time).count(), end_cycle - start_cycle);
}

int main() {
  std::vector<num_t> x_re(N, 1.0f), x_im(N, 0.0f);
  std::vector<num_t> X_re(N, 0.0f), X_im(N, 0.0f);

  unsigned int aux;

  show_res_head();
  // start_time = std::chrono::high_resolution_clock::now();
  // start_cycle = __rdtscp(&aux);
  // dft(x_re.data(), x_im.data(), N, X_re.data(), X_im.data());
  // end_cycle = __rdtscp(&aux);
  // end_time = std::chrono::high_resolution_clock::now();

  // show_res("DFT_Usual");
  uint64_t times = 0, cycles = 0;
  const int TESTS = 15;
  for (int i = 0; i < TESTS; i++) {
    start_time = std::chrono::high_resolution_clock::now();
    start_cycle = __rdtscp(&aux);
    dft_radix2_single_loop(
        x_re.data(),
        x_im.data(),
        N,
        X_re.data(),
        X_im.data()
    );
    end_cycle = __rdtscp(&aux);
    end_time = std::chrono::high_resolution_clock::now();
    times += (end_time - start_time).count();
    cycles += (end_cycle - start_cycle);
  }

  show_res("dft_radix2_single_loop (15 avg)", times / TESTS, cycles / TESTS);

  times = 0;
  cycles = 0;
  for (int i = 0; i < TESTS; i++) {
    start_time = std::chrono::high_resolution_clock::now();
    start_cycle = __rdtscp(&aux);
    dft_radix2(x_re.data(), x_im.data(), N, X_re.data(), X_im.data());
    end_cycle = __rdtscp(&aux);
    end_time = std::chrono::high_resolution_clock::now();
    times += (end_time - start_time).count();
    cycles += (end_cycle - start_cycle);
  }
  show_res("DFT_radix2", times / TESTS, cycles / TESTS);

  // start_time = std::chrono::high_resolution_clock::now();
  // start_cycle = __rdtscp(&aux);
  // dft_CT(x_re.data(), x_im.data(), N1, N2, X_re.data(), X_im.data());
  // end_cycle = __rdtscp(&aux);
  // end_time = std::chrono::high_resolution_clock::now();

  // show_res("dft_CT");
  return 0;
}