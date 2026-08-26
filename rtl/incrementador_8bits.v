// incrementador_8bits.v
// Suma 1 a un valor de 8 bits (con wrap-around natural: 11111111 -> 00000000).
// Proyecto 1 - Arquitectura de Computadores.
//
// Cadena de 8 full adders con B=0 fijo en todos los bits y Cin=1 solo en el
// bit menos significativo (equivale a sumar 00000001). Es la misma tecnica
// que sumador_restador_4bits.v, pero de 8 bits y solo para sumar 1 (no hace
// falta invA/invB aqui). Se usa en el contador del circuito de debounce.
//
// Solo reutiliza full_adder.v ya verificado.

module incrementador_8bits (
    input  wire [7:0] A,
    output wire [7:0] resultado
);

    wire c1, c2, c3, c4, c5, c6, c7, c8_descartado;

    full_adder fa0 (.A(A[0]), .B(1'b0), .Cin(1'b1), .S(resultado[0]), .Cout(c1));
    full_adder fa1 (.A(A[1]), .B(1'b0), .Cin(c1),   .S(resultado[1]), .Cout(c2));
    full_adder fa2 (.A(A[2]), .B(1'b0), .Cin(c2),   .S(resultado[2]), .Cout(c3));
    full_adder fa3 (.A(A[3]), .B(1'b0), .Cin(c3),   .S(resultado[3]), .Cout(c4));
    full_adder fa4 (.A(A[4]), .B(1'b0), .Cin(c4),   .S(resultado[4]), .Cout(c5));
    full_adder fa5 (.A(A[5]), .B(1'b0), .Cin(c5),   .S(resultado[5]), .Cout(c6));
    full_adder fa6 (.A(A[6]), .B(1'b0), .Cin(c6),   .S(resultado[6]), .Cout(c7));
    full_adder fa7 (.A(A[7]), .B(1'b0), .Cin(c7),   .S(resultado[7]), .Cout(c8_descartado));

endmodule
