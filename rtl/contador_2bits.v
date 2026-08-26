// contador_2bits.v
// Registro de estado de la FSM: contador de 2 bits que avanza de a 1 cada
// vez que "avanzar"=1 (con wrap-around: 11 -> 00), y se puede forzar a 00
// con "reset". Los 4 valores posibles (00,01,10,11) representan los 4
// estados: elegir operacion, ingresar op1, ingresar op2, mostrar resultado.
// Proyecto 1 - Arquitectura de Computadores.
//
// Reutiliza incrementador_2bits.v, mux2_1.v y dff.v, todos ya verificados.

module contador_2bits (
    input  wire avanzar,
    input  wire reset,
    input  wire clk,
    output wire [1:0] Q
);

    wire [1:0] Q_mas_1, tras_avanzar, siguiente;

    incrementador_2bits inc (.A(Q), .resultado(Q_mas_1));

    mux2_1 sel_avanzar0 (.a(Q[0]), .b(Q_mas_1[0]), .sel(avanzar), .salida(tras_avanzar[0]));
    mux2_1 sel_avanzar1 (.a(Q[1]), .b(Q_mas_1[1]), .sel(avanzar), .salida(tras_avanzar[1]));

    mux2_1 sel_reset0 (.a(tras_avanzar[0]), .b(1'b0), .sel(reset), .salida(siguiente[0]));
    mux2_1 sel_reset1 (.a(tras_avanzar[1]), .b(1'b0), .sel(reset), .salida(siguiente[1]));

    dff bit0 (.D(siguiente[0]), .CLK(clk), .Q(Q[0]));
    dff bit1 (.D(siguiente[1]), .CLK(clk), .Q(Q[1]));

endmodule
