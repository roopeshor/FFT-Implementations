`timescale 1ns / 1ps

// ==============================================================================
// TOP LEVEL: Radix-2 Single-Path Delay Commutator (SDC) FFT
// ==============================================================================
module R2SDC #(
    parameter STAGES  = 3,   // Number of FFT stages (N = 2^STAGES)
    parameter DW      = 16,  // Data width per component (Real/Imag)
    parameter FIXP_Q  = 10,  // Fractional bits for twiddle factors
    parameter USE_ARS = '0   // Whether to use arithmetic shifting
) (
    input  logic            clk,
    input  logic            rst,
    input  logic [2*DW-1:0] din,       // [Real: Upper DW, Imag: Lower DW]
    input  logic            in_valid,
    output logic [2*DW-1:0] dout,
    output logic            out_valid
);

  // Interconnect arrays to daisy-chain the stages together
  logic [2*DW-1:0] stage_data [0:STAGES];
  logic            stage_valid[0:STAGES];

  // Bind input ports to the start of the pipeline
  assign stage_data[STAGES] = din;
  assign stage_valid[STAGES] = in_valid;

  // Generate cascaded stages
  // Data flows from STAGES-1 (largest delay) down to 0 (delay of 1)
  genvar g;
  generate
    for (g = STAGES - 1; g >= 0; g--) begin : gen_stages
      R2SDC_Stage #(
          .STAGE_IDX(g),
          .DW(DW),
          .FIXP_Q(FIXP_Q),
          .USE_ARS(USE_ARS)
      ) stage_inst (
          .clk(clk),
          .rst(rst),
          .din(stage_data[g+1]),
          .in_valid(stage_valid[g+1]),
          .dout(stage_data[g]),
          .out_valid(stage_valid[g])
      );
    end
  endgenerate

  // Bind output ports to the end of the pipeline
  assign out_valid = stage_valid[0];
  assign dout = stage_data[0];

endmodule
