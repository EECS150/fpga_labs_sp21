`timescale 1ns/1ns

module behavioral_adder (
  input [2:0] a,
  input [2:0] b,
  output [3:0] sum
);
  assign sum = a + b;
endmodule
