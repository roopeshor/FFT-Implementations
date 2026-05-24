`timescale 1ns / 1ps
`include "structs_float.sv"
`include "twiddle_factor_float.sv"

// -------------------------------------------------------------------------
// Floating-Point FFT Module
// -------------------------------------------------------------------------
module fft_radix2 #(
    parameter int N = 16
)(
    input logic clk,
    input logic rst,
    input logic start,

    input logic input_valid,
    input complex_t din,

    output logic ready,
    output logic done,
    output complex_t dout_a,
    output complex_t dout_b
);

  localparam int N_BITS = $clog2(N);
  localparam int STAGES = N_BITS;
  localparam int BF_PER_STAGE = N / 2;
  localparam int STEPS = STAGES * BF_PER_STAGE;
  localparam int BF_BITS = $clog2(BF_PER_STAGE);
  localparam int TWIDDLE_BITS = BF_BITS;
  localparam int STAGE_BITS = $clog2(STAGES);
  localparam int STEPS_BITS = $clog2(STEPS);

  typedef enum logic [2:0] {
    IDLE,
    LOAD,
    COMP_READ,
    COMP_WRITE,
    DONE
  } state_t;
  state_t state;

  complex_t mem[0:N-1];
  logic [N_BITS-1:0] load_cnt;
  logic [STEPS_BITS-1:0] step;

  logic [STAGE_BITS-1:0] stage;
  logic [BF_BITS-1:0] bf_idx;
  assign stage  = step[STEPS_BITS-1:BF_BITS];
  assign bf_idx = step[BF_BITS-1:0];

  logic [N_BITS-1:0] addr_a, addr_b;
  logic [ N_BITS-1:0] load_addr;
  logic [BF_BITS-1:0] twiddle_idx;

  genvar i;
  generate
    for (i = 0; i < N_BITS; i = i + 1) begin : rev_bits
      assign load_addr[i] = load_cnt[N_BITS-1-i];
    end
  endgenerate

  complex_t w, a, b, c, d;

  // ---------------------------------------------------------------------
  // Twiddle Factor ROM (Floating Point Literals)
  // ---------------------------------------------------------------------
  twiddle_factor #(
      .BF_BITS(BF_BITS)
  ) tf1 (
      .twiddle_idx(twiddle_idx),
      .w(w)
  );

  // ---------------------------------------------------------------------
  // Address Generation Logic
  // ---------------------------------------------------------------------
  logic [STAGES-1:0] mask;
  logic [STAGES-1:0] bf_pad = STAGES'(bf_idx);
  // 32'(stage) tells Verilator to treat the 2-bit variable as a 32-bit int for the math
  // STAGES'(...) explicitly casts the final mask down to exactly 4 bits
  assign mask = STAGES'((32'd1 << 32'(stage)) - 32'd1);

  always_comb begin

    addr_a = ((bf_pad & ~mask) << 1) | (bf_pad & mask);

    addr_b = addr_a + STAGES'(32'd1 << 32'(stage));

    twiddle_idx = (STAGES - 1)'((bf_pad & mask) << (STAGES - 1 - 32'(stage)));
  end

  // ---------------------------------------------------------------------
  // Combinational Floating-Point Butterfly
  // ---------------------------------------------------------------------
  real bw_re, bw_im;

  always_comb begin
    a = mem[addr_a];
    b = mem[addr_b];

    // Native floating point multiplication
    bw_re = (b.re * w.re) - (b.im * w.im);
    bw_im = (b.re * w.im) + (b.im * w.re);

    // Native floating point addition/subtraction (no scaling required)
    c.re = a.re + bw_re;
    c.im = a.im + bw_im;

    d.re = a.re - bw_re;
    d.im = a.im - bw_im;
  end

  // Assign outputs
  assign dout_a = mem[addr_a];
  assign dout_b = mem[addr_b];

  // ---------------------------------------------------------------------
  // Control FSM
  // ---------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state    <= IDLE;
      ready    <= 1'b1;
      done     <= 1'b0;
      load_cnt <= 0;
      step     <= 0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            state <= LOAD;
            ready <= 1'b0;
            load_cnt <= 0;
          end
        end
        LOAD: begin
          if (input_valid) begin
            mem[load_addr] <= din;
            if (load_cnt == N_BITS'(N-1)) begin
              state <= COMP_READ;
              step  <= 0;
            end
            load_cnt <= load_cnt + 1;
          end
        end
        COMP_READ: begin
          state <= COMP_WRITE;
        end
        COMP_WRITE: begin
          mem[addr_a] <= c;
          mem[addr_b] <= d;

          if (step == STEPS_BITS'(STEPS-1)) begin
            state <= DONE;
          end else begin
            step  <= step + 1;
            state <= COMP_READ;
          end
        end
        DONE: begin
          done  <= 1'b1;
          ready <= 1'b1;
          if (start) begin
            state <= LOAD;
            ready <= 1'b0;
          end
        end
        default: done <= 1'b0;
      endcase
    end
  end
endmodule
