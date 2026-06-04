`timescale 1ns / 1ps

module fft_fsm_tb;

  // Parameters
  localparam COUNTER = 5;
  localparam N = 16;

  //Ports
  logic clk;
  logic rst;
  logic input_valid;
  logic start;
  logic output_ready;
  logic write_computed_cd_to_mem;
  logic write_input_to_mem;
  logic [COUNTER-1:0] counter;

  fft_fsm #(
      .COUNTER(COUNTER)
  ) fsm (
      .clk(clk),
      .rst(rst),
      .input_valid(input_valid),
      .start(start),
      .output_ready(output_ready),
      .write_computed_cd_to_mem(write_computed_cd_to_mem),
      .write_input_to_mem(write_input_to_mem),
      .counter(counter)
  );

  always #2 clk = !clk;
  always_ff @(posedge clk) begin
    $display("--posedge--");
    $display("%d: State        = %s", counter, state_read(fsm.state));
    $display("%d: rst          = %b", counter, rst);
    $display("%d: start        = %b", counter, start);
    $display("%d: input_valid  = %b", counter, input_valid);
    $display("%d: output_ready = %b", counter, output_ready);
    $display("%d: write_cd     = %b", counter, write_computed_cd_to_mem);
    $display("%d: write_in     = %b", counter, write_input_to_mem);
  end
  initial begin
    clk = 0;
    rst = 0;
    @(posedge clk);
    rst = 1;
    @(posedge clk);
    rst = 0;
    $display("--- Streaming Input Data ---");

    start = 1;
    input_valid = 1;
    for (integer i = 0; i < N; i = i + 1) begin
      @(posedge clk);
    end

    input_valid = 0;
    wait (output_ready);
    @(posedge clk);
    start = 0;
    $display("--- Getting output ---");
    #127 $finish();

  end
  function string state_read(logic [1:0] state);
    case (state)
      2'd0: return "IDLE";
      2'd1: return "LOAD";
      2'd2: return "WRITE";
      2'd3: return "DONE";
    endcase
  endfunction
endmodule
