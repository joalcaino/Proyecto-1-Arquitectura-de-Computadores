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
// Tiene ademas una entrada "reset": fuerza Q a 0000 en el siguiente flanco
// de reloj (prioridad sobre confirmar), para arrancar en un estado conocido
// -- igual que contador_4bits.v y contador_operacion.v, necesario porque Q
// se retroalimenta a si mismo.
//
// Reutiliza mux2_1.v y dff.v ya verificados; no agrega compuertas nuevas.

module registro_4bits (
    input  wire [3:0] D_nuevo,
    input  wire       confirmar,
    input  wire       reset,
    input  wire       clk,
    output wire [3:0] Q
);

    wire [3:0] tras_confirmar, D_efectivo;

    mux2_1 sel0 (.a(Q[0]), .b(D_nuevo[0]), .sel(confirmar), .salida(tras_confirmar[0]));
    mux2_1 sel1 (.a(Q[1]), .b(D_nuevo[1]), .sel(confirmar), .salida(tras_confirmar[1]));
    mux2_1 sel2 (.a(Q[2]), .b(D_nuevo[2]), .sel(confirmar), .salida(tras_confirmar[2]));
    mux2_1 sel3 (.a(Q[3]), .b(D_nuevo[3]), .sel(confirmar), .salida(tras_confirmar[3]));

    mux2_1 r0 (.a(tras_confirmar[0]), .b(1'b0), .sel(reset), .salida(D_efectivo[0]));
    mux2_1 r1 (.a(tras_confirmar[1]), .b(1'b0), .sel(reset), .salida(D_efectivo[1]));
    mux2_1 r2 (.a(tras_confirmar[2]), .b(1'b0), .sel(reset), .salida(D_efectivo[2]));
    mux2_1 r3 (.a(tras_confirmar[3]), .b(1'b0), .sel(reset), .salida(D_efectivo[3]));

    dff ff0 (.D(D_efectivo[0]), .CLK(clk), .Q(Q[0]));
    dff ff1 (.D(D_efectivo[1]), .CLK(clk), .Q(Q[1]));
    dff ff2 (.D(D_efectivo[2]), .CLK(clk), .Q(Q[2]));
    dff ff3 (.D(D_efectivo[3]), .CLK(clk), .Q(Q[3]));

endmodule
