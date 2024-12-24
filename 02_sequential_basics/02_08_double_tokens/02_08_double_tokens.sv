//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output logic b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

    // решение из разбора д/з
    logic [7:0] cnt;

    // т.к. в задании сказано - поднимать флаг, если "1" > 200 => флаг поднимаем,
    // когда cnt > 200.
    // Но также всё работает при поднятии флага при cnt >= 200.
    always_ff @ (posedge clk)
        if (rst)
            overflow <= 1'b0;
        else if (cnt == 'd200 & a)
            overflow <= 1'b1;

    always_ff @(posedge clk)
      if (rst)
        begin
          cnt <= 'd0;
          b   <= 'b0;
        end
      else if (~overflow)
        if (a)
          begin
            cnt <= cnt + 'd1;
            b   <= 'b1;
          end
        else
          if (cnt >'d0)
            begin
              cnt <= cnt - 'd1;
              b   <= 'b1;
            end
          else
            b   <= 'b0;

    // // моё вариант решения (использовал конечный автомат)
    // logic [8:0]counter;  // счётчик единиц, которые ещё надо выставить на входе b

    // // States
    // typedef enum logic[1:0]
    // {
    //   st_stop      = 2'b00,
    //   st_increment = 2'b01,
    //   st_decrement = 2'b10,
    //   st_overflow  = 2'b11
    // } statetype_t;
    // statetype_t state, new_state;

    // // State transition logic  (логика переходоа конечного автомата)
    // always_comb
    //   begin
    //     new_state = state;

    //     case (state)
    //       st_stop      : if ( a) new_state = st_increment;
    //       st_increment : if (~a) new_state = st_decrement;
    //                      else if (counter > 'd199) new_state = st_overflow;
    //       st_decrement : if ( a) new_state = st_increment;
    //                      else if ( counter == 'd1) new_state = st_stop;
    //     endcase
    //   end

    // // Output logic (обновление выходов)
    // assign b = (state == st_decrement) | (state == st_increment);
    // assign overflow = (state == st_overflow);

    // // обновление состояния
    // always_ff @ (posedge clk)
    //   if (rst)
    //     state <= st_stop;
    //   else
    //     state <= new_state;

    // // счётчик
    // always_ff @ (posedge clk)
    //   if(rst)
    //     counter <= 'd0;
    //   else
    //     begin
    //       if (state == st_increment)
    //         counter <= counter + 'd1;
    //       else if (state == st_decrement)
    //         counter <= counter - 'd1;
    //     end

endmodule
