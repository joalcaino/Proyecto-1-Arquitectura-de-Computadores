// mux2_1.v
// Multiplexor 2:1 de 1 bit, Proyecto 1 - Arquitectura de Computadores.
//
// Bloque base reutilizado (sin cambios) en: el selector de op2, las dos etapas
// de cada barrel shifter, y el arbol del decodificador de operacion.
//
// Ecuacion (informe, seccion 4.2):
//   salida = (NOT sel AND a) OR (sel AND b)
//   sel=0 -> pasa "a" ; sel=1 -> pasa "b"
//
// Solo primitivas de compuertas: not, and, or.

module mux2_1 (
    input  wire a,
    input  wire b,
    input  wire sel,
    output wire salida
);

    wire sel_n;
    wire a_and, b_and;

    not (sel_n, sel);
    and (a_and, a, sel_n);
    and (b_and, b, sel);
    or  (salida, a_and, b_and);

endmodule
