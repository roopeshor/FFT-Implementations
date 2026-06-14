`timescale 1ns / 1ps

module fixed_add #(
    parameter FIXP_WIDTH = 16
) (
    input  logic signed [FIXP_WIDTH-1:0] a,
    input  logic signed [FIXP_WIDTH-1:0] b,
    output logic  signed [FIXP_WIDTH-1:0] c
);

  logic signed [FIXP_WIDTH:0] full_sum;

  localparam signed [FIXP_WIDTH:0] MAX_VAL_EXT = (1 << (FIXP_WIDTH - 1)) - 1;
  localparam signed [FIXP_WIDTH:0] MIN_VAL_EXT = -(1 << (FIXP_WIDTH - 1));

  always_comb begin
    full_sum = a + b;

    // clamping
    // if (full_sum > MAX_VAL_EXT) begin
    //   c = MAX_VAL_EXT[FIXP_WIDTH-1:0];
    // end else if (full_sum < MIN_VAL_EXT) begin
    //   c = MIN_VAL_EXT[FIXP_WIDTH-1:0];
    // end else begin
      c = full_sum[FIXP_WIDTH-1:0];
    // end
  end

endmodule
