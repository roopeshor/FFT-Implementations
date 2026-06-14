`timescale 1ns / 1ps

// ---------------------------------------------------------
// SDC Control Logic & Master Counter
// ---------------------------------------------------------
module SDC_Control #(
    parameter STAGE_IDX = 0,
    parameter D = 1,
    parameter K_WIDTH = 1
) (
    input  logic               clk,
    input  logic               rst,
    input  logic               in_valid,
    output logic               stage_en,
    output logic               state,
    output logic [K_WIDTH-1:0] k,
    output logic               pre_out_valid
);
  logic [STAGE_IDX:0] cnt;

  Shift_Register #(
      .D (D),
      .DW(1)
  ) u_shift_reg (
      .clk (clk),
      .rst (rst),
      .en  (stage_en),
      .din (in_valid),
      .dout(pre_out_valid)
  );
  assign stage_en = in_valid | pre_out_valid;

  // Master Phase Counter
  always_ff @(posedge clk) begin
    if (rst) cnt <= 0;
    else if (stage_en) cnt <= cnt + 1;
  end

  assign state = cnt[STAGE_IDX];
  generate
    if (STAGE_IDX == 0) begin : genblk1
      assign k = '0;
    end else begin : genblk1
      assign k = cnt[STAGE_IDX-1:0];
    end
  endgenerate

endmodule
