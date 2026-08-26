// detector_flanco_tb.v
// Testbench de detector_flanco.v: mantiene la senal en 0 varios ciclos,
// la sube a 1 y verifica que "pulso" es 1 SOLO en ese primer ciclo, y
// vuelve a 0 aunque la senal se mantenga en 1 varios ciclos mas.

`timescale 1ns/1ps

module detector_flanco_tb;

    reg senal, clk, reset;
    wire pulso;
    integer i, errores;

    detector_flanco dut (.senal(senal), .clk(clk), .reset(reset), .pulso(pulso));

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("detector_flanco_tb.vcd");
        $dumpvars(0, detector_flanco_tb);
        errores = 0;
        senal = 0; reset = 1;

        @(posedge clk); #1;
        reset = 0;
        if (pulso !== 1'b0) begin errores=errores+1; $display("FALLO reset: pulso=%b",pulso); end
        else $display("OK reset: pulso=%b", pulso);

        // senal en 0 varios ciclos: pulso debe seguir en 0
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge clk); #1;
            if (pulso !== 1'b0) begin errores=errores+1; $display("FALLO senal=0 (paso %0d): pulso=%b",i,pulso); end
        end

        // Sube la senal a 1: en el PRIMER ciclo tras el flanco, pulso debe ser 1
        senal = 1;
        @(posedge clk); #1;
        if (pulso !== 1'b1) begin errores=errores+1; $display("FALLO flanco de subida: pulso=%b (esperado 1)",pulso); end
        else $display("OK flanco de subida: pulso=%b", pulso);

        // Mantiene la senal en 1 varios ciclos mas: pulso debe volver a 0
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk); #1;
            if (pulso !== 1'b0) begin
                errores = errores + 1;
                $display("FALLO senal sostenida en 1 (paso %0d): pulso=%b (esperado 0, no debe repetirse)", i, pulso);
            end
        end
        $display("OK: pulso no se repite mientras la senal sigue en 1");

        // Baja la senal a 0: pulso debe seguir en 0 (no hay flanco de bajada que detectar)
        senal = 0;
        @(posedge clk); #1;
        if (pulso !== 1'b0) begin errores=errores+1; $display("FALLO flanco de bajada: pulso=%b (esperado 0)",pulso); end
        else $display("OK flanco de bajada (no genera pulso): pulso=%b", pulso);

        // Segundo flanco de subida: debe generar un nuevo pulso
        senal = 1;
        @(posedge clk); #1;
        if (pulso !== 1'b1) begin errores=errores+1; $display("FALLO segundo flanco: pulso=%b (esperado 1)",pulso); end
        else $display("OK segundo flanco de subida: pulso=%b", pulso);

        if (errores == 0) $display("TODOS LOS CASOS PASARON.");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
