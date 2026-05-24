`timescale 1ns / 1ps
module twiddle_factor #(
    parameter int BF_BITS = 3
) (
    input logic [BF_BITS-1:0] twiddle_idx,
    output complex_t w
);
  always_comb begin
    case (twiddle_idx)
      3'd0  : w = '{re: WIDTH'( 256), im: WIDTH'(   0)};
      3'd1  : w = '{re: WIDTH'( 237), im: WIDTH'( -98)};
      3'd2  : w = '{re: WIDTH'( 181), im: WIDTH'(-181)};
      3'd3  : w = '{re: WIDTH'(  98), im: WIDTH'(-237)};
      3'd4  : w = '{re: WIDTH'(   0), im: WIDTH'(-256)};
      3'd5  : w = '{re: WIDTH'( -98), im: WIDTH'(-237)};
      3'd6  : w = '{re: WIDTH'(-181), im: WIDTH'(-181)};
      3'd7  : w = '{re: WIDTH'(-237), im: WIDTH'( -98)};
      default: w = '{re: WIDTH'(   0), im: WIDTH'(   0)};
    endcase
  end
endmodule