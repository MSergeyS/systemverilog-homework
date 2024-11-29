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
    // Примечание:state != st_ready
    // Если какой-либо аргумент не является допустимым числом, то есть NaN или Inf, следует установить флаг "err".
    //
    // Параметр FLEN определен в файле "import/preprocessed/cvw/config-shared.vh"
    // и обычно равен битовой ширине числа с плавающей точкой двойной точности, FP64, 64 бита.

    // умножитель (float)
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

    // вычитатель (float)
    logic [FLEN - 1:0] sub_a;
    logic [FLEN - 1:0] sub_b;
    logic              sub_arg_vld;
    logic [FLEN - 1:0] sub_res;
    logic              sub_res_vld;
    logic              sub_busy;
    logic              sub_err;

    f_sub i_sub (
            .clk(clk),
            .rst(rst),
            .a(sub_a),
            .b(sub_b),
            .up_valid(sub_arg_vld),
            .res(sub_res),
            .down_valid(sub_res_vld),
            .busy(sub_busy),
            .error(sub_err)
    );

    // FSM (finite state machine) ----------------------------------------------
    // стop  arg_vld     mult_res_vld    mult_res_vld   mult_res_vld     sub_res_vld
    // -------------------------------------------------------------------------------
    // stop    -1->   b*b    -1->    a*c   -1->   4*a*c   -1->  subtraction  --
    //                                                                        |
    //         <---------------------------------------------------------------

    // States
    typedef enum logic [2:0]
    {
        st_stop  = 3'd0,
        st_bb    = 3'd1,
        st_ac    = 3'd2,
        st_4ac   = 3'd3,
        st_sub   = 3'd4
    } statetype_t;
    statetype_t state, next_state;

    //------------------------------------------------------------------------
    // Next state and isqrt st_stopinterface

    always_comb
    begin
        next_state  = state;

        // This lint warning is bogus because we assign the default value above
        // verilator lint_off CASEINCOMPLETE

        case (state)
            st_stop  : if (arg_vld) next_state = st_bb;
            st_bb    : if (mult_res_vld) next_state = st_ac;
            st_ac    : if (mult_res_vld) next_state = st_4ac;
            st_4ac   : if (mult_res_vld) next_state = st_sub;
            st_sub   : if (sub_res_vld) next_state = st_stop;
        endcase

        // verilator lint_on  CASEINCOMPLETE
    end

    always_comb
        begin
        mult_arg_vld = 1'b0;
        sub_arg_vld = 1'b0;

        case (state)
            st_stop :
                begin
                    mult_a = b;
                    mult_b = b;
                    mult_arg_vld = arg_vld;
                end
            st_bb :
                begin
                    mult_a = a;
                    mult_b = c;
                    mult_arg_vld = mult_res_vld;
                    if (mult_res_vld) sub_a = mult_res;
                end
            st_ac :
                begin
                    mult_a = $realtobits ( 4 );
                    mult_b = mult_res;
                    mult_arg_vld = mult_res_vld;
                end
            st_4ac :
                begin
                    if (mult_res_vld) sub_b = mult_res;
                    sub_arg_vld = mult_res_vld;
                end
        endcase
    end

    // Output logic ---------------------------------------------------------
    assign res = sub_res;
    assign res_vld = sub_res_vld;
    assign busy = (state != st_stop);

    assign mult_err_vld = mult_err & mult_res_vld;
    assign sub_err_vld = sub_err & sub_res_vld;

    always_ff @ (posedge clk)
        begin
            err <= (state == st_stop) ?
                1'b0 :        // сбрасываем
                (err ? 1'b1 : ( mult_err_vld | sub_err_vld ) );
            end

    //------------------------------------------------------------------------
    // Assigning next state

    always_ff @ (posedge clk)
        if (rst)
            state <= st_stop;
        else
            state <= next_state;

endmodule
