//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101

    logic path_true;

    always_ff @(posedge clk)
    begin
      if (rst)
        begin
          path_true <= 1'b0;
        end
      else if (a)
        begin
          path_true <= ~path_true;
        end
    end

    assign b = path_true & a;

    // можно написать ввиде конечного автомата (это мой вариант решение)
    // // States
    // typedef enum logic
    // {
    //   st_first   = 1'b0,
    //   st_second  = 1'b1
    // }  statetype_t;
    // statetype_t state, new_state;

    // // State transition logic  (логика переходоа конечного автомата)
    // always_comb
    //   begin
    //     new_state = state;

    //     case (state)
    //       st_first   : if (a) new_state = st_second;
    //       st_second  : if (a) new_state = st_first;
    //     endcase

    //   // verilator lint_on  CASEINCOMPLETE
    //   end

    // // Output logic (обновление выходов)
    // assign b = a & (state == st_second);

    // // обновление состояния
    // always_ff @ (posedge clk)
    //   if (rst)
    //     state <= st_first;
    //   else
    //     state <= new_state;

endmodule
