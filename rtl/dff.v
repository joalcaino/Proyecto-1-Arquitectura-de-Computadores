// dff.v
// Flip-flop D disparado por flanco de subida (positive-edge-triggered),
// construido con la tecnica clasica "maestro-esclavo": 2 latches D en
// cascada, habilitados con fases opuestas del reloj.
// Proyecto 1 - Arquitectura de Computadores.
//
// Latch maestro: transparente mientras CLK=0 (sigue a D).
// Latch esclavo: transparente mientras CLK=1 (copia lo que el maestro
//                dejo congelado justo antes de que CLK subiera).
//
// Resultado: Q solo cambia en el flanco de subida de CLK, capturando el
// valor que tenia D justo antes de ese flanco - el comportamiento estandar
// de un flip-flop D, pero construido enteramente con d_latch.v (que a su
// vez es sr_latch.v). No usa "always"/"posedge"/"<=": es 100% estructural.

module dff (
    input  wire D,
    input  wire CLK,
    output wire Q
);

    wire CLKn, Qm;

    not (CLKn, CLK);

    d_latch maestro (.D(D),  .EN(CLKn), .Q(Qm));
    d_latch esclavo  (.D(Qm), .EN(CLK),  .Q(Q));

endmodule
