`timescale 1ns / 1ps

// --- 1. Pure Combinatorial Butterfly ---
module Butterfly #(parameter DW=16)(
    input  logic signed [DW-1:0] a_re, a_im, b_re, b_im,
    output logic signed [DW-1:0] c_re, c_im, d_re, d_im
);
    assign c_re = a_re + b_re;
    assign c_im = a_im + b_im;
    assign d_re = a_re - b_re;
    assign d_im = a_im - b_im;
endmodule
