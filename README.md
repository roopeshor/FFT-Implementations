# FFT Implementations
Repository of Scalable (general N point) C++ and SystemVerilog implementations of various FFT algorithms

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
## SystemVerilog
- [ ]  Basic FFT
- [x]  [Radix - 2](systemverilog/fft_radix2.sv)
- [ ]  Mixed radix
- [ ]  Cooley Tukey
- [ ]  PFT/Good Thomas
- [ ]  Winograd
### Testing:
```bash
cd systemverilog
verilator --binary --timing --top-module tb_fft fft_radix2.sv tb_fft.sv
./obj_dir/Vtb_fft
```