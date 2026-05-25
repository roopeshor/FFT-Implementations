`timescale 1ns / 1ps
parameter int N = 16;
parameter int Q_FRAC = 8;
module tb_fft ();

  logic clk, rst, start, input_valid, ready, done;
  complex_t din;
  complex_t mem [0:N-1];


  fft_radix2 #(
      .N(N)
  ) dut (
      .clk,
      .rst,
      .start,
      .input_valid,
      .ready,
      .done,
      .din,
      .mem
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst = 1;
    start = 0;
    input_valid = 0;
    din = '{re: 0.0, im: 0.0};

    @(posedge clk);
    rst = 0;
    @(posedge clk);

    wait (ready);
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;

    $display("--- Streaming Input Data ---");
    for (int i = 0; i < N; i++) begin
      input_valid = 1;
      // Shift by Q_FRAC to align the radix point.
      din = '{re: WIDTH'(i << Q_FRAC), im: WIDTH'(0)};
      $display("Input: %0d.0 + 0j", i);
      @(posedge clk);
    end

    input_valid = 0;

    wait (done);
    @(posedge clk);

    $display("--- Final FFT Output Spectrum ---");
    $display("Bin | Real (Fixed) | Imag (Fixed) | Real (Float) | Imag (Float)");
    $display("---------------------------------------------------------------");

    for (int i = 0; i < N; i++) begin
      automatic logic signed [WIDTH-1:0] raw_re = mem[i].re;
      automatic logic signed [WIDTH-1:0] raw_im = mem[i].im;

      // Cast to real and divide by the fractional scale (2^Q_FRAC).
      automatic real float_re = real'(raw_re) / real'(1 << Q_FRAC);
      automatic real float_im = real'(raw_im) / real'(1 << Q_FRAC);

      $display("%2d  | %12d | %12d | %12.4f | %12.4f", i, raw_re, raw_im, float_re, float_im);
    end
    $finish;
  end
endmodule
