// mux2_1_tb.v
// Testbench exhaustivo para mux2_1.v (recorre las 8 combinaciones de a, b, sel).

`timescale 1ns/1ps

module mux2_1_tb;

    reg  a, b, sel;
    wire salida;

    integer i;
    reg esperado;
    integer errores;

    mux2_1 dut (.a(a), .b(b), .sel(sel), .salida(salida));

    initial begin
        $dumpfile("mux2_1_tb.vcd");
        $dumpvars(0, mux2_1_tb);

        errores = 0;

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, sel} = i[2:0];
            #5;

            esperado = sel ? b : a;

            if (salida !== esperado) begin
                errores = errores + 1;
                $display("FALLO: a=%b b=%b sel=%b -> salida=%b (esperado %b)", a, b, sel, salida, esperado);
            end else begin
                $display("OK:    a=%b b=%b sel=%b -> salida=%b", a, b, sel, salida);
            end
        end

        if (errores == 0)
            $display("TODOS LOS CASOS PASARON (8/8).");
        else
            $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
