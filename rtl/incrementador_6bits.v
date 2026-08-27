// incrementador_6bits.v
// Igual que incrementador_8bits.v pero de 6 bits: encadena 6 full_adder
// con B fijo en 0 y Cin=1 inyectado solo en el bit 0 (asi A+1 sin usar '+').
// Se usa como base del "preescaler" de debounce.v (ver contador_incremental_6bits.v
// y debounce.v para la explicacion completa del diseño de dos cadenas cortas).
// Proyecto 1 - Arquitectura de Computadores.

module incrementador_6bits (
    input  wire [5:0] A,
    output wire [5:0] resultado
);

    wire [5:0] cout;

    full_adder fa0 (.A(A[0]), .B(1'b0), .Cin(1'b1), .S(resultado[0]), .Cout(cout[0]));
    full_adder fa1 (.A(A[1]), .B(1'b0), .Cin(cout[0]), .S(resultado[1]), .Cout(cout[1]));
    full_adder fa2 (.A(A[2]), .B(1'b0), .Cin(cout[1]), .S(resultado[2]), .Cout(cout[2]));
    full_adder fa3 (.A(A[3]), .B(1'b0), .Cin(cout[2]), .S(resultado[3]), .Cout(cout[3]));
    full_adder fa4 (.A(A[4]), .B(1'b0), .Cin(cout[3]), .S(resultado[4]), .Cout(cout[4]));
    full_adder fa5 (.A(A[5]), .B(1'b0), .Cin(cout[4]), .S(resultado[5]), .Cout(cout[5]));

endmodule
