`include "fixed_arith.sv"
module butterfly_structural #(
    parameter int WIDTH = 16,
    parameter int Q_FRAC = 8
)(
    input  complex_t a,
    input  complex_t b,
    input  complex_t w,
    output complex_t c,
    output complex_t d
);

    logic signed [WIDTH-1:0] p_rr, p_ii, p_ri, p_ir;
    logic signed [WIDTH-1:0] bw_re, bw_im;
    // p_xy = b.x * w.y
    fixed_mul #(.WIDTH(WIDTH), .Q_FRAC(Q_FRAC)) mult_rr (.a(b.re), .b(w.re), .p(p_rr));
    fixed_mul #(.WIDTH(WIDTH), .Q_FRAC(Q_FRAC)) mult_ii (.a(b.im), .b(w.im), .p(p_ii));
    fixed_mul #(.WIDTH(WIDTH), .Q_FRAC(Q_FRAC)) mult_ri (.a(b.re), .b(w.im), .p(p_ri));
    fixed_mul #(.WIDTH(WIDTH), .Q_FRAC(Q_FRAC)) mult_ir (.a(b.im), .b(w.re), .p(p_ir));

    // bw = (p_rr - p_ii) + j(p_ri + p_ir)
    fixed_sub #(.WIDTH(WIDTH)) sub_bw_re (.a(p_rr), .b(p_ii), .c(bw_re));
    fixed_add #(.WIDTH(WIDTH)) add_bw_im (.a(p_ri), .b(p_ir), .c(bw_im));

    // c.re = a.re + bw_re
    fixed_add #(.WIDTH(WIDTH)) add_c_re (.a(a.re), .b(bw_re), .c(c.re));
    // c.im = a.im + bw_im
    fixed_add #(.WIDTH(WIDTH)) add_c_im (.a(a.im), .b(bw_im), .c(c.im));
    
    // d.re = a.re - bw_re
    fixed_sub #(.WIDTH(WIDTH)) sub_d_re (.a(a.re), .b(bw_re), .c(d.re));
    // d.im = a.im - bw_im
    fixed_sub #(.WIDTH(WIDTH)) sub_d_im (.a(a.im), .b(bw_im), .c(d.im));

endmodule