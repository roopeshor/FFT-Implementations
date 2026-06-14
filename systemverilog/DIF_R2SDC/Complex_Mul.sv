`timescale 1ns / 1ps

// ---------------------------------------------------------
// Complex Multiplier
// ---------------------------------------------------------
module Complex_Mul #(
    parameter DW = 16,
    parameter FIXP_Q = 10
) (
    input  logic [DW*2-1:0] a, b,
    input  logic            clk,
    output logic [DW*2-1:0] p
);
  logic signed [DW-1:0] ar, ai, br, bi, pr, pi;
  // logic signed [2*DW-1:0] pr_full, pi_full;
  logic signed [2*DW-1:0] p_rr, p_ii, p_ri, p_ir;

  assign {ar, ai} = a;
  assign {br, bi} = b;

  always_ff @(posedge clk) begin
    p_rr <= ar * br;
    p_ii <= ai * bi;
    p_ri <= ar * bi;
    p_ir <= ai * br;
  end
  // assign pr_full = (ar * br) - (ai * bi);
  // assign pi_full = (ar * bi) + (ai * br);

  // Truncate back to base data width
  assign pr = DW'((p_rr - p_ii) >>> FIXP_Q);
  assign pi = DW'((p_ri + p_ir) >>> FIXP_Q);

  assign p = {pr, pi};
endmodule
