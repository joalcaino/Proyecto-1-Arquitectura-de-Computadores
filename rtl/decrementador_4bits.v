// decrementador_4bits.v
// Resta 1 a un valor de 4 bits (A-1, con wrap-around natural: 0000 -> 1111).
// Proyecto 1 - Arquitectura de Computadores.
//
// Reutiliza sumador_restador_4bits.v con B fijo en 0001, invA=0, invB=1,
// Cin=1 (modo resta A-B, con B=1). No agrega compuertas nuevas.

module decrementador_4bits (
    input  wire [3:0] A,
    output wire [3:0] resultado
);

    sumador_restador_4bits resta1 (
        .A(A), .B(4'b0001),
        .invA(1'b0), .invB(1'b1), .Cin(1'b1),
        .S(resultado)
    );

endmodule
