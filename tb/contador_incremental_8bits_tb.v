// contador_incremental_8bits_tb.v
// Testbench de contador_incremental_8bits.v: limpia, cuenta 256 pulsos
// seguidos (debe volver a 0 por wrap-around), y verifica que "limpiar"
// interrumpe el conteo en cualquier momento.

`timescale 1ns/1ps

module contador_incremental_8bits_tb;

    reg incrementar, limpiar, clk;
    wire [7:0] Q;
    integer i, errores;

    contador_incremental_8bits dut (.incrementar(incrementar), .limpiar(limpiar), .clk(clk), .Q(Q));

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("contador_incremental_8bits_tb.vcd");
        $dumpvars(0, contador_incremental_8bits_tb);
        errores = 0;
        incrementar = 0; limpiar = 1;

        @(posedge clk); #1;
        limpiar = 0;
        if (Q !== 8'd0) begin errores=errores+1; $display("FALLO limpiar inicial: Q=%0d",Q); end
        else $display("OK limpiar inicial: Q=%0d", Q);

        // Cuenta 10 veces, chequea 1..10
        incrementar = 1;
        for (i = 1; i <= 10; i = i + 1) begin
            @(posedge clk); #1;
            if (Q !== i[7:0]) begin errores=errores+1; $display("FALLO cuenta %0d: Q=%0d",i,Q); end
        end
        $display("Tras 10 pulsos: Q=%0d (esperado 10)", Q);

        // Limpia en medio del conteo
        limpiar = 1;
        @(posedge clk); #1;
        limpiar = 0;
        if (Q !== 8'd0) begin errores=errores+1; $display("FALLO limpiar a mitad: Q=%0d",Q); end
        else $display("OK limpiar a mitad: Q=%0d", Q);

        // Cuenta 256 pulsos seguidos: debe volver a 0 por wrap
        for (i = 1; i <= 256; i = i + 1) begin
            @(posedge clk); #1;
        end
        if (Q !== 8'd0) begin errores=errores+1; $display("FALLO wrap tras 256: Q=%0d (esperado 0)",Q); end
        else $display("OK wrap tras 256 pulsos: Q=%0d", Q);

        if (errores == 0) $display("TODOS LOS CASOS PASARON.");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
