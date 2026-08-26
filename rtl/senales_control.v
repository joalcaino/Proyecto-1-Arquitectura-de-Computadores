// senales_control.v
// Senales de control del sumador/restador compartido, Proyecto 1 -
// Arquitectura de Computadores.
//
// A partir del codigo de operacion OP2 OP1 OP0 (OP2 = bit mas significativo),
// calcula (informe, seccion 3.2):
//
//   invB = NOT(OP2) . OP1 . NOT(OP0)   (activo en resta, 010)
//   invA = NOT(OP2) . OP1 . OP0        (activo en resta inversa, 011)
//   Cin  = invA + invB = NOT(OP2) . OP1
//
// Para suma (001) y reinicio (000): invA=invB=Cin=0 (el sumador calcula A+B
// sin modificar; en reinicio, decodificador_operacion.v se encarga de forzar
// la salida a 0000 con la senal es_reinicio). Para shift left/right (100/101)
// y los codigos no definidos (110/111), OP2=1 hace que invA=invB=Cin=0
// automaticamente por la formula (no afecta, esas salidas se descartan en el
// decodificador de operacion).
//
// Solo primitivas de compuertas: not, and, or.

module senales_control (
    input  wire OP2,
    input  wire OP1,
    input  wire OP0,
    output wire invA,
    output wire invB,
    output wire Cin
);

    wire op2_n, op0_n;

    not (op2_n, OP2);
    not (op0_n, OP0);

    and (invB, op2_n, OP1, op0_n);
    and (invA, op2_n, OP1, OP0);
    or  (Cin, invA, invB);

endmodule
