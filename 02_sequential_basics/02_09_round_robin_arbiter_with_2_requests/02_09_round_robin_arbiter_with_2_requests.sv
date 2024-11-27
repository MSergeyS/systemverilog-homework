//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    // States
    typedef enum logic[1:0]
    {
      st_no_grants = 2'b00,
      st_grant_0   = 2'b01,
      st_grant_1   = 2'b10
    } statetype_t;
    statetype_t state, new_state;

    // State transition logic  (логика переходоа конечного автомата)
    always_comb
      begin
        new_state = state;

        case (state)
          st_no_grants : if (requests[0]) new_state = st_grant_0;
                         else if (requests[1]) new_state = st_grant_1;
          st_grant_0   : if (requests == 2'b00) new_state = st_no_grants;
                         else if (requests[1]) new_state = st_grant_1;
          st_grant_1   : if (requests == 2'b00) new_state = st_no_grants;
                         else if (requests[0]) new_state = st_grant_0;
        endcase
      end

    // Output logic (обновление выходов)
     assign grants = {new_state == st_grant_1, new_state == st_grant_0};

    // обновление состояния
    always_ff @ (posedge clk)
      if (rst)
        state <= st_no_grants;
      else
        state <= new_state;

endmodule
