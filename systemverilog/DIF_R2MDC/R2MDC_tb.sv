`timescale 1ns / 1ps

module R2MDC_tb;

    // Parameters
    localparam STAGES = 3;
    localparam N = 1 << STAGES;
    localparam HALF_N = N / 2;
    localparam DW = 16;
    localparam FIXP_Q = 10;
    localparam real SCALE = 1 << FIXP_Q; 

    // Signals
    logic clk;
    logic rst;
    logic in_valid;
    logic signed [DW-1:0] din_re, din_im;
    
    logic out_valid;
    logic signed [DW-1:0] out0_re, out0_im;
    logic signed [DW-1:0] out1_re, out1_im;

    // Instantiate the DUT
    R2MDC #(
        .STAGES(STAGES),
        .DW(DW),
        .FIXP_Q(FIXP_Q)
    ) dut (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .din_re(din_re),
        .din_im(din_im),
        .out_valid(out_valid),
        .out0_re(out0_re), .out0_im(out0_im),
        .out1_re(out1_re), .out1_im(out1_im)
    );

    // ---------------------------------------------------------
    // 1. Clock Generation
    // ---------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // 2. Stimulus Engine
    // ---------------------------------------------------------
    int x,y;
    initial begin
    #100;
        rst = 1;
        in_valid = 0;
        din_re = 0;
        din_im = 0;
        
        repeat(5) @(posedge clk);
        rst = 0;
        @(posedge clk);
        $display("=================================================");
        $display("   Injecting 8-Point Serial Data: x[n] = n");
        $display("=================================================\n");
        
        for (int i = 0; i < N; i++) begin
          x = i+1;
          y = i;
          in_valid = 1'b1;
          din_re = DW'(x << FIXP_Q); 
          din_im = DW'(y << FIXP_Q);
          $display("x[%2d] = %8.3f + %8.3fj", i, x, y);
          @(posedge clk);
        end

        in_valid = 1'b0;
        din_re = '0;
        din_im = '0;

        // Wait to catch all outputs
        repeat(N) @(posedge clk);
        $finish;
    end

    // ---------------------------------------------------------
    // 3. Bit-Reversal Helper Function
    // ---------------------------------------------------------
    function automatic logic [STAGES-1:0] bit_rev(input logic [STAGES-1:0] val);
        logic [STAGES-1:0] rev;
        for (int i = 0; i < STAGES; i++) begin
            rev[i] = val[STAGES-1-i];
        end
        return rev;
    endfunction

    // ---------------------------------------------------------
    // 4. Output Monitor (Dual Display)
    // ---------------------------------------------------------
    real frame_re [0:N-1];
    real frame_im [0:N-1];
    int pair_cnt = 0;

    always @(posedge clk) begin
        if (out_valid) begin
            
            // 4a. Convert current hardware outputs to float
            automatic real o0_r = rscale(out0_re);
            automatic real o0_i = rscale(out0_im);
            automatic real o1_r = rscale(out1_re);
            automatic real o1_i = rscale(out1_im);

            // Derive true indices to show exactly what X() values are emerging
            automatic logic [STAGES-1:0] val_concat = {pair_cnt[STAGES-2:0], 1'b0};
            automatic logic [STAGES-1:0] idx0 = bit_rev(val_concat);
            automatic logic [STAGES-1:0] idx1 = idx0 + HALF_N;

            // Print the RAW emerging pairs immediately
            if (pair_cnt == 0) $display("--- Hardware Output (Bit-Reversed Pairs) ---");
            $display("Time %0t | Cycle %0d | X(%0d) = %8.3f + %8.3fj  |  X(%0d) = %8.3f + %8.3fj", 
                      $time, pair_cnt, idx0, o0_r, o0_i, idx1, o1_r, o1_i);

            // Buffer them for the final sorted print
            frame_re[idx0] = o0_r;
            frame_im[idx0] = o0_i;
            frame_re[idx1] = o1_r;
            frame_im[idx1] = o1_i;

            pair_cnt++;

            // 4b. Once N/2 pairs arrive, the frame is complete. Print sorted array.
            if (pair_cnt == HALF_N) begin
                $display("\n=================================================");
                $display("       Sorted (Natural Order) FFT Frame");
                $display("=================================================");
                for (int i = 0; i < N; i++) begin
                    $display("  X(%2d) = %8.3f + %8.3fj", i, frame_re[i], frame_im[i]);
                end
                $display("=================================================\n");
                
                // Reset counter for the next continuous incoming frame
                pair_cnt = 0;
            end
        end
    end
  function real rscale(input logic signed [DW-1:0] inx);
    return real'(inx) / SCALE;
  endfunction
endmodule
