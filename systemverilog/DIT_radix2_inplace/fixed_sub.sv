`timescale 1ns / 1ps
module fixed_sub #(
    parameter FIXP_WIDTH = 16
) (
    input  logic signed [FIXP_WIDTH-1:0] a,
    input  logic signed [FIXP_WIDTH-1:0] b,
    output logic  signed [FIXP_WIDTH-1:0] c
);
  logic signed [FIXP_WIDTH:0] full_sub;
  
  localparam signed [FIXP_WIDTH:0] MAX_VAL_EXT = (1 << (FIXP_WIDTH - 1)) - 1;
  localparam signed [FIXP_WIDTH:0] MIN_VAL_EXT = -(1 << (FIXP_WIDTH - 1));

  always_comb begin
    full_sub = a - b;
/*
    if (full_sub > MAX_VAL_EXT) c = MAX_VAL_EXT[FIXP_WIDTH-1:0];
    else if (full_sub < MIN_VAL_EXT) c = MIN_VAL_EXT[FIXP_WIDTH-1:0];*/
    // else 
    c = full_sub[FIXP_WIDTH-1:0];
  end
endmodule
