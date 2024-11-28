//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    // Задача:
    // Реализовать модуль, который принимает три числа с плавающей точкой и выводит их дискриминант.
    // Результирующее значение res должно быть вычислено как дискриминант квадратичного полинома.
    // То есть res = b^2 - 4ac == b*b - 4*a*c
    //
    // Примечание:
    // Если какой-либо аргумент не является допустимым числом, то есть NaN или Inf, следует установить флаг "err".
    //
    // Параметр FLEN определен в файле "import/preprocessed/cvw/config-shared.vh"
    // и обычно равен битовой ширине числа с плавающей точкой двойной точности, FP64, 64 бита.

logic [FLEN - 1:0] mult_a;
logic [FLEN - 1:0] mult_b;
logic              mult_arg_vld;
logic [FLEN - 1:0] mult_res;
logic              mult_res_vld;
logic              mult_busy;
logic              mult_err;


    f_mult i_mult (
            .clk(clk),
            .rst(rst),
            .a(mult_a),
            .b(mult_b),
            .up_valid(mult_arg_vld),
            .res(mult_res),
            .down_valid(mult_res_vld),
            .busy(mult_busy),
            .error(mult_err)
    );

    // FSM (finite state machine) ----------------------------------------------
    // стop   arg_vld
    // -------------------------------------
    // stop    -1->    b*b   --->   a*c   --->  subtraction  --> ready --
    //                                                                  |
    //         <---------------------------------------------------------

    // States
    typedef enum logic [2:0]
    {
        st_stop  = 3'd0,
        st_bb    = 3'd1,
        st_4ac   = 3'd2,
        st_sub   = 3'd3,
        st_ready = 3'd4

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
            st_stop  : if (arg_vld) next_state = st_bb;
            st_bb    : next_state = st_4ac;
            st_4ac   : next_state = st_sub;
            st_sub   : next_state = st_ready;
            st_ready : next_state = st_stop;
        endcase

        // verilator lint_on  CASEINCOMPLETE

    end

    //------------------------------------------------------------------------
    assign mult_a = ( state == st_stop ) ? b : a;
    assign mult_b = ( state == st_bb ) ? b : c;

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
