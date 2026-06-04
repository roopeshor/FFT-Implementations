`timescale 1ns / 1ps
module bit_insert_from_first #(
    parameter int N = 3,
    parameter int P = 2,
    parameter insert = 1'b0
) (
    input  logic [N-1:0] in,
    input  logic [P-1:0] pos,
    output logic [  N:0] out
);

  always_comb begin
    out = '0;
    for (int i = 0; i < N; i++) begin
      if (P'(i) >= pos) out[i+1] = in[i];
      else out[i] = in[i];
    end
    
    // 3. Explicitly insert the 0 at the exact position
    out[pos] = insert;
  end
endmodule
