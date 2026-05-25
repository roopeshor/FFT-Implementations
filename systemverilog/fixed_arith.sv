module fixed_add #(
    parameter int WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] a,
    input  logic signed [WIDTH-1:0] b,
    output logic signed [WIDTH-1:0] c
);

  logic signed [WIDTH:0] full_sum;

  localparam signed [WIDTH-1:0] MAX_VAL = (1 << (WIDTH - 1)) - 1;
  localparam signed [WIDTH-1:0] MIN_VAL = -(1 << (WIDTH - 1));

  always_comb begin
    full_sum = a + b;

    // clamping
    if (full_sum > (WIDTH + 1)'(MAX_VAL)) begin
      c = MAX_VAL;
    end else if (full_sum < (WIDTH + 1)'(MIN_VAL)) begin
      c = MIN_VAL;
    end else begin
      c = WIDTH'(full_sum);
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

  always_comb begin
    full_p = a * b;

    p = WIDTH'(full_p >>> Q_FRAC);
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
    full_sub = a - b;

    if (full_sub > (WIDTH + 1)'(MAX_VAL)) c = MAX_VAL;
    else if (full_sub < (WIDTH + 1)'(MIN_VAL)) c = MIN_VAL;
    else c = WIDTH'(full_sub);
  end
endmodule
