// mux2_1_4bits_tb.v
// Testbench exhaustivo para mux2_1_4bits.v: recorre las 16x16x2 = 512
// combinaciones de a, b y sel.

`timescale 1ns/1ps

module mux2_1_4bits_tb;

    reg  [3:0] a, b;
    reg        sel;
    wire [3:0] salida;

    integer ai, bi, si;
    reg [3:0] esperado;
    integer errores;

    mux2_1_4bits dut (.a(a), .b(b), .sel(sel), .salida(salida));

    initial begin
        $dumpfile("mux2_1_4bits_tb.vcd");
        $dumpvars(0, mux2_1_4bits_tb);

        errores = 0;

        for (ai = 0; ai < 16; ai = ai + 1) begin
            for (bi = 0; bi < 16; bi = bi + 1) begin
                for (si = 0; si < 2; si = si + 1) begin
                    a = ai[3:0]; b = bi[3:0]; sel = si[0];
                    #2;

                    esperado = sel ? b : a;

                    if (salida !== esperado) begin
                        errores = errores + 1;
                        $display("FALLO: a=%0d b=%0d sel=%b -> salida=%0d (esperado %0d)",
                                  a, b, sel, salida, esperado);
                    end
                end
            end
        end

        if (errores == 0)
            $display("TODOS LOS CASOS PASARON (512/512).");
        else
            $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
