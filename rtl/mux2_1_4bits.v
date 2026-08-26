// mux2_1_4bits.v
// Multiplexor 2:1 de 4 bits: 4 instancias de mux2_1 (1 bit) con el mismo sel.
//
// Uso principal (informe, Diagrama de bloques): selector de op2.
//   sel=0 -> op2 externo ; sel=1 -> resultado anterior (realimentacion)
//
// El mismo modulo se reutiliza tal cual en las etapas del barrel shifter y
// en el arbol del decodificador de operacion (cambia solo el cableado externo).

module mux2_1_4bits (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       sel,
    output wire [3:0] salida
);

    mux2_1 m0 (.a(a[0]), .b(b[0]), .sel(sel), .salida(salida[0]));
    mux2_1 m1 (.a(a[1]), .b(b[1]), .sel(sel), .salida(salida[1]));
    mux2_1 m2 (.a(a[2]), .b(b[2]), .sel(sel), .salida(salida[2]));
    mux2_1 m3 (.a(a[3]), .b(b[3]), .sel(sel), .salida(salida[3]));

endmodule
