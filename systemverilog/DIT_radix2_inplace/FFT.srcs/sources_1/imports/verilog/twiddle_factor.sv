`timescale 1ns / 1ps

module twiddle_factor #(
    parameter TWIDDLE = 2,
    parameter FIXP_WIDTH = 16
) (
    input  logic [TWIDDLE-1:0] twiddle_idx,
    output logic signed [FIXP_WIDTH-1:0] wr, wi
);
  always_comb begin
    case (twiddle_idx)
      2'd0  : begin wr = FIXP_WIDTH'(1024); wi = FIXP_WIDTH'(   0); end
      2'd1  : begin wr = FIXP_WIDTH'( 724); wi = FIXP_WIDTH'(-724); end
      2'd2  : begin wr = FIXP_WIDTH'(   0); wi = FIXP_WIDTH'(-1024); end
      2'd3  : begin wr = FIXP_WIDTH'(-724); wi = FIXP_WIDTH'(-724); end
      default: begin wr =  0; wi =    0; end
    endcase
  end
endmodule
