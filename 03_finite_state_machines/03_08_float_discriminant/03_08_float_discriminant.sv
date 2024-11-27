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

endmodule
