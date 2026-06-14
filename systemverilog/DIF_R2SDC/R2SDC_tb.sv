`timescale 1ns / 1ps

module R2SDC_tb;

  // ---------------------------------------------------------
  // 1. Parameters & Signals
  // ---------------------------------------------------------
  localparam int STAGES = 2;
  localparam int DW = 16;
  localparam int FIXP_Q = 10;

  localparam int N = 1 << STAGES;
  localparam USE_ARS = '0;
  // scale by N to account for arithmetic round off between butterfly stages

  localparam real SCALE = USE_ARS ? (1 << FIXP_Q) / N : 1 << FIXP_Q;

  logic clk;
  logic rst;
  logic [2*DW-1:0] din;
  logic in_valid;

  logic [2*DW-1:0] dout;
  logic out_valid;

  // Unpacked output signals for easy waveform viewing
  logic signed [DW-1:0] out_re;
  logic signed [DW-1:0] out_im;
  logic signed [DW-1:0] in_re;
  logic signed [DW-1:0] in_im;
  assign {out_re, out_im} = dout;
  assign din = {in_re, in_im};
  // ---------------------------------------------------------
  // 2. DUT Instantiation
  // ---------------------------------------------------------
  R2SDC #(
      .STAGES(STAGES),
      .DW(DW),
      .FIXP_Q(FIXP_Q),
      .USE_ARS(USE_ARS)
  ) dut (
      .clk(clk),
      .rst(rst),
      .din(din),
      .in_valid(in_valid),
      .dout(dout),
      .out_valid(out_valid)
  );

  // ---------------------------------------------------------
  // 3. Clock Generation (100 MHz)
  // ---------------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // ---------------------------------------------------------
  // 4. Stimulus Engine
  // ---------------------------------------------------------
  int x, y;
  initial begin

    // Initialize State
    rst = 1;
    in_valid = 0;
    din = 0;

    // Wait for Vivado Global Set/Reset (GSR) to complete
    #100;

    // Hold local reset
    repeat (5) @(posedge clk);
    rst = 0;
    @(posedge clk);

    // Wait a few cycles before starting
    repeat (2) @(posedge clk);

    // Align to negedge to guarantee setup/hold times in gate-level sim
    @(negedge clk);

    for (int i = 0; i < N; i++) begin
      x = i + 1;
      y = i;
      in_valid = '1;
      in_re = DW'(x << FIXP_Q);
      in_im = DW'(y << FIXP_Q);
      din = {in_re, in_im};
      $display("x[%2d] = %8.3f + %8.3fj", i, x, y);
      @(negedge clk);
    end

    $display("\n\nOutput");
    $display("Time\t\tOut_Re\tOut_Im");
    $display("--------------------------------");

    // Drop valid signal after the frame is pushed
    in_valid = 0;
    din = 0;

    // Wait for the pipeline to empty and outputs to generate
    // Pipeline latency is roughly N + N/2 + ... cycles. Waiting 3*N is safe.
    @(negedge out_valid);
    @(negedge clk);

    $display("Simulation Complete.");
    $finish;
  end

  // ---------------------------------------------------------
  // 5. Output Monitor
  // ---------------------------------------------------------
  int  out_cnt = 0;
  real re_out_arr  [N];
  real im_out_arr  [N];
  int  rev_idx;
  initial begin
    forever begin
      @(posedge clk);
      if (out_valid) begin
        $display("%0t\t%f\t%f", $time, rscale(out_re), rscale(out_im));
        re_out_arr[out_cnt] = rscale(out_re);
        im_out_arr[out_cnt] = rscale(out_im);
        out_cnt++;

        if (out_cnt == N) begin
          $display("\nReordered Output (Natural Index):");
          $display("Index\tOut_Re\t\tOut_Im");
          $display("--------------------------------");
          for (int i = 0; i < N; i++) begin
            rev_idx = bit_reverse(i, STAGES);
            $display("X[%2d]\t%f\t%f", i, re_out_arr[rev_idx], im_out_arr[rev_idx]);
          end
        end
      end
    end
  end

  function real rscale(input logic signed [DW-1:0] inx);
    return real'(inx) / SCALE;
  endfunction

  function automatic int bit_reverse(int idx, int bits);
    int rev = 0;
    for (int i = 0; i < bits; i++) begin
      rev = (rev << 1) | (idx & 1);
      idx = idx >> 1;
    end
    return rev;
  endfunction
endmodule
