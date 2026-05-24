`timescale 1ns / 1ps
module tb_fft();

    logic clk, rst, start, input_valid, ready, done;
    complex_t din, dout_a, dout_b;

    parameter int N = 16;

    fft_radix2 #(.N(N))  dut (.*);

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

        wait(ready);
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        $display("--- Streaming Input Data ---");
        for (int i = 0; i < N; i++) begin
            input_valid = 1;
            // Native float assignment!
            din = '{re: i, im: 0.0}; 
            $display("i + 0j");
            @(posedge clk);
        end
        input_valid = 0; 

        wait(done);
        @(posedge clk);

        $display("--- Final FFT Output Spectrum ---");
        $display("Bin | Real (Float) | Imag (Float)");
        $display("---------------------------------");
    
        for (int i = 0; i < N; i++) begin
            // Directly read the shortreal from memory
            $display("%2d  | %12.4f | %12.4f", i, dut.mem[i].re, dut.mem[i].im);
        end
        $finish;
    end
endmodule