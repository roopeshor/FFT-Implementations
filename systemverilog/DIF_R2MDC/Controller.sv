`timescale 1ns / 1ps
//! Controller initates the systemwide counter and data validity
module Controller #(
    //! number of stages (used to compute size of buffer)
    parameter int STAGES = 3,
    parameter int DW = 16
) (
    input logic clk,
    input logic rst,
    //! whether input is valid. thing works only if this is high
    input logic in_valid,

    input logic signed [DW-1:0] din_re,
    input logic signed [DW-1:0] din_im,

    //! Is high when output is ready
    output logic out_valid,
    //! Returns internal counter output, which is used in further stages
    output logic [STAGES-2:0] out_cnt,
    output logic signed [DW-1:0] out0_re,
    output logic signed [DW-1:0] out0_im,
    output logic signed [DW-1:0] out1_re,
    output logic signed [DW-1:0] out1_im
);
  assign out0_re = din_re;
  assign out0_im = din_im;
  assign out1_re = din_re;
  assign out1_im = din_im;

  //! internal counter
  logic [STAGES-1:0] cnt;

  //! updates counter
  always_ff @(posedge clk) begin : counter_update
    if (rst) cnt <= '0;
    else if (in_valid) cnt <= cnt + 1'b1;
  end

  assign out_valid = in_valid && cnt[STAGES-1];
  assign out_cnt   = cnt[STAGES-2:0];
endmodule
