// decodificador_hex_7seg.v
// Decodificador de hexadecimal (4 bits, 0 a F) a 7 segmentos, para el
// segundo display de 7 segmentos de la Go Board (el primero muestra el
// signo +/-, ver decodificador_signo.v).
// Proyecto 1 - Arquitectura de Computadores.
//
// Por cada segmento (a..g) hay un mux16_1 que, segun el digito de
// entrada (0000 a 1111), elige uno de 16 valores fijos -- el equivalente
// estructural de una tabla de verdad / "case", sin usar if/case.
//
// Los 16 valores de cada mux16_1 salen de una tabla de 7 segmentos
// estandar (activo-ALTO: 1 = segmento encendido), generada con un script
// para no transcribirla a mano y evitar errores. Por ejemplo, para el
// segmento a, el digito 0 usa 1, el digito 1 usa 0, etc.
//
// La Go Board usa segmentos activos en BAJO (0 = encendido, ver el
// ejemplo oficial de Nandland: "o_Segment_A <= not w_Segment_A;"). Por
// eso cada salida de mux16_1 (activa-alta) pasa por un "not" antes de
// llegar al puerto de salida.
//
// Reutiliza mux16_1.v (y por lo tanto mux2_1.v) ya verificados; no
// agrega compuertas nuevas aparte de los 7 "not" finales.

module decodificador_hex_7seg (
    input  wire [3:0] digito,
    output wire        seg_a,
    output wire        seg_b,
    output wire        seg_c,
    output wire        seg_d,
    output wire        seg_e,
    output wire        seg_f,
    output wire        seg_g
);

    // Valores activos-ALTO (1 = encendido), bit15=digito F ... bit0=digito 0.
    wire a_h, b_h, c_h, d_h, e_h, f_h, g_h;

    mux16_1 mux_a (.in(16'b1101011111101101), .sel(digito), .salida(a_h));
    mux16_1 mux_b (.in(16'b0010011110011111), .sel(digito), .salida(b_h));
    mux16_1 mux_c (.in(16'b0010111111111011), .sel(digito), .salida(c_h));
    mux16_1 mux_d (.in(16'b0111101101101101), .sel(digito), .salida(d_h));
    mux16_1 mux_e (.in(16'b1111110101000101), .sel(digito), .salida(e_h));
    mux16_1 mux_f (.in(16'b1101111101110001), .sel(digito), .salida(f_h));
    mux16_1 mux_g (.in(16'b1110111101111100), .sel(digito), .salida(g_h));

    // Inversion final: la Go Board necesita activo-BAJO.
    not (seg_a, a_h);
    not (seg_b, b_h);
    not (seg_c, c_h);
    not (seg_d, d_h);
    not (seg_e, e_h);
    not (seg_f, f_h);
    not (seg_g, g_h);

endmodule
