`timescale 1ns/1ns

module structural_adder_tb();
  parameter N = 32;

  reg clock;
  initial clock = 0;
  always #(4) clock <= ~clock;

  reg  [N-1:0] operand1, operand2;
  wire [N:0] adder_output;

  // Note: this assumes that you have the parameter N in your structural_adder code
  // (the bitwidth of your operands)
  structural_adder #(.N(32)) dut (
    .a(operand1),
    .b(operand2),
    .sum(adder_output)
  );

  initial begin
    #0;
    operand1 = 32'd1000;
    operand2 = 32'd1000;
    #100;
    operand1 = 32'd2000;
    #300;
    operand2 = 32'd3000;
    #500;
    $finish();
  end

endmodule
