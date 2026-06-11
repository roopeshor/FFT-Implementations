`timescale 1ns/1ps
// --- 6. The 2x2 MDC Commutator Switch and delay adjuster ---
module Commutator #(parameter DW=16, D=1, CNT_W=1)(
    input  logic clk, rst, in_valid, w_cross,
    input  logic [CNT_W-1:0] in_cnt,
    input  logic signed [DW-1:0] in0_re, in0_im, in1_re, in1_im,
    output logic out_valid,
    output logic [CNT_W-1:0] out_cnt,
    output logic signed [DW-1:0] out0_re, out0_im, out1_re, out1_im
);

/**
 * Diagram: 
 *           ←— D ——→
 * in_valid —⯀⯀⯀⯀⯀⯀———————————————————— out_valid
 *      in0 —————————————————┊—————————┊————— out0
 *                           ┊ \     / ┊ sw0 
 *                           ┊  \   /  ┊ 
 *                           ┊   \ /   ┊ 
 *                           ┊    ╳    ┊ 
 *                           ┊   / \   ┊ 
 *                           ┊  /   \  ┊     
 *                    dly_in1┊ /     \ ┊ sw1 
 *      in1 —⯀⯀⯀⯀⯀⯀————————┊—————————┊————— out1
 *           ←— D ——→             ↑
 *                             w_cross
 *                             0 -> —
 *                             1 -> ╳
 *                             
 * in_cnt   —⯀⯀⯀⯀⯀⯀———————————————————— out_cnt
 *           ←— D ——→
 * 
*/
    logic signed [DW-1:0] dly_in1_re, dly_in1_im;
    ////// pre delay
    Delay_pipe #(.DW(DW), .CYCLES(D)) pre_r (.clk(clk), .rst(rst), .en(1'b1), .d(in1_re), .q(dly_in1_re));
    Delay_pipe #(.DW(DW), .CYCLES(D)) pre_i (.clk(clk), .rst(rst), .en(1'b1), .d(in1_im), .q(dly_in1_im));

    logic signed [DW-1:0] sw0_re, sw0_im, sw1_re, sw1_im;

    ////// switch
    always_comb begin
        if (w_cross) begin
            sw0_re = dly_in1_re; sw0_im = dly_in1_im;
            sw1_re = in0_re;     sw1_im = in0_im;
        end else begin
            sw0_re = in0_re;     sw0_im = in0_im;
            sw1_re = dly_in1_re; sw1_im = dly_in1_im;
        end
    end
    // Delay_pipe #(.DW(DW), .CYCLES(D)) post_r (.clk(clk), .rst(rst), .en(1'b1), .d(sw0_re), .q(out0_re));
    // Delay_pipe #(.DW(DW), .CYCLES(D)) post_i (.clk(clk), .rst(rst), .en(1'b1), .d(sw0_im), .q(out0_im));
    assign out1_re = sw1_re;
    assign out1_im = sw1_im;
    assign out0_re = sw0_re;
    assign out0_im = sw0_im;
    ////// delay control singals
    Delay_pipe #(.DW(1 + CNT_W), .CYCLES(D)) ctrl_pipe (
        .clk(clk), .rst(rst), .en(1'b1),
        .d({in_valid, in_cnt}),
        .q({out_valid, out_cnt})
    );
endmodule
