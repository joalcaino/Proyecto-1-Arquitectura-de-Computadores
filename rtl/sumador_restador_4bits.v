// sumador_restador_4bits.v
// Sumador/restador de 4 bits compartido, Proyecto 1 - Arquitectura de Computadores.
//
// Bloque base (informe, seccion 3.2): encadena 4 full adders (acarreo en cascada).
// El Cout de la ultima etapa se descarta -> overflow trunca a los 4 bits menos
// significativos, tal como pide el enunciado.
//
// Para reutilizar el mismo sumador en suma / resta / resta inversa, cada bit de
// A y de B pasa antes por un "inversor controlado" (compuerta XOR) manejado por
// invA e invB. invA, invB y Cin se calculan a partir del codigo de operacion en
// un bloque de control aparte (seccion 4.3 del informe) y entran aqui ya listos:
//   Suma          -> invA=0, invB=0, Cin=0
//   Resta (A-B)   -> invA=0, invB=1, Cin=1
//   Resta inversa -> invA=1, invB=0, Cin=1
//
// Solo usa primitivas de compuertas (xor) y el modulo full_adder ya verificado.

module sumador_restador_4bits (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       invA,
    input  wire       invB,
    input  wire       Cin,
    output wire [3:0] S
);

    // ---- Inversores controlados (A y B "modificados") ----
    wire [3:0] A_mod, B_mod;

    xor (A_mod[0], A[0], invA);
    xor (A_mod[1], A[1], invA);
    xor (A_mod[2], A[2], invA);
    xor (A_mod[3], A[3], invA);

    xor (B_mod[0], B[0], invB);
    xor (B_mod[1], B[1], invB);
    xor (B_mod[2], B[2], invB);
    xor (B_mod[3], B[3], invB);

    // ---- Cadena de 4 full adders, acarreo en cascada ----
    wire c1, c2, c3, c4_descartado;

    full_adder fa0 (.A(A_mod[0]), .B(B_mod[0]), .Cin(Cin), .S(S[0]), .Cout(c1));
    full_adder fa1 (.A(A_mod[1]), .B(B_mod[1]), .Cin(c1),  .S(S[1]), .Cout(c2));
    full_adder fa2 (.A(A_mod[2]), .B(B_mod[2]), .Cin(c2),  .S(S[2]), .Cout(c3));
    full_adder fa3 (.A(A_mod[3]), .B(B_mod[3]), .Cin(c3),  .S(S[3]), .Cout(c4_descartado));

endmodule
