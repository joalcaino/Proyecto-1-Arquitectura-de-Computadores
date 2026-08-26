// incrementador_2bits.v
// Suma 1 a un valor de 2 bits (con wrap-around natural: 11 -> 00). Se usa
// para el registro de estado de la FSM (4 estados, avanza uno a la vez).
// Proyecto 1 - Arquitectura de Computadores.
//
// Misma tecnica que incrementador_4bits.v / incrementador_8bits.v: cadena
// de full adders con B=0 fijo y Cin=1 solo en el bit menos significativo.
// Solo reutiliza full_adder.v ya verificado.

module incrementador_2bits (
    input  wire [1:0] A,
    output wire [1:0] resultado
);

    wire c1, c2_descartado;

    full_adder fa0 (.A(A[0]), .B(1'b0), .Cin(1'b1), .S(resultado[0]), .Cout(c1));
    full_adder fa1 (.A(A[1]), .B(1'b0), .Cin(c1),   .S(resultado[1]), .Cout(c2_descartado));

endmodule
