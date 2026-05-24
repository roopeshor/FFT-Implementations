# FFT Implementations
Repository of C++ implementations of various FFT algorithms

## C++
- [x]  [Basic FFT](c++/dft_usual.cpp)
- [x]  [Radix - 2](c++/dft_radix2.cpp)
- [ ]  Mixed radix
- [x]  [Cooley Tukey](c++/dft_CT.cpp)
- [ ]  PFT/Good Thomas
- [ ]  Winograd
### Testing:
```bash
cd c++
clang++ -fsanitize=address -Wall main.cpp && ./a.out
```