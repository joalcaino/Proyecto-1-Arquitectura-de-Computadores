// barrel_shifter_left.v
// Barrel shifter - desplazamiento a la izquierda (A << B[1:0]).
// Proyecto 1 - Arquitectura de Computadores.
//
// Arbol de 2 etapas de mux2_1 (informe, seccion 3.4). Etapa 1 desplaza 0/1
// posicion (sel = monto[0]); etapa 2 desplaza 0/2 posiciones (sel = monto[1]).
// Combinadas cubren los 4 desplazamientos posibles (0 a 3). Relleno logico
// con 0 fijo cuando la entrada requerida "sale" del registro de 4 bits
// (conexiones segun la Tabla "Conexiones del barrel shifter para
// desplazamiento a la izquierda" del informe).
//
// Solo instancia el bloque mux2_1 ya verificado; no usa compuertas nuevas.

module barrel_shifter_left (
    input  wire [3:0] A,
    input  wire [1:0] monto,   // B[1:0]: cantidad de desplazamiento
    output wire [3:0] R
);

    wire [3:0] temp;

    // ---- Etapa 1 (sel = monto[0]): desplaza 0 o 1 posicion ----
    mux2_1 s1_bit3 (.a(A[3]), .b(A[2]),  .sel(monto[0]), .salida(temp[3]));
    mux2_1 s1_bit2 (.a(A[2]), .b(A[1]),  .sel(monto[0]), .salida(temp[2]));
    mux2_1 s1_bit1 (.a(A[1]), .b(A[0]),  .sel(monto[0]), .salida(temp[1]));
    mux2_1 s1_bit0 (.a(A[0]), .b(1'b0),  .sel(monto[0]), .salida(temp[0]));

    // ---- Etapa 2 (sel = monto[1]): desplaza 0 o 2 posiciones ----
    mux2_1 s2_bit3 (.a(temp[3]), .b(temp[1]), .sel(monto[1]), .salida(R[3]));
    mux2_1 s2_bit2 (.a(temp[2]), .b(temp[0]), .sel(monto[1]), .salida(R[2]));
    mux2_1 s2_bit1 (.a(temp[1]), .b(1'b0),    .sel(monto[1]), .salida(R[1]));
    mux2_1 s2_bit0 (.a(temp[0]), .b(1'b0),    .sel(monto[1]), .salida(R[0]));

endmodule
