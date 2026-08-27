// incrementador_12bits.v
// Igual que incrementador_8bits.v pero de 12 bits: encadena 12 full_adder
// con B fijo en 0 y Cin=1 inyectado solo en el bit 0 (asi A+1 sin usar '+').
// Version reducida desde 18 bits: la cadena de 18 sumadores resulto
// demasiado larga (no cierra timing a 25MHz en el chip real, aunque en
// simulacion con Icarus -sin demoras reales- funcionaba perfecto). Se
// bajo a 12 bits para acortar la cadena combinacional mientras se mantiene
// un umbral de debounce bastante mayor al original de 8 bits (256 ciclos).
// Proyecto 1 - Arquitectura de Computadores.

module incrementador_12bits (
    input  wire [11:0] A,
    output wire [11:0] resultado
);

    wire [11:0] cout;

    full_adder fa0 (.A(A[0]), .B(1'b0), .Cin(1'b1), .S(resultado[0]), .Cout(cout[0]));
    full_adder fa1 (.A(A[1]), .B(1'b0), .Cin(cout[0]), .S(resultado[1]), .Cout(cout[1]));
    full_adder fa2 (.A(A[2]), .B(1'b0), .Cin(cout[1]), .S(resultado[2]), .Cout(cout[2]));
    full_adder fa3 (.A(A[3]), .B(1'b0), .Cin(cout[2]), .S(resultado[3]), .Cout(cout[3]));
    full_adder fa4 (.A(A[4]), .B(1'b0), .Cin(cout[3]), .S(resultado[4]), .Cout(cout[4]));
    full_adder fa5 (.A(A[5]), .B(1'b0), .Cin(cout[4]), .S(resultado[5]), .Cout(cout[5]));
    full_adder fa6 (.A(A[6]), .B(1'b0), .Cin(cout[5]), .S(resultado[6]), .Cout(cout[6]));
    full_adder fa7 (.A(A[7]), .B(1'b0), .Cin(cout[6]), .S(resultado[7]), .Cout(cout[7]));
    full_adder fa8 (.A(A[8]), .B(1'b0), .Cin(cout[7]), .S(resultado[8]), .Cout(cout[8]));
    full_adder fa9 (.A(A[9]), .B(1'b0), .Cin(cout[8]), .S(resultado[9]), .Cout(cout[9]));
    full_adder fa10 (.A(A[10]), .B(1'b0), .Cin(cout[9]), .S(resultado[10]), .Cout(cout[10]));
    full_adder fa11 (.A(A[11]), .B(1'b0), .Cin(cout[10]), .S(resultado[11]), .Cout(cout[11]));

endmodule
