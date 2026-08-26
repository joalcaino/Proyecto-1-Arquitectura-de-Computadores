// incrementador_4bits.v
// Suma 1 a un valor de 4 bits (A+1, con wrap-around natural: 1111 -> 0000).
// Proyecto 1 - Arquitectura de Computadores.
//
// Reutiliza sumador_restador_4bits.v con B fijo en 0001, invA=0, invB=0,
// Cin=0 (modo suma normal). No agrega compuertas nuevas.

module incrementador_4bits (
    input  wire [3:0] A,
    output wire [3:0] resultado
);

    sumador_restador_4bits suma1 (
        .A(A), .B(4'b0001),
        .invA(1'b0), .invB(1'b0), .Cin(1'b0),
        .S(resultado)
    );

endmodule
