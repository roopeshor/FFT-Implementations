//! @title Configurable Buffer
module Delay_pipe #(
    //! Width of data
    parameter int DW = 16,
    //! number of cycles to delay data
    parameter int CYCLES = 1
) (
    input logic clk,
    input logic rst,
    //! Only shifts data if `en` signal is high
    input logic en,
    //! Input data
    input logic [DW-1:0] d,
    //! Data delayed by `CYCLES`
    output logic [DW-1:0] q
);
  generate
    if (CYCLES == 0) begin : geb1
      assign q = d;
    end else begin : geb1
      logic [DW-1:0] pipe[0:CYCLES-1];
      always_ff @(posedge clk) begin
        if (rst) for (int i = 0; i < CYCLES; i++) pipe[i] <= '0;
        else if (en) begin
          pipe[0] <= d;
          for (int i = 1; i < CYCLES; i++) pipe[i] <= pipe[i-1];
        end
      end
      assign q = pipe[CYCLES-1];
    end
  endgenerate
endmodule
