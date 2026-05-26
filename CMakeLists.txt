cmake_minimum_required(VERSION 3.10)
project(DFT_System)

# Redirect all compiled executables to the /bin folder
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# C++ Executable
file(GLOB SOURCES "c++/dft/*.cpp")

# Create the executable using that list
add_executable(cpp_exec c++/main.cpp ${SOURCES})
target_compile_options(cpp_exec PRIVATE -Wall)

# C++ Benchmark
add_executable(cpp_bench c++/benchmark.cpp ${SOURCES})
target_compile_options(cpp_bench PRIVATE -Wall)

# Verilator (Requires manual output path in the command)
add_custom_target(sv
    COMMAND python3 systemverilog/twiddle_factor.py 16
    # Add -Mdir to tell Verilator where to put build files
    COMMAND verilator --binary --timing --top-module tb_fft --debug -Isystemverilog -Mdir ${CMAKE_BINARY_DIR}/bin/obj_dir -o ${CMAKE_BINARY_DIR}/bin/sv_exec systemverilog/fft_radix2.sv systemverilog/tb_fft.sv
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running Python script and Verilator build..."
)