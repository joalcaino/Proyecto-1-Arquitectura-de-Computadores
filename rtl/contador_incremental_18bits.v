// contador_incremental_18bits.v
// Igual que contador_incremental_8bits.v pero de 18 bits: contador de un
// solo sentido, suma 1 cada flanco de reloj mientras "incrementar"=1, se
// limpia a 0 cuando "limpiar"=1 (prioridad). Se necesitan 18 bits (en vez
// de 8) para que el umbral de debounce.v equivalga a un tiempo real (~10ms)
// en vez de solo 256 ciclos (~10 microsegundos), que resulto ser demasiado
// corto para filtrar el rebote mecanico real de los botones de la Go Board
// (descubierto probando en la placa real, no en simulacion).
// Proyecto 1 - Arquitectura de Computadores.
//
// Reutiliza incrementador_18bits.v, mux2_1.v y dff.v, todos ya verificados.

module contador_incremental_18bits (
    input  wire       incrementar,
    input  wire       limpiar,
    input  wire       clk,
    output wire [17:0] Q
);

    wire [17:0] Q_mas_1, tras_inc, siguiente;

    incrementador_18bits inc (.A(Q), .resultado(Q_mas_1));

    mux2_1 s0 (.a(Q[0]), .b(Q_mas_1[0]), .sel(incrementar), .salida(tras_inc[0]));
    mux2_1 s1 (.a(Q[1]), .b(Q_mas_1[1]), .sel(incrementar), .salida(tras_inc[1]));
    mux2_1 s2 (.a(Q[2]), .b(Q_mas_1[2]), .sel(incrementar), .salida(tras_inc[2]));
    mux2_1 s3 (.a(Q[3]), .b(Q_mas_1[3]), .sel(incrementar), .salida(tras_inc[3]));
    mux2_1 s4 (.a(Q[4]), .b(Q_mas_1[4]), .sel(incrementar), .salida(tras_inc[4]));
    mux2_1 s5 (.a(Q[5]), .b(Q_mas_1[5]), .sel(incrementar), .salida(tras_inc[5]));
    mux2_1 s6 (.a(Q[6]), .b(Q_mas_1[6]), .sel(incrementar), .salida(tras_inc[6]));
    mux2_1 s7 (.a(Q[7]), .b(Q_mas_1[7]), .sel(incrementar), .salida(tras_inc[7]));
    mux2_1 s8 (.a(Q[8]), .b(Q_mas_1[8]), .sel(incrementar), .salida(tras_inc[8]));
    mux2_1 s9 (.a(Q[9]), .b(Q_mas_1[9]), .sel(incrementar), .salida(tras_inc[9]));
    mux2_1 s10 (.a(Q[10]), .b(Q_mas_1[10]), .sel(incrementar), .salida(tras_inc[10]));
    mux2_1 s11 (.a(Q[11]), .b(Q_mas_1[11]), .sel(incrementar), .salida(tras_inc[11]));
    mux2_1 s12 (.a(Q[12]), .b(Q_mas_1[12]), .sel(incrementar), .salida(tras_inc[12]));
    mux2_1 s13 (.a(Q[13]), .b(Q_mas_1[13]), .sel(incrementar), .salida(tras_inc[13]));
    mux2_1 s14 (.a(Q[14]), .b(Q_mas_1[14]), .sel(incrementar), .salida(tras_inc[14]));
    mux2_1 s15 (.a(Q[15]), .b(Q_mas_1[15]), .sel(incrementar), .salida(tras_inc[15]));
    mux2_1 s16 (.a(Q[16]), .b(Q_mas_1[16]), .sel(incrementar), .salida(tras_inc[16]));
    mux2_1 s17 (.a(Q[17]), .b(Q_mas_1[17]), .sel(incrementar), .salida(tras_inc[17]));

    mux2_1 l0 (.a(tras_inc[0]), .b(1'b0), .sel(limpiar), .salida(siguiente[0]));
    mux2_1 l1 (.a(tras_inc[1]), .b(1'b0), .sel(limpiar), .salida(siguiente[1]));
    mux2_1 l2 (.a(tras_inc[2]), .b(1'b0), .sel(limpiar), .salida(siguiente[2]));
    mux2_1 l3 (.a(tras_inc[3]), .b(1'b0), .sel(limpiar), .salida(siguiente[3]));
    mux2_1 l4 (.a(tras_inc[4]), .b(1'b0), .sel(limpiar), .salida(siguiente[4]));
    mux2_1 l5 (.a(tras_inc[5]), .b(1'b0), .sel(limpiar), .salida(siguiente[5]));
    mux2_1 l6 (.a(tras_inc[6]), .b(1'b0), .sel(limpiar), .salida(siguiente[6]));
    mux2_1 l7 (.a(tras_inc[7]), .b(1'b0), .sel(limpiar), .salida(siguiente[7]));
    mux2_1 l8 (.a(tras_inc[8]), .b(1'b0), .sel(limpiar), .salida(siguiente[8]));
    mux2_1 l9 (.a(tras_inc[9]), .b(1'b0), .sel(limpiar), .salida(siguiente[9]));
    mux2_1 l10 (.a(tras_inc[10]), .b(1'b0), .sel(limpiar), .salida(siguiente[10]));
    mux2_1 l11 (.a(tras_inc[11]), .b(1'b0), .sel(limpiar), .salida(siguiente[11]));
    mux2_1 l12 (.a(tras_inc[12]), .b(1'b0), .sel(limpiar), .salida(siguiente[12]));
    mux2_1 l13 (.a(tras_inc[13]), .b(1'b0), .sel(limpiar), .salida(siguiente[13]));
    mux2_1 l14 (.a(tras_inc[14]), .b(1'b0), .sel(limpiar), .salida(siguiente[14]));
    mux2_1 l15 (.a(tras_inc[15]), .b(1'b0), .sel(limpiar), .salida(siguiente[15]));
    mux2_1 l16 (.a(tras_inc[16]), .b(1'b0), .sel(limpiar), .salida(siguiente[16]));
    mux2_1 l17 (.a(tras_inc[17]), .b(1'b0), .sel(limpiar), .salida(siguiente[17]));

    dff bit0 (.D(siguiente[0]), .CLK(clk), .Q(Q[0]));
    dff bit1 (.D(siguiente[1]), .CLK(clk), .Q(Q[1]));
    dff bit2 (.D(siguiente[2]), .CLK(clk), .Q(Q[2]));
    dff bit3 (.D(siguiente[3]), .CLK(clk), .Q(Q[3]));
    dff bit4 (.D(siguiente[4]), .CLK(clk), .Q(Q[4]));
    dff bit5 (.D(siguiente[5]), .CLK(clk), .Q(Q[5]));
    dff bit6 (.D(siguiente[6]), .CLK(clk), .Q(Q[6]));
    dff bit7 (.D(siguiente[7]), .CLK(clk), .Q(Q[7]));
    dff bit8 (.D(siguiente[8]), .CLK(clk), .Q(Q[8]));
    dff bit9 (.D(siguiente[9]), .CLK(clk), .Q(Q[9]));
    dff bit10 (.D(siguiente[10]), .CLK(clk), .Q(Q[10]));
    dff bit11 (.D(siguiente[11]), .CLK(clk), .Q(Q[11]));
    dff bit12 (.D(siguiente[12]), .CLK(clk), .Q(Q[12]));
    dff bit13 (.D(siguiente[13]), .CLK(clk), .Q(Q[13]));
    dff bit14 (.D(siguiente[14]), .CLK(clk), .Q(Q[14]));
    dff bit15 (.D(siguiente[15]), .CLK(clk), .Q(Q[15]));
    dff bit16 (.D(siguiente[16]), .CLK(clk), .Q(Q[16]));
    dff bit17 (.D(siguiente[17]), .CLK(clk), .Q(Q[17]));

endmodule
