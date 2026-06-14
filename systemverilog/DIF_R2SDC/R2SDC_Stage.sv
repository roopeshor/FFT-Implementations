`timescale 1ns / 1ps

// ==============================================================================
// SUB-MODULE: Single SDC Stage (Structural Wrapper)
// ==============================================================================
module R2SDC_Stage #(
    parameter STAGE_IDX = 0,
    parameter DW = 16,
    parameter FIXP_Q = 10,
    parameter USE_ARS = '0
) (
    input  logic            clk,
    input  logic            rst,
    input  logic [DW*2-1:0] din,
    input  logic            in_valid,
    output logic [DW*2-1:0] dout,
    output logic            out_valid
);
  localparam int D = 1 << STAGE_IDX;
  localparam int K_WIDTH = (STAGE_IDX == 0) ? 1 : STAGE_IDX;

  logic state, pre_out_valid, stage_en;
  logic [K_WIDTH-1:0] k;
  logic [DW*2-1:0] sr_out, sum, diff, W, mult_out, to_sr, to_mul;

  // 2. Instantiate Sub-Modules
  SDC_Control #(
      .STAGE_IDX(STAGE_IDX),
      .D(D),
      .K_WIDTH(K_WIDTH)
  ) u_ctrl (
      .clk(clk),
      .rst(rst),
      .in_valid(in_valid),
      .stage_en(stage_en),
      .state(state),
      .k(k),
      .pre_out_valid(pre_out_valid)
  );

  Butterfly #(
      .DW(DW),
      .USE_ARS(USE_ARS)
  ) u_bfly (
      .a(sr_out),
      .b(din),
      .sum(sum),
      .diff(diff)
  );

  Commutator #(
      .DW(DW)
  ) u_comm (
      .state(state),
      .din(din),
      .sr_out(sr_out),
      .diff(diff),
      .sum(sum),
      .to_sr(to_sr),
      .to_mul(to_mul)
  );

  Shift_Register #(
      .D (D),
      .DW(DW * 2)
  ) u_shift_reg (
      .clk (clk),
      .rst (rst),
      .en  (stage_en),
      .din (to_sr),
      .dout(sr_out)
  );

  Twiddle_ROM #(
      .D(D),
      .DW(DW),
      .FIXP_Q(FIXP_Q),
      .K_WIDTH(K_WIDTH)
  ) u_rom (
      .state(state),
      .k(k),
      .W(W)
  );

  Complex_Mul #(
      .DW(DW),
      .FIXP_Q(FIXP_Q)
  ) u_mul (
      .a  (to_mul),
      .b  (W),
      .p  (mult_out),
      .clk(clk)
  );

  // 3. Pipeline Output Registers
  logic mul_valid, pre_stage_en;
  always_ff @(posedge clk) begin
    if (rst) begin
      dout <= 0;
      mul_valid <= 0;
      out_valid <= 0;
      pre_stage_en <= 0;
    end else begin
      mul_valid    <= stage_en & pre_out_valid;
      pre_stage_en <= stage_en;

      out_valid <= mul_valid;
      if (pre_stage_en) dout <= mult_out;
    end
  end
endmodule
