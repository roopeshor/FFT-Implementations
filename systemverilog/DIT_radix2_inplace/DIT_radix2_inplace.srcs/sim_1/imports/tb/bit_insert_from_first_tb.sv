`timescale 1ns / 1ps

module bit_insert_from_first_tb;

  // Parameters
  localparam int N = 3;
  localparam int P = 2;
  localparam insert = 1;

  //Ports
  logic [N-1:0] in;
  logic [P-1:0] pos;
  logic [  N:0] out;

  bit_insert_from_first #(
      .N(N),
      .P(P),
      .insert(insert)
  ) bit_insert_from_first_inst (
      .in (in),
      .pos(pos),
      .out(out)
  );

  initial begin
    in = 3'b000;
    pos = 2'b11;

    #1 $display("N = %d, P = %d, insert = %d, in = %b, pos = %d, out = %b", N, P, insert, in, pos, out);
    
    #5;
    in = 3'b000;
    pos = 2'b01;

    #1 $display("N = %d, P = %d, insert = %d, in = %b, pos = %d, out = %b", N, P, insert, in, pos, out);
  end
endmodule
