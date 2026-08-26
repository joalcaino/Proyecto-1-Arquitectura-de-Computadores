// alu.v
// ALU combinacional de la calculadora de 4 bits, Proyecto 1 - Arquitectura
// de Computadores. Corresponde al bloque "ALU combinacional (solo
// compuertas)" del diagrama de bloques del informe.
//
// Conecta todos los bloques ya verificados:
//   senales_control        -> invA, invB, Cin  (a partir de OP2 OP1 OP0)
//   sumador_restador_4bits  -> R_arit           (suma / resta / resta inversa)
//   barrel_shifter_left     -> shift_left       (A << B[1:0])
//   barrel_shifter_right    -> shift_right      (A >> B[1:0])
//   decodificador_operacion -> R                (selecciona el resultado final)
//
// A = op1 (4 bits). B = segundo operando YA seleccionado (op2 externo o
// resultado anterior; ese MUX 2:1 vive fuera de este bloque, es el "selector
// de op2" del diagrama de bloques). El monto de desplazamiento de los barrel
// shifters es B[1:0], tal como especifica el enunciado.
//
// Este modulo no agrega compuertas nuevas: solo instancia y cablea los
// bloques ya construidos y probados por separado.

module alu (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       OP2,
    input  wire       OP1,
    input  wire       OP0,
    output wire [3:0] R
);

    wire invA, invB, Cin;
    wire [3:0] R_arit, shift_left, shift_right;

    senales_control ctrl (
        .OP2(OP2), .OP1(OP1), .OP0(OP0),
        .invA(invA), .invB(invB), .Cin(Cin)
    );

    sumador_restador_4bits sr (
        .A(A), .B(B), .invA(invA), .invB(invB), .Cin(Cin), .S(R_arit)
    );

    barrel_shifter_left bsl (
        .A(A), .monto(B[1:0]), .R(shift_left)
    );

    barrel_shifter_right bsr (
        .A(A), .monto(B[1:0]), .R(shift_right)
    );

    decodificador_operacion deco (
        .R_arit(R_arit), .shift_left(shift_left), .shift_right(shift_right),
        .OP2(OP2), .OP1(OP1), .OP0(OP0), .R(R)
    );

endmodule
