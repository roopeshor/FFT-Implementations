`timescale 1ns / 1ps
module tb_fft ();

  logic clk, rst, start, input_valid, ready, done;
  complex_t din, dout_a, dout_b;

  parameter int N = 16;
  parameter int Q_FRAC = 8;

  fft_radix2 #(.N(N)) dut (.*);

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

      // 1. Shift 'i' by Q_FRAC (e.g., 8) to align the radix point.
      // 2. Cast to WIDTH (e.g., 16) to prevent Verilator width warnings.
      din = '{re: WIDTH'(i << Q_FRAC), im: WIDTH'(0)};

      // Use string formatting (%0d) to print the actual integer value of i
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
      // 1. Extract the raw bits and force the simulator to treat them as signed integers.
      // If you skip this, negative numbers will convert into massive positive floats.
      automatic logic signed [WIDTH-1:0] raw_re = dut.mem[i].re;
      automatic logic signed [WIDTH-1:0] raw_im = dut.mem[i].im;

      // 2. Cast to 'real' and divide by the fractional scale (2^Q_FRAC).
      automatic real float_re = real'(raw_re) / real'(1 << Q_FRAC);
      automatic real float_im = real'(raw_im) / real'(1 << Q_FRAC);

      // 3. Print both the raw integer and the calculated float
      $display("%2d  | %12d | %12d | %12.4f | %12.4f", i, raw_re, raw_im, float_re, float_im);
    end
    $finish;
  end
endmodule
