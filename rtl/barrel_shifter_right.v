// barrel_shifter_right.v
// Barrel shifter - desplazamiento a la derecha (A >> B[1:0]).
// Proyecto 1 - Arquitectura de Computadores.
//
// Misma arquitectura que barrel_shifter_left.v (arbol de 2 etapas de mux2_1),
// pero imagen especular: en cada etapa se toma el bit SUPERIOR como entrada
// de reemplazo (en vez del inferior), y se rellena con 0 cuando ya no queda
// ningun bit superior disponible (conexiones segun la Tabla "Conexiones del
// barrel shifter para desplazamiento a la derecha" del informe).
//
// Solo instancia el bloque mux2_1 ya verificado; no usa compuertas nuevas.

module barrel_shifter_right (
    input  wire [3:0] A,
    input  wire [1:0] monto,   // B[1:0]: cantidad de desplazamiento
    output wire [3:0] R
);

    wire [3:0] temp;

    // ---- Etapa 1 (sel = monto[0]): desplaza 0 o 1 posicion ----
    mux2_1 s1_bit3 (.a(A[3]), .b(1'b0), .sel(monto[0]), .salida(temp[3]));
    mux2_1 s1_bit2 (.a(A[2]), .b(A[3]), .sel(monto[0]), .salida(temp[2]));
    mux2_1 s1_bit1 (.a(A[1]), .b(A[2]), .sel(monto[0]), .salida(temp[1]));
    mux2_1 s1_bit0 (.a(A[0]), .b(A[1]), .sel(monto[0]), .salida(temp[0]));

    // ---- Etapa 2 (sel = monto[1]): desplaza 0 o 2 posiciones ----
    mux2_1 s2_bit3 (.a(temp[3]), .b(1'b0),    .sel(monto[1]), .salida(R[3]));
    mux2_1 s2_bit2 (.a(temp[2]), .b(1'b0),    .sel(monto[1]), .salida(R[2]));
    mux2_1 s2_bit1 (.a(temp[1]), .b(temp[3]), .sel(monto[1]), .salida(R[1]));
    mux2_1 s2_bit0 (.a(temp[0]), .b(temp[2]), .sel(monto[1]), .salida(R[0]));

endmodule
