// contador_4bits.v
// Contador/registro de 4 bits con subida y bajada de a 1 (con wrap-around
// completo: 1111->0000 al subir, 0000->1111 al bajar). Se usa para ingresar
// op1 y op2 (rango natural -8 a 7 en complemento a dos).
// Proyecto 1 - Arquitectura de Computadores.
//
// Tiene una entrada "reset": fuerza Q a 0000 en el siguiente flanco de
// reloj, sin pasar por el incrementador/decrementador (necesario porque
// Q se retroalimenta a si mismo a traves de compuertas XOR -- si el
// flip-flop arranca en estado desconocido, como al encender la FPGA, el
// XOR nunca "sale" solo de ese estado; el reset lo fuerza directamente).
//
// Prioridad si hay varias senales activas a la vez: reset > bajar > subir.
//
// Reutiliza incrementador_4bits, decrementador_4bits, mux2_1_4bits y dff,
// todos ya verificados. No agrega compuertas nuevas.

module contador_4bits (
    input  wire subir,
    input  wire bajar,
    input  wire reset,
    input  wire clk,
    output wire [3:0] Q
);

    wire [3:0] valor_inc, valor_dec, tras_subir, tras_bajar, siguiente;

    incrementador_4bits u_inc (.A(Q), .resultado(valor_inc));
    decrementador_4bits u_dec (.A(Q), .resultado(valor_dec));

    mux2_1_4bits sel_subir (.a(Q),          .b(valor_inc),  .sel(subir), .salida(tras_subir));
    mux2_1_4bits sel_bajar (.a(tras_subir), .b(valor_dec),  .sel(bajar), .salida(tras_bajar));
    mux2_1_4bits sel_reset (.a(tras_bajar), .b(4'b0000),    .sel(reset), .salida(siguiente));

    dff bit0 (.D(siguiente[0]), .CLK(clk), .Q(Q[0]));
    dff bit1 (.D(siguiente[1]), .CLK(clk), .Q(Q[1]));
    dff bit2 (.D(siguiente[2]), .CLK(clk), .Q(Q[2]));
    dff bit3 (.D(siguiente[3]), .CLK(clk), .Q(Q[3]));

endmodule
