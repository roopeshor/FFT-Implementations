`timescale 1ns / 1ps
module address_generator #(
    parameter ADDR = 4,
    parameter STAGE = 2,
    parameter TWIDDLE = 3
) (
    input logic [TWIDDLE-1:0] bf_idx,
    input logic [STAGE-1:0] stage,
    output logic [ADDR-1:0] addr_a,
    output logic [ADDR-1:0] addr_b,
    output logic [TWIDDLE-1:0] twiddle_idx
);
  bit_insert_from_first #(
      .N(TWIDDLE),
      .P(STAGE),
      .insert(1'b0)
  ) bi1 (
      .in (bf_idx),
      .pos(stage),
      .out(addr_a)
  );
  bit_insert_from_first #(
      .N(TWIDDLE),
      .P(STAGE),
      .insert(1'b1)
  ) bi2 (
      .in (bf_idx),
      .pos(stage),
      .out(addr_b)
  );

  always_comb begin
    twiddle_idx = TWIDDLE'(bf_idx << (STAGE'(TWIDDLE) - stage));
  end
endmodule
