// mux16_1.v
// Multiplexor 16 a 1, construido apilando mux2_1 en 4 niveles (8+4+2+1
// instancias = 15 en total). Es el equivalente estructural de un "case"
// con 16 ramas, pero hecho solo con compuertas -- se usa para el
// decodificador de 7 segmentos (16 digitos hex) en vez de derivar a mano
// las ecuaciones booleanas de cada segmento.
// Proyecto 1 - Arquitectura de Computadores.
//
// sel[3:0] es el indice binario (0 a 15) de la entrada que se quiere
// pasar a la salida. Cada nivel de mux2_1 decide con un bit de sel:
// nivel 1 con sel[0], nivel 2 con sel[1], nivel 3 con sel[2],
// nivel 4 (el ultimo) con sel[3]. En cada mux2_1, sel=0 elige "a" y
// sel=1 elige "b" (igual convencion que en mux2_1.v).
//
// Reutiliza mux2_1.v ya verificado; no agrega compuertas nuevas.

module mux16_1 (
    input  wire [15:0] in,
    input  wire [3:0]  sel,
    output wire         salida
);

    wire m1_0, m1_1, m1_2, m1_3, m1_4, m1_5, m1_6, m1_7;
    wire m2_0, m2_1, m2_2, m2_3;
    wire m3_0, m3_1;

    // Nivel 1: 8 mux2_1, deciden con sel[0]
    mux2_1 n1_0 (.a(in[0]),  .b(in[1]),  .sel(sel[0]), .salida(m1_0));
    mux2_1 n1_1 (.a(in[2]),  .b(in[3]),  .sel(sel[0]), .salida(m1_1));
    mux2_1 n1_2 (.a(in[4]),  .b(in[5]),  .sel(sel[0]), .salida(m1_2));
    mux2_1 n1_3 (.a(in[6]),  .b(in[7]),  .sel(sel[0]), .salida(m1_3));
    mux2_1 n1_4 (.a(in[8]),  .b(in[9]),  .sel(sel[0]), .salida(m1_4));
    mux2_1 n1_5 (.a(in[10]), .b(in[11]), .sel(sel[0]), .salida(m1_5));
    mux2_1 n1_6 (.a(in[12]), .b(in[13]), .sel(sel[0]), .salida(m1_6));
    mux2_1 n1_7 (.a(in[14]), .b(in[15]), .sel(sel[0]), .salida(m1_7));

    // Nivel 2: 4 mux2_1, deciden con sel[1]
    mux2_1 n2_0 (.a(m1_0), .b(m1_1), .sel(sel[1]), .salida(m2_0));
    mux2_1 n2_1 (.a(m1_2), .b(m1_3), .sel(sel[1]), .salida(m2_1));
    mux2_1 n2_2 (.a(m1_4), .b(m1_5), .sel(sel[1]), .salida(m2_2));
    mux2_1 n2_3 (.a(m1_6), .b(m1_7), .sel(sel[1]), .salida(m2_3));

    // Nivel 3: 2 mux2_1, deciden con sel[2]
    mux2_1 n3_0 (.a(m2_0), .b(m2_1), .sel(sel[2]), .salida(m3_0));
    mux2_1 n3_1 (.a(m2_2), .b(m2_3), .sel(sel[2]), .salida(m3_1));

    // Nivel 4: 1 mux2_1, decide con sel[3]
    mux2_1 n4_0 (.a(m3_0), .b(m3_1), .sel(sel[3]), .salida(salida));

endmodule
