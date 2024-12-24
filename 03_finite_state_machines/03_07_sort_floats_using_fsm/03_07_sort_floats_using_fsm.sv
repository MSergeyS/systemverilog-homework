//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res2
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    // Задача:
    // Реализовать модуль, который принимает три числа с плавающей точкой и выводит их в порядке возрастания
    // с помощью конечного автомата.
    //
    // Требования:
    // Решение должно иметь задержку, равную трем тактам.
    // Решение должно использовать входы и выходы одного модуля "f_less_or_equal".
    // Решение НЕ должно создавать экземпляры каких-либо модулей.
    //
    // Примечания:
    // res0 должно быть меньше или равно res1
    // res1 должно быть меньше или равно res2
    //
    // Параметр FLEN определен в файле "import/preprocessed/cvw/config-shared.vh"
    // и обычно равен битовой ширине числа с плавающей точкой двойной точности, FP64, 64 бита.

    f_less_or_equal i_floe
    (
        .a   ( f_le_a   ),
        .b   ( f_le_b   ),
        .res ( f_le_res ),
        .err ( f_le_err)
    );

    // FSM (finite state machine) ----------------------------------------------
    // старт  a<=b      a<=c     b<=c  финиш
    // -------------------------------------
    //                           -1->  012
    //                  -1-> 0хх
    //        -1-> 01x           -0->  021
    //                  -0---------->  201
    // ххх
    //                  -1---------->  102
    //        -0-> 10x           -1->  120
    //                  -0-> xx0
    //                           -0->  210
    // States

    typedef enum logic [2:0]
    {
        st_xxx  = 3'd0,
        st_01x  = 3'd1,
        st_10x  = 3'd2,
        st_0xx  = 3'd3,
        st_xx0  = 3'd4,
        st_wait = 3'd5,
        st_stop = 3'd6
    } statetype_t;
    statetype_t state, next_state;

    //------------------------------------------------------------------------
    // Next state and isqrt interface

    always_comb
    begin
        next_state  = state;

        // This lint warning is bogus because we assign the default value above
        // verilator lint_off CASEINCOMPLETE

        case (state)
            st_xxx  : if (f_le_res) next_state = st_01x;
                     else next_state = st_10x;
            st_01x  : if (f_le_res) next_state = st_0xx;
                     else next_state = st_wait;
            st_10x  : if (f_le_res) next_state = st_wait;
                         else next_state = st_xx0;
            st_0xx  : next_state = st_stop;
            st_xx0  : next_state = st_stop;
            st_wait : next_state = st_stop;
            st_stop : next_state = st_xxx;
        endcase

        // verilator lint_on  CASEINCOMPLETE

    end

    //------------------------------------------------------------------------
    assign f_le_a = ( (state == st_xxx) |
                      (state == st_01x) |
                      (state == st_10x) ) ?
                    unsorted[0] : unsorted[1];
    assign f_le_b = (state == st_xxx) ? unsorted[1] : unsorted[2];

    // Output logic ---------------------------------------------------------
    always_comb
    begin
        case (state)
            st_01x : sorted = (f_le_res) ?
                     {(3*FLEN){1'bx}} :
                     {unsorted[2], unsorted[0], unsorted[1]};
            st_10x : sorted = (f_le_res) ?
                     {unsorted[1], unsorted[0], unsorted[2]} :
                     {(3*FLEN){1'bx}};
            st_0xx : sorted = (f_le_res) ?
                     unsorted :
                     {unsorted[0], unsorted[2], unsorted[1]};
            st_xx0 : sorted = (f_le_res) ?
                     {unsorted[1], unsorted[2], unsorted[0]} :
                     {unsorted[2], unsorted[1], unsorted[0]};
            st_xxx : sorted = {(3*FLEN){1'bx}};
        endcase

        // verilator lint_on  CASEINCOMPLETE

    end

    always_ff @ (posedge clk)
        if (rst)
            valid_out <= 1'b0;
        else
            begin
                valid_out <= (next_state == st_stop);
                err <= (state == st_xxx) ? 1'b0 : (err ? 1'b1 : f_le_err);
            end

    assign busy = (state != st_xxx);

    //------------------------------------------------------------------------
    // Assigning next state

    always_ff @ (posedge clk)
        if (rst)
            state <= st_xxx;
        else
            state <= next_state;

endmodule
