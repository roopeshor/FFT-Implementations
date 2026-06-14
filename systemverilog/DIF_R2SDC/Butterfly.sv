`timescale 1ns / 1ps

// ---------------------------------------------------------
// Butterfly Arithmetic (with symmetric scaling)
// ---------------------------------------------------------
module Butterfly #(
    parameter DW = 16,
    parameter USE_ARS = '0
) (
    // From Shift Register
    input  logic [DW*2-1:0] a,
    // From Live Input (din)
    input  logic [DW*2-1:0] b,
    output logic [DW*2-1:0] sum,
    output logic [DW*2-1:0] diff
);
  logic signed [DW-1:0] a_re, a_im, b_re, b_im, sum_re, sum_im, diff_re, diff_im;
  assign {a_re, a_im} = a;
  assign {b_re, b_im} = b;
  assign sum = {sum_re, sum_im};
  assign diff = {diff_re, diff_im};

  generate
    if (USE_ARS) begin : gblk1
      logic signed [DW:0] s_re, s_im, d_re, d_im;

      assign s_re = a_re + b_re;
      assign s_im = a_im + b_im;
      assign d_re = a_re - b_re;
      assign d_im = a_im - b_im;

      // Divide by 2 to prevent bit-growth (Arithmetic Right Shift)
      assign sum_re = s_re[DW:1];
      assign sum_im = s_im[DW:1];
      assign diff_re = d_re[DW:1];
      assign diff_im = d_im[DW:1];
    end else begin : gblk1
      assign sum_re  = a_re + b_re;
      assign sum_im  = a_im + b_im;
      assign diff_re = a_re - b_re;
      assign diff_im = a_im - b_im;
    end
  endgenerate
endmodule

