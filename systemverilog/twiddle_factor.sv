`timescale 1ns / 1ps
module twiddle_factor #(
    parameter int BF_BITS = 3
) (
    input logic [BF_BITS-1:0] twiddle_idx,
    output complex_t w
);
  always_comb begin
    case (twiddle_idx)
      3'd0: w = '{re: 1.0000000000, im: 0.0000000000};
      3'd1: w = '{re: 0.9238795325, im: -0.3826834324};
      3'd2: w = '{re: 0.7071067812, im: -0.7071067812};
      3'd3: w = '{re: 0.3826834324, im: -0.9238795325};
      3'd4: w = '{re: 0.0000000000, im: -1.0000000000};
      3'd5: w = '{re: -0.3826834324, im: -0.9238795325};
      3'd6: w = '{re: -0.7071067812, im: -0.7071067812};
      3'd7: w = '{re: -0.9238795325, im: -0.3826834324};
      default: w = '{re: 0.0, im: 0.0};
    endcase
  end
endmodule
