// --- 2. 1-Cycle Latency Complex Multiplier ---
module Complex_Mul #(parameter DW=16, FIXP_Q=10)(
    input  logic clk,
    input  logic signed [DW-1:0] ar, ai, br, bi,
    output logic signed [DW-1:0] cr, ci
);
    logic signed [2*DW-1:0] p_rr, p_ii, p_ri, p_ir;
    always_ff @(posedge clk) begin
        p_rr <= ar * br;
        p_ii <= ai * bi;
        p_ri <= ar * bi;
        p_ir <= ai * br;
    end
    assign cr = DW'((p_rr - p_ii) >>> FIXP_Q);
    assign ci = DW'((p_ri + p_ir) >>> FIXP_Q);
endmodule
