// full_adder.v
// Sumador completo de 1 bit (full adder), Proyecto 1 - Arquitectura de Computadores.
//
// Implementado exclusivamente con primitivas de compuertas de Verilog
// (and, or, not, xor, nand, nor, xnor, buf) - sin operadores de alto nivel.
//
// Ecuaciones (ya derivadas y documentadas en el informe, seccion 3.1):
//   S    = A xor B xor Cin
//   Cout = (A and B) or (A and Cin) or (B and Cin)     -- funcion mayoria

module full_adder (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire S,
    output wire Cout
);

    // ---- Suma (S) ----
    wire ab_xor;
    xor (ab_xor, A, B);
    xor (S, ab_xor, Cin);

    // ---- Acarreo de salida (Cout) ----
    wire ab_and, a_cin_and, b_cin_and, or_ab_acin;
    and (ab_and,    A, B);
    and (a_cin_and, A, Cin);
    and (b_cin_and, B, Cin);

    or (or_ab_acin, ab_and, a_cin_and);
    or (Cout, or_ab_acin, b_cin_and);

endmodule
