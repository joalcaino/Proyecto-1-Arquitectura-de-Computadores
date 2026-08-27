// contador_incremental_6bits.v
// Igual que contador_incremental_8bits.v pero de 6 bits: contador de un
// solo sentido, suma 1 cada flanco de reloj mientras "incrementar"=1, se
// limpia a 0 cuando "limpiar"=1 (prioridad).
//
// Se usa dentro de debounce.v como "preescaler": un contador libre (siempre
// incrementando, incrementar=1 fijo) que genera un pulso de 1 ciclo cada 64
// ciclos de reloj. La idea completa (ver debounce.v): en vez de una sola
// cadena larga de sumadores para llegar a un umbral de ~10.5ms (que resulto
// romper el tiempo real del reloj a 25MHz cuando se probo con 18 bits en
// una sola cadena -- funcionaba perfecto en simulacion pero NINGUN boton
// respondia en la placa real), se combinan DOS cadenas cortas e
// independientes: este contador de 6 bits (preescaler) mas el contador de
// debounce de 12 bits (que ya se confirmo que SI cierra timing en la placa
// real). Cada cadena individual queda corta (6 y 12 sumadores), pero el
// tiempo total equivalente es el mismo (2^6 x 2^12 = 262144 ciclos, ~10.5ms).
// Proyecto 1 - Arquitectura de Computadores.
//
// Reutiliza incrementador_6bits.v, mux2_1.v y dff.v, todos ya verificados.

module contador_incremental_6bits (
    input  wire       incrementar,
    input  wire       limpiar,
    input  wire       clk,
    output wire [5:0] Q
);

    wire [5:0] Q_mas_1, tras_inc, siguiente;

    incrementador_6bits inc (.A(Q), .resultado(Q_mas_1));

    mux2_1 s0 (.a(Q[0]), .b(Q_mas_1[0]), .sel(incrementar), .salida(tras_inc[0]));
    mux2_1 s1 (.a(Q[1]), .b(Q_mas_1[1]), .sel(incrementar), .salida(tras_inc[1]));
    mux2_1 s2 (.a(Q[2]), .b(Q_mas_1[2]), .sel(incrementar), .salida(tras_inc[2]));
    mux2_1 s3 (.a(Q[3]), .b(Q_mas_1[3]), .sel(incrementar), .salida(tras_inc[3]));
    mux2_1 s4 (.a(Q[4]), .b(Q_mas_1[4]), .sel(incrementar), .salida(tras_inc[4]));
    mux2_1 s5 (.a(Q[5]), .b(Q_mas_1[5]), .sel(incrementar), .salida(tras_inc[5]));

    mux2_1 l0 (.a(tras_inc[0]), .b(1'b0), .sel(limpiar), .salida(siguiente[0]));
    mux2_1 l1 (.a(tras_inc[1]), .b(1'b0), .sel(limpiar), .salida(siguiente[1]));
    mux2_1 l2 (.a(tras_inc[2]), .b(1'b0), .sel(limpiar), .salida(siguiente[2]));
    mux2_1 l3 (.a(tras_inc[3]), .b(1'b0), .sel(limpiar), .salida(siguiente[3]));
    mux2_1 l4 (.a(tras_inc[4]), .b(1'b0), .sel(limpiar), .salida(siguiente[4]));
    mux2_1 l5 (.a(tras_inc[5]), .b(1'b0), .sel(limpiar), .salida(siguiente[5]));

    dff bit0 (.D(siguiente[0]), .CLK(clk), .Q(Q[0]));
    dff bit1 (.D(siguiente[1]), .CLK(clk), .Q(Q[1]));
    dff bit2 (.D(siguiente[2]), .CLK(clk), .Q(Q[2]));
    dff bit3 (.D(siguiente[3]), .CLK(clk), .Q(Q[3]));
    dff bit4 (.D(siguiente[4]), .CLK(clk), .Q(Q[4]));
    dff bit5 (.D(siguiente[5]), .CLK(clk), .Q(Q[5]));

endmodule
