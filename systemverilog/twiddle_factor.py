import math
import sys

def generate_twiddle_rom(N):
    # only needs N/2 twiddle factors
    num_twiddles = N // 2
    
    index_bits = max(1, math.ceil(math.log2(num_twiddles)))
    fileContent = f"""`timescale 1ns / 1ps
module twiddle_factor #(
    parameter int BF_BITS = {index_bits}
) (
    input logic [BF_BITS-1:0] twiddle_idx,
    output complex_t w
);
  always_comb begin
    case (twiddle_idx)
"""
    for k in range(num_twiddles):
        # Calculate W_N^k = cos(2*pi*k/N) - j*sin(2*pi*k/N)
        real_part = math.cos(2 * math.pi * k / N)
        imag_part = -math.sin(2 * math.pi * k / N)
        
        if abs(real_part) < 1e-10: real_part = 0.0
        if abs(imag_part) < 1e-10: imag_part = 0.0
        
        idx_str = f"{index_bits}'d{k}"
        fileContent += f"      {idx_str}: w = '{{re: {real_part:>8.10f}, im: {imag_part:>8.10f}}};\n"
    fileContent +=f"""      default: w = '{{re: 0.0, im: 0.0}};
    endcase
  end
endmodule
"""
    return fileContent


import math

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
module twiddle_factor #(
    parameter int BF_BITS = {index_bits}
) (
    input logic [BF_BITS-1:0] twiddle_idx,
    output complex_t w
);
  always_comb begin
    case (twiddle_idx)
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
        fileContent += f"      {idx_str:<6}: w = '{{re: WIDTH'({real_fixed:>4}), im: WIDTH'({imag_fixed:>4})}};\n"
        
    fileContent += f"""      default: w = '{{re: WIDTH'(   0), im: WIDTH'(   0)}};
    endcase
  end
endmodule"""
    return fileContent

N = 16
if len(sys.argv) > 1:
    N = int(sys.argv[1])
    
if "fixed" in sys.argv:
    print(f"Generating Fixed for N={N}")
    s = generate_fixed_point_twiddles(N)
    with open("twiddle_factor.sv", "w") as f:
        f.write(s)
        f.close()
else:
    print(f"Generating floating for N={N}")
    s = generate_twiddle_rom(N)
    with open("floating/twiddle_factor_float.sv", "w") as f:
        f.write(s)
        f.close()