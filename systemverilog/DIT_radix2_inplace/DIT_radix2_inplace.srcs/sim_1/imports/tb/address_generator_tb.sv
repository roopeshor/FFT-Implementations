`timescale 1ns / 1ps
module address_generator_tb;

  // Parameters
  localparam ADDR = 4;
  localparam STAGE = 2;
  localparam TWIDDLE = 3;
  localparam COUNTER = 5;
  localparam BF_ADDR_WIDTH = TWIDDLE;

  //Ports
  logic [TWIDDLE-1:0] bf_idx;
  logic [STAGE-1:0] stage;
  logic [ADDR-1:0] addr_a;
  logic [ADDR-1:0] addr_b;
  logic [TWIDDLE-1:0] twiddle_idx;

  logic clk;
  logic [COUNTER-1:0] counter;

  address_generator #(
      .ADDR(ADDR),
      .STAGE(STAGE),
      .TWIDDLE(TWIDDLE)
  ) address_generator_inst (
      .bf_idx(bf_idx),
      .stage(stage),
      .addr_a(addr_a),
      .addr_b(addr_b),
      .twiddle_idx(twiddle_idx)
  );

  assign bf_idx = counter[BF_ADDR_WIDTH-1:0];
  assign stage  = counter[COUNTER-1:BF_ADDR_WIDTH];
  always #2 clk = !clk;
  
  always_ff @(posedge clk) begin
    if (counter >= {COUNTER{1'b1}}) counter <= 0;
    else counter <= counter + 1;
      $display("%05b    | %02b    | %03b    | %04b   | %04b    | %03b", counter, stage, bf_idx, addr_a, addr_b, twiddle_idx);
  end

  initial begin
    clk = 0;
    counter = 0;
    $dumpfile("waveform.vcd");
    $dumpvars(0, address_generator_tb);
    $display("counter  | stage | bf_idx | addr_a | addr_b  | twiddle_idx");
    $display("---------|-------|--------|--------|---------|------------");
    #128 $finish();
  end

endmodule
