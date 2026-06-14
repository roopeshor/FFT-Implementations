`timescale 1ns / 1ps

// ---------------------------------------------------------
// Commutator (Hardware Folding Multiplexer)
// ---------------------------------------------------------
module Commutator #(
    parameter DW = 16
) (
    input  logic            state,
    input  logic [2*DW-1:0] din,     // Live Input
    input  logic [2*DW-1:0] diff,    // Butterfly Difference
    input  logic [2*DW-1:0] sr_out,  // Shift Register Output
    input  logic [2*DW-1:0] sum,     // Butterfly Sum
    output logic [2*DW-1:0] to_sr,   // Routed to Shift Register IN
    output logic [2*DW-1:0] to_mul   // Routed to Multiplier IN
);
  // Phase 1 (state=0): Buffer 'din', emit 'sr_out'
  // Phase 2 (state=1): Feed 'diff' back, emit 'sum'
  assign to_sr  = (state == 0) ? din : diff;
  assign to_mul = (state == 0) ? sr_out : sum;
endmodule
