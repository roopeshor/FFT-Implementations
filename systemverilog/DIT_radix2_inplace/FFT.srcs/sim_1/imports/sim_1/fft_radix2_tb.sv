`timescale 1ns / 1ps

module fft_radix2_tb ();

  localparam N = 8;
  localparam N_BITS = $clog2(N);
  localparam FIXP_WIDTH = 16;
  localparam FIXP_Q = 10;

  logic clk;
  logic rst;
  logic start;
  logic input_valid;
  logic output_ready;
  logic [N_BITS-1:0] output_read_addr;
  logic signed [FIXP_WIDTH-1:0] din_re, din_im;
  logic signed [FIXP_WIDTH-1:0] dout_re, dout_im;

  fft_radix2 #(
      .N(N),
      .FIXP_WIDTH(FIXP_WIDTH),
      .FIXP_Q(FIXP_Q)
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


  // for waveform export
  integer file;
  initial begin
    file = $fopen("fft_radix2_tb.csv", "w");
    $fdisplay(
        file,
        "clk,rst,start,input_valid,output_read_addr,din_re,din_im,output_ready,dout_re,dout_im");
  end

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  initial begin
    @(posedge clk);
    rst = 1;
    start = 0;
    input_valid = 0;
    din_re = 0;
    din_im = 0;
    output_read_addr = 0;
    start = 0;
    @(posedge clk);
    @(posedge clk);
    rst = 0;
    @(posedge clk);
    start = 1;
    $display("--- Streaming Input Data ---");
    input_valid = 1;
    for (integer i = 1; i <= N; i = i + 1) begin
      din_re = FIXP_WIDTH'((i+3) << FIXP_Q);
      din_im = 0;
      $display("Input: %0d + 0j", (i+3));
      @(posedge clk);
    end

    input_valid = 0;
    // force all inputs to unknown to test data overwrite
    din_re = {(FIXP_WIDTH) {1'bx}};
    din_im = {(FIXP_WIDTH) {1'bx}};

    $display("waiting for output_ready");
    wait (output_ready);
    @(posedge clk);
    start = 0;

    $display("--- Final FFT Output Spectrum ---");
    $display("Bin | Real (Fixed) | Imag (Fixed) | Real (Float) | Imag (Float)");
    $display("---------------------------------------------------------------");
    for (integer i = 0; i < N; i = i + 1) begin
      output_read_addr = N_BITS'(i);
      @(posedge clk);
      $display("%2d  | %12d | %12d | %12.4f | %12.4f", i, dout_re, dout_im, b2r(dout_re), b2r(
               dout_im));
    end
    $finish;
  end

  always @(posedge clk or negedge clk) begin
    $fdisplay(file, "%b,%b,%b,%b,%d,%12.1f,%12.1f,%b,%12.1f,%12.1f", clk, rst, start,
              input_valid, output_read_addr, b2r(din_re), b2r(din_im),
              output_ready, b2r(dout_re), b2r(dout_im));
  end

  function real b2r(input logic signed [FIXP_WIDTH-1:0] p);
    return $itor($signed(p)) / (1.0 * (1 << FIXP_Q));
  endfunction

  
endmodule
