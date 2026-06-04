module bit_rev #(
    parameter BITS = 3
) (
    input  logic [BITS-1:0] src,
    output logic [BITS-1:0] dest
);
  genvar i;
  generate
    for (i = 0; i < BITS; i = i + 1) begin
      assign dest[i] = src[BITS-1-i];
    end
  endgenerate
endmodule
