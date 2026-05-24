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

N = 16
if len(sys.argv) > 1:
    N = int(sys.argv[1])

print(f"Generating for N={N}")
s = generate_twiddle_rom(N)

with open("twiddle_factor.sv", "w") as f:
    f.write(s)
    f.close()