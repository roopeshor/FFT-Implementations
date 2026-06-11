import math
import sys
import os
def err():
  print(
"""Usage: py twiddle_factor.py N [width Q_point]

if no width or Q_point is not given a floating point twiddle will be given.
eg: py twiddle_factor.py 16        # creates a floating point list
eg: py twiddle_factor.py 16 32 20  # creates a fixed point list
""")
  exit()

def generate_floating_point_twiddles(N):
    # only needs N/2 twiddle factors
    num_twiddles = N // 2

    index_bits = max(1, math.ceil(math.log2(num_twiddles)))
    fileContent = f"""`timescale 1ns / 1ps
module twiddle_factor #(
    parameter int BF_BITS = {index_bits}
) (
    input logic [BF_BITS-1:0] k,
    output complex_t w
);
  always_comb begin
    case (k)
"""
    for k in range(num_twiddles):
        # Calculate W_N^k = cos(2*pi*k/N) - j*sin(2*pi*k/N)
        real_part = math.cos(2 * math.pi * k / N)
        imag_part = -math.sin(2 * math.pi * k / N)

        if abs(real_part) < 1e-10:
            real_part = 0.0
        if abs(imag_part) < 1e-10:
            imag_part = 0.0

        idx_str = f"{index_bits}'d{k}"
        fileContent += f"      {idx_str}: w = '{{re: {real_part:>8.10f}, im: {imag_part:>8.10f}}};\n"
    fileContent += f"""      default: w = '{{re: 0.0, im: 0.0}};
    endcase
  end
endmodule
"""
    return fileContent


def generate_fixed_point_twiddles(N=16, width=16, q_frac=8):
    """
    Generates a SystemVerilog combinational ROM for fixed-point twiddle factors.

    Args:
        N (int): Total number of points in the FFT.
        width (int): The total bit-width of the SystemVerilog parameter (WIDTH).
        q_frac (int): The number of fractional bits in the Q-format.
    """
    # A Radix-2 FFT only needs N/2 twiddle factors
    num_twiddles = N // 2

    # Calculate the exact number of bits needed for the case statement index
    index_bits = max(1, math.ceil(math.log2(num_twiddles)))

    # The scaling multiplier for the Q-format (e.g., Q8.8 means multiply by 2^8)
    scale = 1 << q_frac

    fileContent = f"""`timescale 1ns / 1ps

module Twiddle_ROM #(
    parameter STAGES = {index_bits},
    parameter DW = {width}
) (
    input  logic [STAGES-2:0] k,
    output logic signed [DW-1:0] w_re, w_im
);
  always_comb begin
    case (k)
"""

    for k in range(num_twiddles):
        # 1. Calculate ideal floating-point values
        # W_N^k = cos(2*pi*k/N) - j*sin(2*pi*k/N)
        real_part = math.cos(2 * math.pi * k / N)
        imag_part = -math.sin(2 * math.pi * k / N)

        # 2. Scale and round to nearest integer
        # We round instead of casting to int() to prevent persistent truncation bias
        real_fixed = round(real_part * scale)
        imag_fixed = round(imag_part * scale)

        # 3. Format the Verilog string with the WIDTH'(val) static cast
        idx_str = f"{index_bits}'d{k}"

        # Use Python f-string padding to keep the columns perfectly aligned
        fileContent += f"      {idx_str:<6}: begin w_re = DW'({real_fixed:>4}); w_im = DW'({imag_fixed:>4}); end\n"

    fileContent += f"""      default: begin w_re =  0; w_im =    0; end
    endcase
  end
endmodule
"""
    return fileContent


args = [16, 32, 20]
file_str = ""

if (len(sys.argv) != 2) and (len(sys.argv) != 4):
  print(sys.argv)
  err()
else:
  for (i, x) in enumerate(sys.argv[1:]):
    if not x.isnumeric(): err()
    else: args[i] = int(x)

if (len(sys.argv) == 4):
  print(f"Generating Fixed for N={args[0]}, width={args[1]}, Q_POINT={args[2]}")
  file_str = generate_fixed_point_twiddles(args[0], args[1], args[2])
else:
  print(f"Generating floating for N={args[0]}")
  file_str = generate_floating_point_twiddles(args[0])

with open(os.path.join(os.getcwd(), "Twiddle_ROM.sv"), "w") as f:
    f.write(file_str)
    f.close()
