// decodificador_operacion.v
// Decodificador de operacion, Proyecto 1 - Arquitectura de Computadores.
//
// Toma los resultados candidatos ya calculados por los bloques anteriores
// (sumador/restador compartido, y los dos barrel shifters) y selecciona cual
// pasa a la salida final R, segun el codigo de operacion OP2 OP1 OP0
// (informe, seccion 3.5):
//
//   R_shift = MUX(shift_left, shift_right; sel=OP0)
//   R_op2   = MUX(R_arit, R_shift; sel=OP2)
//   es_reinicio = NOT(OP2) AND NOT(OP1) AND NOT(OP0)   -- unico minterm 000
//   R[i] = R_op2[i] AND NOT(es_reinicio)               -- fuerza R=0000 en reinicio
//
// R_arit ya viene correcto para suma/resta/resta inversa gracias a invA,
// invB y Cin del sumador/restador compartido (se calcula fuera de este
// bloque). Los codigos 110 y 111 quedan no definidos (don't care).
//
// Reutiliza mux2_1_4bits (arbol de MUX 2:1) ya verificado; el resto son
// primitivas de compuertas (not, and).

module decodificador_operacion (
    input  wire [3:0] R_arit,
    input  wire [3:0] shift_left,
    input  wire [3:0] shift_right,
    input  wire       OP2,
    input  wire       OP1,
    input  wire       OP0,
    output wire [3:0] R
);

    wire [3:0] R_shift, R_op2;
    wire op2_n, op1_n, op0_n;
    wire es_reinicio, es_reinicio_n;

    // ---- Arbol de 2 MUX 2:1 ----
    mux2_1_4bits mux_shift (.a(shift_left), .b(shift_right), .sel(OP0), .salida(R_shift));
    mux2_1_4bits mux_op2   (.a(R_arit),     .b(R_shift),     .sel(OP2), .salida(R_op2));

    // ---- es_reinicio = NOT(OP2) . NOT(OP1) . NOT(OP0) ----
    not (op2_n, OP2);
    not (op1_n, OP1);
    not (op0_n, OP0);
    and (es_reinicio, op2_n, op1_n, op0_n);

    // ---- Compuerta de bloqueo final: R[i] = R_op2[i] . NOT(es_reinicio) ----
    not (es_reinicio_n, es_reinicio);

    and (R[3], R_op2[3], es_reinicio_n);
    and (R[2], R_op2[2], es_reinicio_n);
    and (R[1], R_op2[1], es_reinicio_n);
    and (R[0], R_op2[0], es_reinicio_n);

endmodule
