`timescale 1ns/1ns

module z1top_adder (
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS
);

  wire [2:0] adder_operand1, adder_operand2;
  wire [3:0] adder_result;

  // First operand:  {SWITCHES[0], BUTTONS[1], BUTTONS[0]}
  assign adder_operand1 = {SWITCHES[0], BUTTONS[1:0]};
  // Second operand: {SWITCHES[1], BUTTONS[3], BUTTONS[2]}
  assign adder_operand2 = {SWITCHES[1], BUTTONS[3:2]};
  // Result: {LEDS[3], LEDS[2], LEDS[1], LEDS[0]}
  assign LEDS[3:0] = adder_result;
  assign LEDS[5:4] = 0;

  // Module instantation of the structural_adder logic   
  structural_adder user_adder(
    .a(adder_operand1),
    .b(adder_operand2),
    .sum(adder_result)
  );

endmodule
