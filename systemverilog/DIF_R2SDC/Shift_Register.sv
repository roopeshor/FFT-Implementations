`timescale 1ns / 1ps

// ---------------------------------------------------------
// Shift Register (The Delay Line)
// ---------------------------------------------------------
module Shift_Register #(
    parameter D = 1, 
    parameter DW = 32
)(
    input  logic              clk,
    input  logic              rst,
    input  logic              en,
    input  logic [DW-1:0]   din,
    output logic [DW-1:0]   dout
);
    logic [DW-1:0] sr [0:D-1];
    
    assign dout = sr[D-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for(int i=0; i<D; i++) sr[i] <= 0;
        end else if (en) begin
            sr[0] <= din;
            for(int i=1; i<D; i++) sr[i] <= sr[i-1];
        end
    end
endmodule
