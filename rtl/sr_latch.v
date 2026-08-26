// sr_latch.v
// Latch SR (Set-Reset) basico, construido con 2 compuertas NOR cruzadas.
// Proyecto 1 - Arquitectura de Computadores.
//
// Es la pieza mas basica de memoria de 1 bit: S=1 fuerza Q=1 (set),
// R=1 fuerza Q=0 (reset), S=R=0 mantiene el valor guardado (hold).
// S=R=1 no se usa (estado no valido para un latch NOR).
//
// Se usa como base para construir el latch D (d_latch.v), que a su vez
// se usa para construir el flip-flop D maestro-esclavo (dff.v).
//
// Solo primitiva de compuertas: nor.

module sr_latch (
    input  wire S,
    input  wire R,
    output wire Q,
    output wire Qn
);

    nor (Q,  R, Qn);
    nor (Qn, S, Q);

endmodule
