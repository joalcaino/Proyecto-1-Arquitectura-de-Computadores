// sumador_restador_4bits_tb.v
// Testbench del sumador/restador de 4 bits compartido.
// Recorre las 3 combinaciones de control usadas por el proyecto (suma, resta,
// resta inversa) para las 16x16 combinaciones de A y B, y compara contra el
// resultado esperado en modulo 16 (equivalente a complemento a dos truncado
// a 4 bits, que es justamente la regla de overflow del enunciado).
//
// Nota: el testbench SI puede usar operadores de alto nivel (+, -, %) porque
// no es el diseno que se sube a la FPGA, es solo el modelo de referencia para
// verificar que el diseno estructural (full_adder.v + sumador_restador_4bits.v)
// se comporta como se espera.

`timescale 1ns/1ps

module sumador_restador_4bits_tb;

    reg  [3:0] A, B;
    reg        invA, invB, Cin;
    wire [3:0] S;

    integer a, b;
    reg [4:0] esperado_ext; // 5 bits para poder calcular mod 16 comodamente
    reg [3:0] esperado;
    integer errores;

    sumador_restador_4bits dut (
        .A(A), .B(B), .invA(invA), .invB(invB), .Cin(Cin), .S(S)
    );

    task correr_caso;
        input [3:0] a_in, b_in;
        input inv_a, inv_b, cin_in;
        begin
            A = a_in; B = b_in; invA = inv_a; invB = inv_b; Cin = cin_in;
            #5;
        end
    endtask

    initial begin
        $dumpfile("sumador_restador_4bits_tb.vcd");
        $dumpvars(0, sumador_restador_4bits_tb);

        errores = 0;

        // ---- Caso 1: SUMA (invA=0, invB=0, Cin=0) -> R = (A+B) mod 16 ----
        for (a = 0; a < 16; a = a + 1) begin
            for (b = 0; b < 16; b = b + 1) begin
                correr_caso(a[3:0], b[3:0], 1'b0, 1'b0, 1'b0);
                esperado = (a + b) % 16;
                if (S !== esperado) begin
                    errores = errores + 1;
                    $display("FALLO SUMA: A=%0d B=%0d -> S=%0d (esperado %0d)", a, b, S, esperado);
                end
            end
        end

        // ---- Caso 2: RESTA A-B (invA=0, invB=1, Cin=1) -> R = (A-B) mod 16 ----
        for (a = 0; a < 16; a = a + 1) begin
            for (b = 0; b < 16; b = b + 1) begin
                correr_caso(a[3:0], b[3:0], 1'b0, 1'b1, 1'b1);
                esperado = (a - b + 16) % 16;
                if (S !== esperado) begin
                    errores = errores + 1;
                    $display("FALLO RESTA: A=%0d B=%0d -> S=%0d (esperado %0d)", a, b, S, esperado);
                end
            end
        end

        // ---- Caso 3: RESTA INVERSA B-A (invA=1, invB=0, Cin=1) -> R = (B-A) mod 16 ----
        for (a = 0; a < 16; a = a + 1) begin
            for (b = 0; b < 16; b = b + 1) begin
                correr_caso(a[3:0], b[3:0], 1'b1, 1'b0, 1'b1);
                esperado = (b - a + 16) % 16;
                if (S !== esperado) begin
                    errores = errores + 1;
                    $display("FALLO RESTA INVERSA: A=%0d B=%0d -> S=%0d (esperado %0d)", a, b, S, esperado);
                end
            end
        end

        if (errores == 0)
            $display("TODOS LOS CASOS PASARON (768/768: 256 suma + 256 resta + 256 resta inversa).");
        else
            $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
