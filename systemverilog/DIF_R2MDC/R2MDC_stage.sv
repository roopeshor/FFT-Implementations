`timescale 1ns / 1ps

// --- 7. A Single Parametric FFT Stage ---
module R2MDC_stage #(
    parameter int STAGES = 3,
    parameter int STAGE_IDX = 1,
    parameter int DW = 16,
    parameter int FIXP_Q = 10
) (
    input logic clk,
    input logic rst,
    input logic in_valid,
    input logic [STAGES-2:0] in_cnt,
    input logic signed [DW-1:0] in0_re,
    input logic signed [DW-1:0] in0_im,
    input logic signed [DW-1:0] in1_re,
    input logic signed [DW-1:0] in1_im,
    output logic out_valid,
    output logic [STAGES-2:0] out_cnt,
    output logic signed [DW-1:0] out0_re,
    output logic signed [DW-1:0] out0_im,
    output logic signed [DW-1:0] out1_re,
    output logic signed [DW-1:0] out1_im
);
  logic signed [DW-1:0] bf0_re, bf0_im, bf1_re, bf1_im;
  logic signed [DW-1:0] in0_re_delayed,in0_im_delayed;
  //! number of data points
  // localparam int N = 1 << STAGES;
  //! half the number of data points
  // localparam int HALF_N = N / 2;
  localparam D = 1 << (STAGES - 1 - STAGE_IDX);
  // localparam D2 = 1 << (STAGES - STAGE_IDX);
  // Delay_pipe #(
  //     .DW(DW),
  //     .CYCLES(D2)
  // ) d_r (
  //     .clk(clk),
  //     .rst(rst),
  //     .en (1'b1),
  //     .d  (in0_re),
  //     .q  (in0_re_delayed)
  // );
  //! delays imaginary part of input
  // Delay_pipe #(
  //     .DW(DW),
  //     .CYCLES(D2)
  // ) d_i (
  //     .clk(clk),
  //     .rst(rst),
  //     .en (1'b1),
  //     .d  (in0_im),
  //     .q  (in0_im_delayed)
  // );

  Butterfly #(
      .DW(DW)
  ) bf (
      .a_re(in0_re),
      .a_im(in0_im),
      .b_re(in1_re),
      .b_im(in1_im),
      .c_re(bf0_re),
      .c_im(bf0_im),
      .d_re(bf1_re),
      .d_im(bf1_im)
  );

  logic signed [DW-1:0] r_bf0_re, r_bf0_im, r_bf1_re, r_bf1_im;
  logic r_valid1;
  logic [STAGES-2:0] r_cntr1;
  always_ff @(posedge clk) begin
    r_valid1 <= rst ? 1'b0 : in_valid;
    r_cntr1  <= in_cnt;
    r_bf0_re <= bf0_re;
    r_bf0_im <= bf0_im;
    r_bf1_re <= bf1_re;
    r_bf1_im <= bf1_im;
  end

  generate
    if (STAGE_IDX < STAGES) begin : gen_stage
      logic [STAGES-2:0] mask, k;
      assign mask = (1 << (STAGES - STAGE_IDX)) - 1;
      assign k = (r_cntr1 & mask) << (STAGE_IDX - 1);

      logic signed [DW-1:0] w_re, w_im;
      Twiddle_ROM #(
          .STAGES(STAGES),
          .DW(DW),
          .FIXP_Q(FIXP_Q)
      ) twd (
          .k(k),
          .w_re(w_re),
          .w_im(w_im)
      );

      logic signed [DW-1:0] mult_re, mult_im;
      Complex_Mul #(
          .DW(DW),
          .FIXP_Q(FIXP_Q)
      ) cmult (
          .clk(clk),
          .ar (r_bf1_re),
          .ai (r_bf1_im),
          .br (w_re),
          .bi (w_im),
          .cr (mult_re),
          .ci (mult_im)
      );

      logic signed [DW-1:0] r2_bf0_re, r2_bf0_im;
      logic r_valid2;
      logic [STAGES-2:0] r_cntr2;
      always_ff @(posedge clk) begin
        r_valid2  <= rst ? 1'b0 : r_valid1;
        r_cntr2   <= r_cntr1;
        r2_bf0_re <= r_bf0_re;
        r2_bf0_im <= r_bf0_im;
      end

      logic w_cross;
      assign w_cross = r_cntr2[STAGES-1-STAGE_IDX];

      Commutator #(
          .DW(DW),
          .D(D),
          .CNT_W(STAGES - 1)
      ) comm (
          .clk(clk),
          .rst(rst),
          .in_valid(r_valid2),
          .in_cnt(r_cntr2),
          .w_cross(w_cross),
          .in0_re(r2_bf0_re),
          .in0_im(r2_bf0_im),
          .in1_re(mult_re),
          .in1_im(mult_im),
          .out_valid(out_valid),
          .out_cnt(out_cnt),
          .out0_re(out0_re),
          .out0_im(out0_im),
          .out1_re(out1_re),
          .out1_im(out1_im)
      );

    end else begin : gen_last_stage
      assign out_valid = r_valid1;
      assign out_cnt   = r_cntr1;
      assign out0_re   = r_bf0_re;
      assign out0_im   = r_bf0_im;
      assign out1_re   = r_bf1_re;
      assign out1_im   = r_bf1_im;
    end
  endgenerate
endmodule
