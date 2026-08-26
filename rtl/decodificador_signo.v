// decodificador_signo.v
// Decodificador para el PRIMER display de 7 segmentos (el que muestra el
// signo +/- del valor que se este mostrando -- op1, op2 o resultado,
// segun el estado de la FSM). Como los valores son de 4 bits en
// complemento a dos, el signo es simplemente el bit mas significativo
// del valor (bit[3]): 0 = positivo, 1 = negativo.
// Proyecto 1 - Arquitectura de Computadores.
//
// Convencion elegida (un solo display de 7 segmentos no puede mostrar un
// "+" limpio, asi que se usa la convencion estandar de multimetro):
//   signo=0 (positivo) -> display apagado por completo (en blanco)
//   signo=1 (negativo) -> solo el segmento central "g" encendido (guion "-")
//
// Salidas activas en BAJO (igual que decodificador_hex_7seg.v), porque
// asi funcionan los displays de la Go Board.
//
// No necesita mux16_1 (solo hay 2 casos): un solo "not" para el segmento
// g, y el resto de segmentos amarrados a apagado (1 = apagado, activo-bajo).

module decodificador_signo (
    input  wire signo,  // bit de signo del valor (bit[3]): 1 = negativo
    output wire seg_a,
    output wire seg_b,
    output wire seg_c,
    output wire seg_d,
    output wire seg_e,
    output wire seg_f,
    output wire seg_g
);

    // Segmentos a..f siempre apagados en este display (activo-bajo: 1=apagado)
    buf (seg_a, 1'b1);
    buf (seg_b, 1'b1);
    buf (seg_c, 1'b1);
    buf (seg_d, 1'b1);
    buf (seg_e, 1'b1);
    buf (seg_f, 1'b1);

    // g: apagado (1) si signo=0, encendido (0) si signo=1
    not (seg_g, signo);

endmodule
