#include <iomanip>

#include "dft_CT.cpp"
#include "dft_radix2.cpp"

int main() {
  const size_t N1 = 4, N2 = 4;
  const size_t N = N1 * N2;

  float* arr_re = new float[N];
  float* arr_im = new float[N];

  float* out_re = new float[N];
  float* out_im = new float[N];
  float* out_ct_re = new float[N];
  float* out_ct_im = new float[N];
  for (int i = 0; i < N; i++) {
    arr_re[i] = i;
    arr_im[i] = 0;
  }
  dft(arr_re, arr_im, N, out_re, out_im);
  dft_CT(arr_re, arr_im, N1, N2, out_ct_re, out_ct_im);
  std::cout << "Array: ";
  for (int i = 0; i < N; i++) {
    std::cout << std::endl
              << arr_re[i] << (arr_im[i] >= 0 ? " +" : " ") << arr_im[i] << "i";
  }

  std::cout << std::fixed << std::setprecision(2);
  std::cout << "\n" << "DFT(re)\tDFT_CT(re)\tDFT(im)\tDFT_CT(im)\n";
  for (int i = 0; i < N; i++) {
    std::cout << out_re[i] << "\t" << out_ct_re[i] << "\t" << out_im[i] << "\t"
              << out_ct_im[i] << "\n";
  }
  delete[] arr_re;
  delete[] arr_im;
  delete[] out_re;
  delete[] out_im;
  delete[] out_ct_re;
  delete[] out_ct_im;
}
