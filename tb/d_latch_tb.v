// d_latch_tb.v
// Testbench del latch D: prueba que es transparente con EN=1 (Q sigue a D)
// y que retiene el valor con EN=0 (Q se congela, ignora cambios de D).

`timescale 1ns/1ps

module d_latch_tb;

    reg D, EN;
    wire Q;
    integer errores;

    d_latch dut (.D(D), .EN(EN), .Q(Q));

    initial begin
        $dumpfile("d_latch_tb.vcd");
        $dumpvars(0, d_latch_tb);
        errores = 0;

        // Transparente: EN=1, Q debe seguir a D
        EN = 1; D = 0; #10;
        if (Q !== 1'b0) begin errores=errores+1; $display("FALLO transp D=0: Q=%b",Q); end
        else $display("OK transp D=0: Q=%b", Q);

        D = 1; #10;
        if (Q !== 1'b1) begin errores=errores+1; $display("FALLO transp D=1: Q=%b",Q); end
        else $display("OK transp D=1: Q=%b", Q);

        D = 0; #10;
        if (Q !== 1'b0) begin errores=errores+1; $display("FALLO transp D=0(2): Q=%b",Q); end
        else $display("OK transp D=0(2): Q=%b", Q);

        // Retiene: EN pasa a 0 con D=1 justo antes -> Q debe congelarse en 1
        D = 1; #10;   // D=1 mientras EN=1 todavia
        EN = 0; #10;  // se congela

        if (Q !== 1'b1) begin errores=errores+1; $display("FALLO al congelar: Q=%b (esperado 1)",Q); end
        else $display("OK al congelar: Q=%b", Q);

        // Con EN=0, cambiar D no debe afectar a Q
        D = 0; #10;
        if (Q !== 1'b1) begin errores=errores+1; $display("FALLO hold ignora D: Q=%b (esperado 1)",Q); end
        else $display("OK hold ignora D: Q=%b", Q);

        D = 1; #10;
        if (Q !== 1'b1) begin errores=errores+1; $display("FALLO hold ignora D(2): Q=%b (esperado 1)",Q); end
        else $display("OK hold ignora D(2): Q=%b", Q);

        // Vuelve a ser transparente
        EN = 1; D = 0; #10;
        if (Q !== 1'b0) begin errores=errores+1; $display("FALLO vuelve a transp: Q=%b (esperado 0)",Q); end
        else $display("OK vuelve a transp: Q=%b", Q);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (7/7).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
