`timescale 1ns / 1ps
import DIT_radix2_inplace::*;
// FSM states
module fft_radix2_tb_dbg ();

  localparam N = 4;
  localparam N_BITS = $clog2(N);
  localparam FIXP_WIDTH = 32;
  localparam FIXP_Q = 20;

  logic clk;
  logic rst;
  logic start;
  logic input_valid;
  logic [$clog2(N)-1:0] output_read_addr;
  logic signed [FIXP_WIDTH-1:0] din_re, din_im;

  logic output_ready;
  logic signed [FIXP_WIDTH-1:0] dout_re, dout_im;

  fft_radix2 #(
      .N(N),
      .FIXP_WIDTH(FIXP_WIDTH),
      .FIXP_Q(FIXP_Q),
      .DEBUG(1'b0)
  ) dut (
      .clk(clk),
      .rst(rst),
      .start(start),
      .input_valid(input_valid),
      .din_re(din_re),
      .din_im(din_im),
      .output_ready(output_ready),
      .output_read_addr(output_read_addr),
      .dout_re(dout_re),
      .dout_im(dout_im)
  );

  always_ff @(posedge clk) begin
    if (!output_ready) begin
      $display("--- posedge: %0f, counter: %d ---", $realtime, dut.counter);
      $display("  state        = %s", state_read(dut.state));
      $display("  rst          = %b", dut.rst);
      $display("  start        = %b", dut.start);
      $display("  input_valid  = %b", dut.input_valid);
      $display("  output_ready = %b", dut.output_ready);
      $display("  din          = %03.2f + %03.2fj", b2r(din_re), b2r(din_im));
      $display("  dout         = %03.2f + %03.2fj", b2r(dout_re), b2r(dout_im));
      $display("  a(%03.2f + %03.2fj)   b(%03.2f + %03.2fj) ", b2r(dut.ar), b2r(dut.ai), b2r(dut.br
               ), b2r(dut.bi));
      $display("  c(%03.2f + %03.2fj)   d(%03.2f + %03.2fj) ", b2r(dut.cr), b2r(dut.ci), b2r(dut.dr
               ), b2r(dut.di));
      $display("  addr_a=%0d   addr_b=%0d   input_load_addr=%0d", dut.addr_a, dut.addr_b,
               dut.input_load_addr);
      if (!input_valid) $display("  w            = %03.2f + %03.2fj", b2r(dut.wr), b2r(dut.wi));
      $display("  ----- mem -----");
      for (integer i = 0; i < N; i = i + 1) begin
        $display(
            "     [%2d]:%6.2f %s%6.2fj%s", i, b2r(dut.mem_re[i]), (b2r(dut.mem_im[i]
            ) < 0.0) ? "-" : "+", (b2r(dut.mem_im[i]) < 0.0) ? -b2r(dut.mem_im[i]) : b2r(
            dut.mem_im[i]),
            ((dut.input_load_addr == N_BITS'(i)) && input_valid ? "      <-- input_load_addr" : ""));
      end
      $display("  ----- /mem -----\n");
    end
  end

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end
  initial begin
    rst = 1;
    start = 0;
    input_valid = 0;
    din_re = 0;
    din_im = 0;
    output_read_addr = 0;
    start = 0;

    @(posedge clk);
    rst = 0;
    @(posedge clk);
    start = 1;
    $display("--- Streaming Input Data ---");
    for (integer i = 0; i < N; i = i + 1) begin
      input_valid = 1;
      din_re = (FIXP_WIDTH'(i) + 1) << FIXP_Q;
      din_im = 0;
      $display("Input: %0d + 0j", i + 1);
      @(posedge clk);
    end

    input_valid = 0;
    din_re = FIXP_WIDTH'((42) << FIXP_Q);
    wait (output_ready);
    @(posedge clk);


    $display("--- Final FFT Output Spectrum ---");
    $display("Bin | Real (Fixed) | Imag (Fixed) | Real (Float) | Imag (Float)");
    $display("---------------------------------------------------------------");
    for (integer i = 0; i < N; i = i + 1) begin
      output_read_addr = $clog2(N)'(i);
      @(posedge clk);
      $display("%2d  | %64b | %64b | %12.4f | %12.4f", i, dout_re, dout_im, b2r(dout_re), b2r(
               dout_im));
    end
    @(posedge clk);
    // #1;
    // // Data for N-1 is available
    // float_mem_re = $itor($signed(dout_re)) / (1.0 * (1 << FIXP_Q));
    // float_mem_im = $itor($signed(dout_im)) / (1.0 * (1 << FIXP_Q));
    // $display("%2d  | %12d | %12d | %12.4f | %12.4f", N - 1, dout_re, dout_im, float_mem_re, float_mem_im);

    $finish;
  end
  function real b2r(logic signed [FIXP_WIDTH-1:0] p);
    return $itor($signed(p)) / (1.0 * (1 << FIXP_Q));
  endfunction

  function string state_read(state_t state);
    case (state)
      IDLE: return "IDLE";
      LOAD: return "LOAD";
      COMPUTE: return "COMPUTE";
      DONE: return "DONE";
      default: return "UKN";
    endcase
  endfunction
endmodule
