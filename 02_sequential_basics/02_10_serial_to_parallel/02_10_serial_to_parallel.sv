//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [width-1:0] shift_reg;

    always_ff @(posedge clk)
      begin
        if (rst)
          begin
            parallel_data <= '0;
            parallel_valid <= '0;
            shift_reg <= 'b1;
          end
        else
          begin
            if (serial_valid)
              begin
                parallel_data <= {serial_data, parallel_data[width-1:1]};
                shift_reg[width-1:0] <= {shift_reg[width-2:0], shift_reg[width-1]};
                if (shift_reg[width-1])
                  begin
                    parallel_valid <= '1;
                    shift_reg <= 'b1;
                  end
                else
                  begin
                    parallel_valid <= '0;
                  end
              end
              else
                begin
                  parallel_valid <= '0;
                end
          end
      end

endmodule

//     // мой вариант решения (использовал конечный автомат)
//     logic [ $clog2(width)-1:0] counter_bits; // счётчик накопленных бит
//     logic [ width-1:0] shift_register;  // сдвиговый регистр

//     // States
//     typedef enum logic[1:0]
//     {
//       st_stop         = 2'b00,
//       st_accumulation = 2'b01,
//       st_complete     = 2'b10
//     } statetype_t;
//     statetype_t state, new_state;

//     // State transition logic  (логика переходоа конечного автомата)
//     always_comb
//       begin
//         new_state = state;

//         case (state)
//           st_stop         : if ( serial_valid)
//                                 if (counter_bits == width-1) new_state = st_complete;
//                                 else new_state = st_accumulation;
//           st_accumulation : if (~serial_valid) new_state = st_stop;
//                             else if (counter_bits == width-1) new_state = st_complete; 
//           st_complete     : if ( serial_valid) new_state = st_accumulation;
//                             else new_state = st_stop;
//         endcase
//       end

//     // Output logic (обновление выходов)
//      assign parallel_valid = (new_state == st_complete);
//      assign parallel_data[width-1:0] = (new_state == st_complete) ?
//                      {serial_data, shift_register[width-1:1]} : 'd0;

//     // обновление состояния
//     always_ff @ (posedge clk)
//       if (rst)
//         state <= st_stop;
//       else
//         state <= new_state;

//     // счётчик
//     always_ff @ (posedge clk)
//     if(rst)
//       counter_bits <= 'd0;
//     else
//       begin
//         if (new_state != st_stop)
//           counter_bits <= (counter_bits == width-1) ? 'd0 : counter_bits + 'd1;
//       end

//     // сдвиговый регистр
//     always_ff @ (posedge clk)
//       if(rst | (new_state == st_complete))
//         shift_register <= 'd0;
//       else
//         begin
//           if (new_state == st_accumulation)
//             // младший бит первый
//             shift_register[width-1:0] <= {serial_data, shift_register[width-1:1]};
//         end

// endmodule
