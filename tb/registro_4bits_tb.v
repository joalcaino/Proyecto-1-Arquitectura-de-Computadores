// registro_4bits_tb.v
// Testbench del registro de 4 bits: confirma que con confirmar=0 el valor
// se retiene aunque D_nuevo cambie, que con confirmar=1 el valor nuevo se
// carga en el siguiente flanco de reloj, y que reset fuerza 0000.

`timescale 1ns/1ps

module registro_4bits_tb;

    reg  [3:0] D_nuevo;
    reg        confirmar, reset, clk;
    wire [3:0] Q;
    integer errores;

    registro_4bits dut (.D_nuevo(D_nuevo), .confirmar(confirmar), .reset(reset), .clk(clk), .Q(Q));

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("registro_4bits_tb.vcd");
        $dumpvars(0, registro_4bits_tb);
        errores = 0;

        // Estado inicial conocido, via reset (no via confirmar+D_nuevo=0)
        D_nuevo = 4'b1111; confirmar = 0; reset = 1;
        @(posedge clk); #1;
        reset = 0;
        if (Q !== 4'b0000) begin errores=errores+1; $display("FALLO estado inicial: Q=%b",Q); end
        else $display("OK estado inicial: Q=%b", Q);

        // Cargar 1010 con confirmar=1
        D_nuevo = 4'b1010; confirmar = 1;
        @(posedge clk); #1;
        if (Q !== 4'b1010) begin errores=errores+1; $display("FALLO carga 1010: Q=%b (esperado 1010)",Q); end
        else $display("OK carga 1010: Q=%b", Q);

        // confirmar=0: aunque D_nuevo cambie a otra cosa, Q debe retener 1010
        confirmar = 0;
        D_nuevo = 4'b0101;
        @(posedge clk); #1;
        if (Q !== 4'b1010) begin errores=errores+1; $display("FALLO retencion (1er flanco): Q=%b (esperado 1010)",Q); end
        else $display("OK retencion (1er flanco): Q=%b", Q);

        D_nuevo = 4'b1111;
        @(posedge clk); #1;
        if (Q !== 4'b1010) begin errores=errores+1; $display("FALLO retencion (2do flanco): Q=%b (esperado 1010)",Q); end
        else $display("OK retencion (2do flanco): Q=%b", Q);

        // confirmar=1 de nuevo: debe cargar lo que hay en D_nuevo en ese momento
        confirmar = 1;
        D_nuevo = 4'b0110;
        @(posedge clk); #1;
        if (Q !== 4'b0110) begin errores=errores+1; $display("FALLO carga 0110: Q=%b (esperado 0110)",Q); end
        else $display("OK carga 0110: Q=%b", Q);

        // Vuelve a retener
        confirmar = 0;
        D_nuevo = 4'b0001;
        @(posedge clk); #1;
        if (Q !== 4'b0110) begin errores=errores+1; $display("FALLO retencion final: Q=%b (esperado 0110)",Q); end
        else $display("OK retencion final: Q=%b", Q);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (6/6).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
