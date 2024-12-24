//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module detect_4_bit_sequence_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  output detected
);

  // Detection of the "1010" sequence

  // States (F — First, S — Second)
  enum logic[2:0]
  {
     IDLE = 3'b000,
     F1   = 3'b001,
     F0   = 3'b010,
     S1   = 3'b011,
     S0   = 3'b100
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      IDLE: if (  a) new_state = F1;
      F1:   if (~ a) new_state = F0;
      F0:   if (  a) new_state = S1;
            else     new_state = IDLE;
      S1:   if (~ a) new_state = S0;
            else     new_state = F1;
      S0:   if (  a) new_state = S1;
            else     new_state = IDLE;
    endcase

    // verilator lint_on CASEINCOMPLETE

  end

  // Output logic (depends only on the current state)
  assign detected = (state == S0);

  // State update
  always_ff @ (posedge clk)
    if (rst)
      state <= IDLE;
    else
      state <= new_state;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module detect_6_bit_sequence_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  output detected
);

  // Task:
  // Implement a module that detects the "110011" input sequence
  //
  // Hint: See Lecture 3 for details

  // Detection of the "110011" sequence

  // States
  typedef enum logic[2:0]
  {
     IDLE     = 3'b000,
     First_1  = 3'b001,
     Second_1 = 3'b010,
     Third_0  = 3'b011,
     Fourth_0 = 3'b100,
     Fifth_1  = 3'b101,
     Sixth_1  = 3'b110
  } statetype_t;
  statetype_t state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      IDLE:     if (  a) new_state = First_1;
      First_1:  if (  a) new_state = Second_1;
                else new_state = IDLE;
      Second_1: if (~ a) new_state = Third_0;
      Third_0:  if (  a) new_state = First_1;
                else new_state = Fourth_0;
      Fourth_0: if (  a) new_state = Fifth_1;
                else     new_state = IDLE;
      Fifth_1:  if (  a) new_state = Sixth_1;
                else     new_state = IDLE;
      Sixth_1:  if (  a) new_state = Second_1;
                else     new_state = Third_0;
    endcase

    // verilator lint_on CASEINCOMPLETE

  end

  // Output logic (depends only on the current state)
  assign detected = (state == Sixth_1);

  // State update
  always_ff @ (posedge clk)
    if (rst)
      state <= IDLE;
    else
      state <= new_state;

endmodule
