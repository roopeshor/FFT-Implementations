`timescale 1ns / 1ps

module R2MDC #(
    //! number of stages (used to compute size of buffer)    
    parameter int STAGES = 4,
    //! width of data
    parameter int DW = 16,
    //! position of decimal point from right
    parameter int FIXP_Q = 10
) (
    //! clock to module
    input logic clk,
    //! reset signal
    input logic rst,
    //! whether input is valid or not
    input logic in_valid,
    //! real part of input
    input logic signed [DW-1:0] din_re,
    //! imaginary part of input
    input logic signed [DW-1:0] din_im,
    //! whether output is valid or not
    output logic out_valid,
    //! real part of first output
    output logic signed [DW-1:0] out0_re,
    //! imaginary part of first output
    output logic signed [DW-1:0] out0_im,
    //! real part of second output
    output logic signed [DW-1:0] out1_re,
    //! imaginary part of second output
    output logic signed [DW-1:0] out1_im
);

  logic stg_val[0:STAGES];
  logic [STAGES-2:0] stg_cnt[0:STAGES];
  logic signed [DW-1:0] stg_re0[0:STAGES];
  logic signed [DW-1:0] stg_im0[0:STAGES];
  logic signed [DW-1:0] stg_re1[0:STAGES];
  logic signed [DW-1:0] stg_im1[0:STAGES];

  Controller #(
      .STAGES(STAGES),
      .DW(DW)
  ) ctrl (
      .clk(clk),  // i
      .rst(rst),  // i
      .in_valid(in_valid),  // i
      .out_valid(stg_val[0]),  // o
      .out_cnt(stg_cnt[0]),  // o
      .din_re(din_re),  // o
      .din_im(din_im),  // o
      .out0_re(stg_re0[0]),  // o
      .out0_im(stg_im0[0]),  // o
      .out1_re(stg_re1[0]),  // o
      .out1_im(stg_im1[0])  // o
  );

  genvar s;
  generate
    for (s = 1; s <= STAGES; s++) begin : gen_stages
      R2MDC_stage #(
          .STAGES(STAGES),
          .STAGE_IDX(s),
          .DW(DW),
          .FIXP_Q(FIXP_Q)
      ) stage_inst (
          .clk(clk),  // i
          .rst(rst),  // i
          .in_valid(stg_val[s-1]),  // i
          .in_cnt(stg_cnt[s-1]),  // i
          .in0_re(stg_re0[s-1]),  // i
          .in0_im(stg_im0[s-1]),  // i
          .in1_re(stg_re1[s-1]),  // i
          .in1_im(stg_im1[s-1]),  // i
          .out_valid(stg_val[s]),  // o
          .out_cnt(stg_cnt[s]),  // o
          .out0_re(stg_re0[s]),  // o
          .out0_im(stg_im0[s]),  // o
          .out1_re(stg_re1[s]),  // o
          .out1_im(stg_im1[s])  // o
      );
    end
  endgenerate

  assign out_valid = stg_val[STAGES];
  assign out0_re   = stg_re0[STAGES];
  assign out0_im   = stg_im0[STAGES];
  assign out1_re   = stg_re1[STAGES];
  assign out1_im   = stg_im1[STAGES];

endmodule
