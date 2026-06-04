`timescale 1ns / 1ps

module butterfly_structure #(
    parameter FIXP_WIDTH = 16,
    parameter FIXP_Q = 8
)(
    input  logic signed [FIXP_WIDTH-1:0] ar, ai, br, bi, wr, wi,
    output logic signed [FIXP_WIDTH-1:0] cr, ci, dr, di
);

    logic signed [2*FIXP_WIDTH-1:0] p_rrx, p_iix, p_rix, p_irx;
    logic signed [FIXP_WIDTH-1:0] p_rr, p_ii, p_ri, p_ir;
    logic signed [FIXP_WIDTH-1:0] bwr, bwi;

    // p_xy = b.x * w.y
    assign p_rrx = br * wr; 
    // fixed_mul #(.FIXP_WIDTH(FIXP_WIDTH), .FIXP_Q(FIXP_Q)) mult_rr (.a(br), .b(wr), .p(p_rr));
    assign p_iix = wi * bi; 
    // fixed_mul #(.FIXP_WIDTH(FIXP_WIDTH), .FIXP_Q(FIXP_Q)) mult_ii (.a(bi), .b(wi), .p(p_ii));
    assign p_rix = wi * br; 
    // fixed_mul #(.FIXP_WIDTH(FIXP_WIDTH), .FIXP_Q(FIXP_Q)) mult_ri (.a(br), .b(wi), .p(p_ri));
    assign p_irx = wr * bi; 
    // fixed_mul #(.FIXP_WIDTH(FIXP_WIDTH), .FIXP_Q(FIXP_Q)) mult_ir (.a(bi), .b(wr), .p(p_ir));

    assign p_rr = FIXP_WIDTH'(p_rrx >>> FIXP_Q);
    assign p_ii = FIXP_WIDTH'(p_iix >>> FIXP_Q);
    assign p_ri = FIXP_WIDTH'(p_rix >>> FIXP_Q);
    assign p_ir = FIXP_WIDTH'(p_irx >>> FIXP_Q);
    
    assign bwr = p_rr - p_ii; // fixed_sub #(.FIXP_WIDTH(FIXP_WIDTH)) sub_bwr (.a(p_rr), .b(p_ii), .c(bwr));
    assign bwi = p_ri + p_ir; // fixed_add #(.FIXP_WIDTH(FIXP_WIDTH)) add_bwi (.a(p_ri), .b(p_ir), .c(bwi));

    assign cr = ar + bwr; // fixed_add #(.FIXP_WIDTH(FIXP_WIDTH)) add_cr (.a(ar), .b(bwr), .c(cr));
    assign ci = ai + bwi; // fixed_add #(.FIXP_WIDTH(FIXP_WIDTH)) add_ci (.a(ai), .b(bwi), .c(ci));
    
    assign dr = ar - bwr; // fixed_sub #(.FIXP_WIDTH(FIXP_WIDTH)) sub_dr (.a(ar), .b(bwr), .c(dr));
    assign di = ai - bwi; // fixed_sub #(.FIXP_WIDTH(FIXP_WIDTH)) sub_di (.a(ai), .b(bwi), .c(di));

endmodule
