// contador_operacion.v
// Contador de 3 bits para elegir el codigo de operacion con subir/bajar,
// dando la vuelta SOLO entre los 6 codigos validos: 000 (reinicio) a 101
// (shift right) -- nunca pasa por 110 ni 111 (decidido con Jo, 26-ago).
// Proyecto 1 - Arquitectura de Computadores.
//
// Reutiliza incrementador_4bits/decrementador_4bits (con el bit alto en 0,
// ya que el codigo es de 3 bits) para calcular el "siguiente valor normal",
// y le agrega deteccion de los dos casos borde:
//   Q==101 y subir=1 -> el siguiente valor no es 110, es 000 (wrap)
//   Q==000 y bajar=1 -> el siguiente valor no es 111, es 101 (wrap)
//
// Tiene ademas una entrada "reset": fuerza Q a 000 en el siguiente flanco
// de reloj, sin pasar por el incrementador/decrementador (necesario porque
// Q se retroalimenta a si mismo a traves de compuertas XOR -- si el
// flip-flop arranca en estado desconocido, como al encender la FPGA, el
// XOR nunca "sale" solo de ese estado; el reset lo fuerza directamente).
//
// Prioridad si hay varias senales activas a la vez: reset > bajar > subir.
//
// Reutiliza incrementador_4bits, decrementador_4bits, mux2_1 y dff, todos
// ya verificados. No agrega compuertas nuevas.

module contador_operacion (
    input  wire subir,
    input  wire bajar,
    input  wire reset,
    input  wire clk,
    output wire [2:0] Q
);

    wire [3:0] inc4, dec4;
    incrementador_4bits u_inc (.A({1'b0, Q}), .resultado(inc4));
    decrementador_4bits u_dec (.A({1'b0, Q}), .resultado(dec4));

    // es_maximo = (Q == 3'b101) ; es_minimo = (Q == 3'b000)
    wire q2n, q1n, q0n, es_maximo, es_minimo;
    not (q2n, Q[2]);
    not (q1n, Q[1]);
    not (q0n, Q[0]);
    and (es_maximo, Q[2], q1n, Q[0]);
    and (es_minimo, q2n, q1n, q0n);

    // Valor a usar si se aprieta "subir": normalmente inc4[2:0], pero si
    // ya estabamos en el maximo (101), se fuerza a 000.
    wire [2:0] subir_valor;
    mux2_1 wrap_s0 (.a(inc4[0]), .b(1'b0), .sel(es_maximo), .salida(subir_valor[0]));
    mux2_1 wrap_s1 (.a(inc4[1]), .b(1'b0), .sel(es_maximo), .salida(subir_valor[1]));
    mux2_1 wrap_s2 (.a(inc4[2]), .b(1'b0), .sel(es_maximo), .salida(subir_valor[2]));

    // Valor a usar si se aprieta "bajar": normalmente dec4[2:0], pero si
    // ya estabamos en el minimo (000), se fuerza a 101.
    wire [2:0] bajar_valor;
    mux2_1 wrap_b0 (.a(dec4[0]), .b(1'b1), .sel(es_minimo), .salida(bajar_valor[0]));
    mux2_1 wrap_b1 (.a(dec4[1]), .b(1'b0), .sel(es_minimo), .salida(bajar_valor[1]));
    mux2_1 wrap_b2 (.a(dec4[2]), .b(1'b1), .sel(es_minimo), .salida(bajar_valor[2]));

    // Selecciona segun el boton apretado (bajar tiene prioridad si ambos)
    wire [2:0] tras_subir, tras_bajar, siguiente;
    mux2_1 sel_s0 (.a(Q[0]), .b(subir_valor[0]), .sel(subir), .salida(tras_subir[0]));
    mux2_1 sel_s1 (.a(Q[1]), .b(subir_valor[1]), .sel(subir), .salida(tras_subir[1]));
    mux2_1 sel_s2 (.a(Q[2]), .b(subir_valor[2]), .sel(subir), .salida(tras_subir[2]));

    mux2_1 sel_b0 (.a(tras_subir[0]), .b(bajar_valor[0]), .sel(bajar), .salida(tras_bajar[0]));
    mux2_1 sel_b1 (.a(tras_subir[1]), .b(bajar_valor[1]), .sel(bajar), .salida(tras_bajar[1]));
    mux2_1 sel_b2 (.a(tras_subir[2]), .b(bajar_valor[2]), .sel(bajar), .salida(tras_bajar[2]));

    // Reset tiene la ultima palabra: fuerza 000 sin importar subir/bajar.
    mux2_1 sel_r0 (.a(tras_bajar[0]), .b(1'b0), .sel(reset), .salida(siguiente[0]));
    mux2_1 sel_r1 (.a(tras_bajar[1]), .b(1'b0), .sel(reset), .salida(siguiente[1]));
    mux2_1 sel_r2 (.a(tras_bajar[2]), .b(1'b0), .sel(reset), .salida(siguiente[2]));

    dff bit0 (.D(siguiente[0]), .CLK(clk), .Q(Q[0]));
    dff bit1 (.D(siguiente[1]), .CLK(clk), .Q(Q[1]));
    dff bit2 (.D(siguiente[2]), .CLK(clk), .Q(Q[2]));

endmodule
