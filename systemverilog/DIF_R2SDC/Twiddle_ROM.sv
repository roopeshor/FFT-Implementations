`timescale 1ns / 1ps

// ---------------------------------------------------------
// Twiddle Factor ROM Generator
// ---------------------------------------------------------
module Twiddle_ROM #(
    parameter D = 1,
    parameter DW = 16,
    parameter FIXP_Q = 10,
    parameter K_WIDTH = 1
) (
    input  logic               state,
    input  logic [K_WIDTH-1:0] k,
    output logic [   DW*2-1:0] W
);
  logic signed [DW-1:0] re_rom[0:D-1];
  logic signed [DW-1:0] im_rom[0:D-1];
  logic signed [DW-1:0] Wi, Wr;

  real theta;
  initial begin
    for (int i = 0; i < D; i++) begin
      theta = -2.0 * 3.14159265358979323846 * i / (2.0 * D);
      re_rom[i] = DW'($rtoi($cos(theta) * (1 << FIXP_Q)));
      im_rom[i] = DW'($rtoi($sin(theta) * (1 << FIXP_Q)));
    end
  end

  // When state=1, pass data through unchanged (multiply by 1 + j0)
  assign Wr = (state == 0) ? re_rom[k] : (1 << FIXP_Q);
  assign Wi = (state == 0) ? im_rom[k] : 0;
  assign W  = {Wr, Wi};
endmodule
