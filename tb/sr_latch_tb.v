// sr_latch_tb.v
// Testbench del latch SR: prueba set, reset y hold (mantener el valor).
// (El testbench usa control de tiempo normal de Verilog para verificar;
// esto no es parte del diseno que se sube a la FPGA.)

`timescale 1ns/1ps

module sr_latch_tb;

    reg S, R;
    wire Q, Qn;
    integer errores;

    sr_latch dut (.S(S), .R(R), .Q(Q), .Qn(Qn));

    initial begin
        $dumpfile("sr_latch_tb.vcd");
        $dumpvars(0, sr_latch_tb);
        errores = 0;

        // Set
        S = 1; R = 0; #10;
        if (Q !== 1'b1) begin errores = errores + 1; $display("FALLO SET: Q=%b (esperado 1)", Q); end
        else $display("OK SET: Q=%b", Q);

        // Hold (S=R=0): debe mantener Q=1
        S = 0; R = 0; #10;
        if (Q !== 1'b1) begin errores = errores + 1; $display("FALLO HOLD tras SET: Q=%b (esperado 1)", Q); end
        else $display("OK HOLD tras SET: Q=%b", Q);

        // Reset
        S = 0; R = 1; #10;
        if (Q !== 1'b0) begin errores = errores + 1; $display("FALLO RESET: Q=%b (esperado 0)", Q); end
        else $display("OK RESET: Q=%b", Q);

        // Hold (S=R=0): debe mantener Q=0
        S = 0; R = 0; #10;
        if (Q !== 1'b0) begin errores = errores + 1; $display("FALLO HOLD tras RESET: Q=%b (esperado 0)", Q); end
        else $display("OK HOLD tras RESET: Q=%b", Q);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (4/4).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
