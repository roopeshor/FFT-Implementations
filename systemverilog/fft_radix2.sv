`timescale 1ns / 1ps
`include "structs.sv"
`include "twiddle_factor.sv"
`include "butterfly_structural.sv"

// -------------------------------------------------------------------------
// Floating-Point FFT Module
// -------------------------------------------------------------------------
module fft_radix2 #(
    parameter int N = 16,
    parameter int FP_WIDTH = 16,
    parameter int Q_FRAC = 8
) (
    input logic clk,
    input logic rst,
    input logic start,

    input logic input_valid,
    input complex_t din,

    output logic ready,
    output logic done,
    output complex_t mem[0:N-1]
);

  localparam int N_BITS = $clog2(N);
  localparam int STAGES = N_BITS;
  localparam int BF_PER_STAGE = N / 2;
  localparam int STEPS = STAGES * BF_PER_STAGE;
  localparam int BF_BITS = $clog2(BF_PER_STAGE);
  localparam int TWIDDLE_BITS = BF_BITS;
  localparam int STAGE_BITS = $clog2(STAGES);
  localparam int STEPS_BITS = $clog2(STEPS);

  typedef enum logic [1:0] {
    IDLE,
    LOAD,
    WRITE,
    DONE
  } state_t;
  state_t state;

  logic [N_BITS-1:0] load_cnt;
  logic [STEPS_BITS-1:0] step;

  logic [STAGE_BITS-1:0] stage;
  logic [BF_BITS-1:0] bf_idx;
  assign stage  = step[STEPS_BITS-1:BF_BITS];
  assign bf_idx = step[BF_BITS-1:0];

  logic [N_BITS-1:0] addr_a, addr_b;
  logic [ N_BITS-1:0] load_addr;
  logic [BF_BITS-1:0] twiddle_idx;
  complex_t w, a, b, c, d;

  genvar i;
  generate
    for (i = 0; i < N_BITS; i = i + 1) begin : rev_bits
      assign load_addr[i] = load_cnt[N_BITS-1-i];
    end
  endgenerate

  // Address Generation Logic
  logic [STAGES-1:0] mask;
  logic [STAGES-1:0] bf_pad = STAGES'(bf_idx);
  assign mask = STAGES'((32'd1 << 32'(stage)) - 32'd1);
  always_comb begin
    addr_a = ((bf_pad & ~mask) << 1) | (bf_pad & mask);
    addr_b = addr_a + STAGES'(32'd1 << 32'(stage));
    twiddle_idx = (STAGES - 1)'((bf_pad & mask) << (STAGES - 1 - 32'(stage)));
  end

  twiddle_factor #(.BF_BITS(BF_BITS)) tf1 (.twiddle_idx, .w);

  assign a = mem[addr_a];
  assign b = mem[addr_b];
  butterfly_structural bs1 (.a, .b, .w, .c, .d);

  // FSM
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
            if (load_cnt == N_BITS'(N - 1)) begin
              state <= WRITE;
              step  <= 0;
            end
            load_cnt <= load_cnt + 1;
          end
        end
        WRITE: begin
          mem[addr_a] <= c;
          mem[addr_b] <= d;
          if (step == STEPS_BITS'(STEPS - 1)) begin
            state <= DONE;
          end else begin
            step  <= step + 1;
            state <= WRITE;
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
      endcase
    end
  end
endmodule
