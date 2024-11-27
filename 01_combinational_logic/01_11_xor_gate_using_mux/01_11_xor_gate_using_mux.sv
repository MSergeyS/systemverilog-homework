//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

  // o = b ? !a : a

  wire a_not; // инверсный сигнал a
  mux mux_not(.d0(1'b1), .d1(1'b0), .sel(a), .y(a_not));
  mux mux1(.d0(a), .d1(a_not), .sel(b), .y(o));

endmodule
