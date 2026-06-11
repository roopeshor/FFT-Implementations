// --- 3. Dynamic Twiddle Factor ROM ---
module Twiddle_ROM #(parameter STAGES=3, DW=16, FIXP_Q=10)(
  input  logic [STAGES-2:0] k,
  output logic signed [DW-1:0] w_re, w_im
);
  localparam N = 1 << STAGES;
  localparam HALF_N = N / 2;
  logic signed [DW-1:0] rom_re [0:HALF_N-1];
  logic signed [DW-1:0] rom_im [0:HALF_N-1];
  real theta;
  initial begin
    for(int i=0; i<HALF_N; i++) begin
      theta = -2.0 * 3.14159265358979323846 * real'(i) / real'(N);
      rom_re[i] = DW'($rtoi($cos(theta) * (1<<FIXP_Q)));
      rom_im[i] = DW'($rtoi($sin(theta) * (1<<FIXP_Q)));
    end
  end
  assign w_re = rom_re[k];
  assign w_im = rom_im[k];
endmodule
