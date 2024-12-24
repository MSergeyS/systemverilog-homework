//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module fibonacci
(
  input               clk,
  input               rst,
  output logic [15:0] num
);

  logic [15:0] num2;

  always_ff @ (posedge clk)
    if (rst)
      { num, num2 } <= { 16'd1, 16'd1 };
    else
      { num, num2 } <= { num2, num + num2 };

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module fibonacci_2
(
  input               clk,
  input               rst,
  output logic [15:0] num,
  output logic [15:0] num2
);

  // Task:
  // Implement a module that generates two fibonacci numbers per cycle

  // Числа Фибоначчи — это последовательность чисел, которые задаются по определённому правилу.
  // Оно звучит так: каждое следующее число равно сумме двух предыдущих.
  // Первые два числа заданы сразу и равны 0 и 1.
  // Вот как выглядит последовательность Фибоначчи:
  // 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, … , ∞

  logic [15:0] num3;
  logic [15:0] num4;

  always_ff @ (posedge clk)
    if (rst)
      { num, num2} <= { 16'd1, 16'd1};
    else
      { num, num2} <= { num2 + num, num2 + num2 + num};

endmodule
