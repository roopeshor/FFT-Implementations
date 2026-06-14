`timescale 1ns / 1ps

module fixed_mul #(
    parameter FIXP_WIDTH  = 16,
    parameter FIXP_Q = 8
) (
    input  logic signed [FIXP_WIDTH-1:0] a,
    input  logic signed [FIXP_WIDTH-1:0] b,
    output logic  signed [FIXP_WIDTH-1:0] p
);

  logic signed [2*FIXP_WIDTH-1:0] full_p;

  always_comb begin
    full_p = a * b;
    p = FIXP_WIDTH'(full_p >>> FIXP_Q);
  end

endmodule
