module fixed_add #(
    parameter int WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] a,
    input  logic signed [WIDTH-1:0] b,
    output logic signed [WIDTH-1:0] c
);

  // 1. Extra bit to catch the overflow/underflow
  logic signed [WIDTH:0] full_sum;

  // 2. Define the exact clipping bounds for the target width
  localparam signed [WIDTH-1:0] MAX_VAL = (1 << (WIDTH - 1)) - 1;
  localparam signed [WIDTH-1:0] MIN_VAL = -(1 << (WIDTH - 1));

  always_comb begin
    // Perform the addition in the wider space
    full_sum = a + b;

    // 3. Hardware multiplexers to clamp the output
    if (full_sum > (WIDTH + 1)'(MAX_VAL)) begin
      c = MAX_VAL;  // Positive Overflow -> Clamp to Max
    end else if (full_sum < (WIDTH + 1)'(MIN_VAL)) begin
      c = MIN_VAL;  // Negative Overflow -> Clamp to Min
    end else begin
      c = WIDTH'(full_sum);  // Safe to cast, no overflow
    end
  end

endmodule

module fixed_mul #(
    parameter int WIDTH  = 16,
    parameter int Q_FRAC = 8
) (
    input  logic signed [WIDTH-1:0] a,
    input  logic signed [WIDTH-1:0] b,
    output logic signed [WIDTH-1:0] p
);

  logic signed [2*WIDTH-1:0] full_p;
  logic signed [2*WIDTH-1:0] rounded_p;

  always_comb begin
    // 1. Raw double-width multiplication
    full_p = a * b;

    // 2. Add Half-LSB for Round-Half-Up
    // In Q8.8, Q_FRAC-1 is 7. (1 << 7) is exactly 0.5 in the discarded fractional space.
    rounded_p = full_p + (1 << (Q_FRAC - 1));

    // 3. Shift and safely cast back to WIDTH
    p = WIDTH'(rounded_p >>> Q_FRAC);
  end

endmodule

module fixed_sub #(
    parameter int WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] a,
    input  logic signed [WIDTH-1:0] b,
    output logic signed [WIDTH-1:0] c
);
  logic signed [WIDTH:0] full_sub;
  localparam signed [WIDTH-1:0] MAX_VAL = (1 << (WIDTH - 1)) - 1;
  localparam signed [WIDTH-1:0] MIN_VAL = -(1 << (WIDTH - 1));

  always_comb begin
    full_sub = a - b;  // Only this line changes from the adder

    if (full_sub > (WIDTH + 1)'(MAX_VAL)) c = MAX_VAL;
    else if (full_sub < (WIDTH + 1)'(MIN_VAL)) c = MIN_VAL;
    else c = WIDTH'(full_sub);
  end
endmodule
