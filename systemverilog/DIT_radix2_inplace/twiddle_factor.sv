// --- 3. Dynamic Twiddle Factor ROM ---
module twiddle_factor #(parameter TWIDDLE=3, FIXP_WIDTH=16, FIXP_Q=10)(
  input  logic [TWIDDLE-1:0] twiddle_idx,
  output logic signed [FIXP_WIDTH-1:0] wr, wi
);
  localparam N = 1 << (TWIDDLE + 1);
  localparam HALF_N = N / 2;
  logic signed [FIXP_WIDTH-1:0] rom_re [0:HALF_N-1];
  logic signed [FIXP_WIDTH-1:0] rom_im [0:HALF_N-1];
  real theta;
  initial begin
    for(int i=0; i<HALF_N; i++) begin
      theta = -2.0 * 3.14159265358979323846 * real'(i) / real'(N);
      rom_re[i] = FIXP_WIDTH'($rtoi($cos(theta) * (1<<FIXP_Q)));
      rom_im[i] = FIXP_WIDTH'($rtoi($sin(theta) * (1<<FIXP_Q)));
    end
  end
  assign wr = rom_re[twiddle_idx];
  assign wi = rom_im[twiddle_idx];
endmodule
