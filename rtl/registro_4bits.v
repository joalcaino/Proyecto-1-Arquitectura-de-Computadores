// registro_4bits.v
// Registro de 4 bits con carga habilitada por la senal confirmar/ejecutar.
// Proyecto 1 - Arquitectura de Computadores.
//
// Corresponde al bloque "Registro" del diagrama de bloques del informe:
// guarda el resultado de la ALU cuando llega el pulso de confirmar/ejecutar,
// y lo retiene sin cambios el resto del tiempo (incluso si D_nuevo sigue
// cambiando, porque la ALU es combinacional y su salida se mueve todo el
// tiempo con A/B/OP).
//
// Truco clasico para un flip-flop CON enable, construido a partir de un
// dff.v "simple" (que se clockea siempre): antes de cada flip-flop se pone
// un mux2_1 que elige, en cada flanco de reloj, entre:
//   confirmar=0 -> realimentar la propia salida Q (recargar el mismo valor
//                  = efecto "retener")
//   confirmar=1 -> cargar el valor nuevo (D_nuevo)
//
// Reutiliza mux2_1.v y dff.v ya verificados; no agrega compuertas nuevas.

module registro_4bits (
    input  wire [3:0] D_nuevo,
    input  wire       confirmar,
    input  wire       clk,
    output wire [3:0] Q
);

    wire [3:0] D_efectivo;

    mux2_1 sel0 (.a(Q[0]), .b(D_nuevo[0]), .sel(confirmar), .salida(D_efectivo[0]));
    mux2_1 sel1 (.a(Q[1]), .b(D_nuevo[1]), .sel(confirmar), .salida(D_efectivo[1]));
    mux2_1 sel2 (.a(Q[2]), .b(D_nuevo[2]), .sel(confirmar), .salida(D_efectivo[2]));
    mux2_1 sel3 (.a(Q[3]), .b(D_nuevo[3]), .sel(confirmar), .salida(D_efectivo[3]));

    dff ff0 (.D(D_efectivo[0]), .CLK(clk), .Q(Q[0]));
    dff ff1 (.D(D_efectivo[1]), .CLK(clk), .Q(Q[1]));
    dff ff2 (.D(D_efectivo[2]), .CLK(clk), .Q(Q[2]));
    dff ff3 (.D(D_efectivo[3]), .CLK(clk), .Q(Q[3]));

endmodule
