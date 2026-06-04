`timescale 1ns / 1ps
import DIT_radix2_inplace::*;

module fft_radix2 #(
    parameter N = 8,
    parameter FIXP_WIDTH = 16,
    parameter FIXP_Q = 10,
    parameter logic DEBUG = '0
) (
    input logic clk,
    input logic rst,
    input logic start,
    input logic input_valid,
    input logic signed [FIXP_WIDTH-1:0] din_re,
    input logic signed [FIXP_WIDTH-1:0] din_im,
    input logic [$clog2(N)-1:0] output_read_addr,

    output logic output_ready,
    output logic signed [FIXP_WIDTH-1:0] dout_re,
    output logic signed [FIXP_WIDTH-1:0] dout_im
);


  /**
  * Number of bits required in address access data points
  * Equal to lb(N)
  * Hence expects N to be of power of 2
  */
  localparam N_BITS = $clog2(N);

  /**
  * in 16pt, there are 4 stages (= number of bits in addr),
  * and 8 butterfly in each stage
  * and hene 4*8 compute counter required
  * The system takes N cycles to load data, STEP = Stages*BF_per_stage cycles to process it
  * Hence in total it takes: N + N*lb(N)/2 cycles to get complete data
  * Below numbers are for N = 16
  */
  localparam STAGES = N_BITS;  // 4
  localparam BF_PER_STAGE = N / 2;  // 8
  localparam COUNTS = STAGES * BF_PER_STAGE;  // 4 * 8 = 32
  localparam STAGE_BITS = $clog2(STAGES);  // 2
  localparam COUNTER = $clog2(COUNTS);  // 5 
  localparam COUNTER_FULLW = COUNTER + 1;  // 5 + 1= 6 (extra one to handle overflow)
  localparam TWIDDLE = $clog2(BF_PER_STAGE);  // 3

  typedef logic signed [FIXP_WIDTH-1:0] num_t;
  typedef logic [N_BITS-1:0] addr_t;
  // Internal memories
  num_t mem_re[0:N-1];
  num_t mem_im[0:N-1];


  // current cycle counter
  logic [COUNTER:0] counter;
  // auxially alias to parts of `counter`
  /**
  * For N=16, counter = 32
  * counter = [   4   |  3   |   2   |   1   |  0   ]
  *           <--- stage ---> <------ bf_idx ------>
  *                    <------- load_counter ------->  
  */

  /**
  * Current loop index in the stage. Used to generate bit reversed index to store
  * input data
  */
  addr_t load_counter;

  /**
  * Current FFT stage
  **/
  logic [STAGE_BITS-1:0] stage;

  /**
  * which butterfly is being processed in a given stage.
  * used to derive addr_a and addr_b (butterfly data index)
  **/
  logic [TWIDDLE-1:0] bf_idx;


  assign bf_idx = counter[TWIDDLE-1:0];
  assign stage = counter[COUNTER-1:TWIDDLE];
  assign load_counter = counter[N_BITS-1:0];


  /**
  * Addresses to the relavent data:
  * 
  * mem[addr_a]:  a ------ c -------> mem[addr_a]
  *                 \     /  
  *                  \   /   
  *                   \ /    
  *                    X     
  *                   / \   
  *                  /   \ 
  *                 /     \     W
  * mem[addr_b]:  b ---->- d --->---> mem[addr_b]
  *                     -1      
  */
  addr_t addr_a, addr_b;

  /**
  * Address of mem where input data (din) is stored
  */
  addr_t input_load_addr;

  /**
  * Index of twiddle factor used in Butterfly
  */
  logic [TWIDDLE-1:0] twiddle_idx;

  /**
  * auxillary wires to store intermediate data 
  */
  num_t wr, wi, ar, ai, br, bi, cr, ci, dr, di;

  assign ar = mem_re[addr_a];
  assign ai = mem_im[addr_a];
  assign br = mem_re[addr_b];
  assign bi = mem_im[addr_b];

  // Find bit reverse for load address
  bit_rev #(
      .BITS(N_BITS)
  ) br1 (
      .src (load_counter),
      .dest(input_load_addr)
  );

  address_generator #(
      .ADDR(N_BITS),
      .STAGE(STAGE_BITS),
      .TWIDDLE(TWIDDLE)
  ) ad1 (
      .bf_idx(bf_idx),
      .stage(stage),
      .addr_a(addr_a),
      .addr_b(addr_b),
      .twiddle_idx(twiddle_idx)
  );


  twiddle_factor #(
      .TWIDDLE(TWIDDLE),
      .FIXP_WIDTH(FIXP_WIDTH)
  ) tf1 (
      .twiddle_idx(twiddle_idx),
      .wr(wr),
      .wi(wi)
  );



  butterfly_structure #(
      .FIXP_WIDTH(FIXP_WIDTH),
      .FIXP_Q(FIXP_Q)
  ) bs1 (
      .ar(ar),
      .ai(ai),
      .br(br),
      .bi(bi),
      .wr(wr),
      .wi(wi),
      .cr(cr),
      .ci(ci),
      .dr(dr),
      .di(di)
  );

  // ========== FSM ========
  state_t state;

  // number of clocks required for computation
  localparam logic [COUNTER_FULLW-1:0] COMPUTE_LEN = COUNTER_FULLW'(N/2 * N_BITS);

  // max number of input mapped to full width of counter
  localparam logic [COUNTER_FULLW-1:0] FULL_N = COUNTER_FULLW'(N);
  
  initial begin
    // init block only for debugging
    if (DEBUG) begin
      $display("COMPUTE_LEN: %d, (%b)", COMPUTE_LEN, COMPUTE_LEN);
      $display("FULL_N: %d, (%b)", FULL_N, FULL_N);
    end
  end

  
  logic counter_reset_trigger;
  // reset on either overflow or when compute is going to start
  assign counter_reset_trigger = (state == COMPUTE && counter == COMPUTE_LEN) || (state == LOAD && counter == FULL_N);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      counter <= 0;
      // outputs
      output_ready <= 0;
      dout_re <= 0;
      dout_im <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (input_valid) begin
            mem_re[input_load_addr] <= din_re;
            mem_im[input_load_addr] <= din_im;
            state <= LOAD;
            if (DEBUG)
              $display(
                  "========%0f======== IDLE: input_valid, setting first loc, going to LOAD",
                  $realtime
              );
          end
        end
        LOAD: begin
          if (counter != FULL_N) begin
            if (DEBUG) $display("========%0f======== LOAD: counter: %d != %d, saving input", $realtime, counter, FULL_N);
            mem_re[input_load_addr] <= din_re;
            mem_im[input_load_addr] <= din_im;
          end else begin
            if (DEBUG) $display("========%0f======== LOAD: going to compute", $realtime);
            state <= COMPUTE;
            // sample computes only in next cycle
          end
        end
        COMPUTE: begin
          if (counter != COMPUTE_LEN) begin
            if (DEBUG)
              $display("========%0f======== COMPUTE: counter: %d != %d, saving BF output", $realtime, counter, COMPUTE_LEN);
            mem_re[addr_b] <= dr;
            mem_im[addr_b] <= di;
            mem_re[addr_a] <= cr;
            mem_im[addr_a] <= ci;
          end else begin
            if (DEBUG)
              $display(
                  "========%0f======== COMPUTE: CTR == F, output ready, going to DONE", $realtime
              );
            output_ready <= '1;
            state <= DONE;
          end
        end
        DONE: begin
          if (DEBUG) $display("Writing output from: %d", output_read_addr);
          dout_im <= mem_im[output_read_addr];
          dout_re <= mem_re[output_read_addr];
        end
      endcase

      // counter driver
      if (start) begin
        if (counter_reset_trigger) begin
          if (DEBUG)
            $display("========%0f======== CTR DRIVER: reseting ctr", $realtime);
          counter <= 0;
        end else begin
          counter <= counter + 1;
        end
      end
    end
  end
endmodule
