// debounce_tb.v
// Testbench de debounce.v: simula un boton que "rebota" (varios cambios
// rapidos) y despues se asienta en un valor. Verifica que boton_estable
// NO se mueve mientras dura el rebote (rafagas cortas, muy por debajo
// de las 256 ciclos), y que SI se actualiza despues de 256 ciclos de
// estabilidad continua.

`timescale 1ns/1ps

module debounce_tb;

    reg boton_crudo, clk, reset;
    wire boton_estable;
    integer i, errores;

    debounce dut (.boton_crudo(boton_crudo), .clk(clk), .reset(reset), .boton_estable(boton_estable));

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("debounce_tb.vcd");
        $dumpvars(0, debounce_tb);
        errores = 0;
        boton_crudo = 0; reset = 1;

        @(posedge clk); #1;
        reset = 0;
        if (boton_estable !== 1'b0) begin errores=errores+1; $display("FALLO reset: boton_estable=%b",boton_estable); end
        else $display("OK reset: boton_estable=%b", boton_estable);

        // Simula el rebote: 20 cambios rapidos (mucho menos que 256 ciclos
        // cada uno) antes de asentarse en 1
        for (i = 0; i < 20; i = i + 1) begin
            boton_crudo = ~boton_crudo;
            @(posedge clk); #1;
            if (boton_estable !== 1'b0) begin
                errores = errores + 1;
                $display("FALLO durante rebote (paso %0d): boton_estable=%b (no deberia haberse movido)", i, boton_estable);
            end
        end
        boton_crudo = 1; // se asienta en 1

        // Debe seguir en 0 justo despues de asentarse (todavia no pasaron 256 ciclos)
        @(posedge clk); #1;
        if (boton_estable !== 1'b0) begin errores=errores+1; $display("FALLO justo tras asentarse: boton_estable=%b",boton_estable); end
        else $display("OK justo tras asentarse (raw=1, estable aun=0): boton_estable=%b", boton_estable);

        // Espera 254 ciclos mas (255 en total desde que se asento) -> todavia no debe cambiar
        for (i = 0; i < 254; i = i + 1) begin @(posedge clk); #1; end
        if (boton_estable !== 1'b0) begin errores=errores+1; $display("FALLO a los 255 ciclos: boton_estable=%b (esperado 0 todavia)",boton_estable); end
        else $display("OK a los 255 ciclos estable: boton_estable=%b (todavia 0)", boton_estable);

        // Un ciclo mas (256 en total) -> ahora si debe pasar a 1
        @(posedge clk); #1;
        if (boton_estable !== 1'b1) begin errores=errores+1; $display("FALLO a los 256 ciclos: boton_estable=%b (esperado 1)",boton_estable); end
        else $display("OK a los 256 ciclos estable: boton_estable=%b (ya es 1)", boton_estable);

        // Ahora prueba que vuelve a 0 tras soltarlo y esperar otros 256 ciclos
        boton_crudo = 0;
        for (i = 0; i < 255; i = i + 1) begin @(posedge clk); #1; end
        if (boton_estable !== 1'b1) begin errores=errores+1; $display("FALLO a los 255 ciclos (soltando): boton_estable=%b (esperado 1 todavia)",boton_estable); end
        else $display("OK a los 255 ciclos soltando: boton_estable=%b (todavia 1)", boton_estable);

        @(posedge clk); #1;
        if (boton_estable !== 1'b0) begin errores=errores+1; $display("FALLO a los 256 ciclos (soltando): boton_estable=%b (esperado 0)",boton_estable); end
        else $display("OK a los 256 ciclos soltando: boton_estable=%b (ya es 0)", boton_estable);

        if (errores == 0) $display("TODOS LOS CASOS PASARON.");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
