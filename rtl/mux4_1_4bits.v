// mux4_1_4bits.v
// Multiplexor 4 a 1 de valores de 4 bits, para elegir cual valor
// (operando 1, operando 2/resultado anterior, o resultado) se muestra
// en los displays de 7 segmentos segun el estado de la FSM.
// Proyecto 1 - Arquitectura de Computadores.
//
// sel[1:0] es el indice (0 a 3) de la entrada que pasa a la salida,
// misma convencion de indices que mux16_1.v: sel=00->in0, 01->in1,
// 10->in2, 11->in3.
//
// Reutiliza mux2_1_4bits.v ya verificado (2 niveles, 3 instancias); no
// agrega compuertas nuevas.

module mux4_1_4bits (
    input  wire [3:0] in0,
    input  wire [3:0] in1,
    input  wire [3:0] in2,
    input  wire [3:0] in3,
    input  wire [1:0] sel,
    output wire [3:0] salida
);

    wire [3:0] nivel1_a, nivel1_b;

    mux2_1_4bits n1_a (.a(in0), .b(in1), .sel(sel[0]), .salida(nivel1_a));
    mux2_1_4bits n1_b (.a(in2), .b(in3), .sel(sel[0]), .salida(nivel1_b));
    mux2_1_4bits n2   (.a(nivel1_a), .b(nivel1_b), .sel(sel[1]), .salida(salida));

endmodule
