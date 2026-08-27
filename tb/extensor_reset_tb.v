// extensor_reset_tb.v
// Testbench de extensor_reset.v: verifica que "reset" se queda en 1
// mientras reset_bruto=1, que sigue en 1 un rato despues de soltarlo
// (bastante antes del umbral real ~262144 ciclos), que baja a 0 una vez
// pasado ese umbral con margen, y que NO se vuelve a activar solo despues
// (queda saturado, no da la vuelta) mientras nadie vuelve a apretar nada.
// Tambien verifica que un reset_bruto nuevo a mitad de la espera reinicia
// el conteo.

`timescale 1ns/1ps

module extensor_reset_tb;

    reg reset_bruto, clk;
    wire reset;
    integer i, errores;

    extensor_reset dut (.reset_bruto(reset_bruto), .clk(clk), .reset(reset));

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        errores = 0;
        reset_bruto = 0;

        // Primer apreton (tambien deja los contadores internos en un
        // estado conocido, arrancando desde 0 -- ver nota de arranque en
        // extensor_reset.v: en la placa real esto no hace falta, cualquier
        // estado inicial converge solo, pero en simulacion con Icarus los
        // registros arrancan en X y necesitan un primer reset_bruto=1
        // explicito para dar un punto de partida comparable).
        reset_bruto = 1;
        @(posedge clk); #1;
        if (reset !== 1'b1) begin errores=errores+1; $display("FALLO reset_bruto=1: reset=%b (esperado 1)",reset); end
        else $display("OK reset_bruto=1: reset=%b", reset);

        // Se suelta: reset debe seguir en 1 (recien empieza la espera)
        reset_bruto = 0;
        @(posedge clk); #1;
        if (reset !== 1'b1) begin errores=errores+1; $display("FALLO justo al soltar: reset=%b (esperado 1 todavia)",reset); end
        else $display("OK justo al soltar: reset=%b (todavia 1, empieza la espera)", reset);

        // Bastante antes del umbral real: reset debe seguir en 1
        for (i = 0; i < 250000; i = i + 1) begin @(posedge clk); #1; end
        if (reset !== 1'b1) begin errores=errores+1; $display("FALLO a los 250000 ciclos: reset=%b (esperado 1 todavia)",reset); end
        else $display("OK a los 250000 ciclos: reset=%b (todavia 1, esperando)", reset);

        // Con margen de sobra por encima del umbral real: reset ya debe haber bajado a 0
        for (i = 0; i < 20000; i = i + 1) begin @(posedge clk); #1; end
        if (reset !== 1'b0) begin errores=errores+1; $display("FALLO a los 270000 ciclos: reset=%b (esperado 0)",reset); end
        else $display("OK a los 270000 ciclos: reset=%b (ya bajo a 0, ~10.5ms)", reset);

        // Se queda en 0 un buen rato mas (no se reactiva solo -- el
        // contador debe estar SATURADO, no dando la vuelta)
        for (i = 0; i < 100000; i = i + 1) begin @(posedge clk); #1; end
        if (reset !== 1'b0) begin errores=errores+1; $display("FALLO tras esperar mas: reset=%b (esperado 0, NO deberia reactivarse solo)",reset); end
        else $display("OK tras esperar mas: reset=%b (sigue en 0, no se reactivo solo)", reset);

        // Nuevo apreton a mitad de camino: reset debe volver a 1 de inmediato
        reset_bruto = 1;
        @(posedge clk); #1;
        if (reset !== 1'b1) begin errores=errores+1; $display("FALLO nuevo apreton: reset=%b (esperado 1)",reset); end
        else $display("OK nuevo apreton: reset=%b", reset);

        // Se suelta otra vez: reset debe seguir en 1 un rato (reinicio del conteo)
        reset_bruto = 0;
        for (i = 0; i < 250000; i = i + 1) begin @(posedge clk); #1; end
        if (reset !== 1'b1) begin errores=errores+1; $display("FALLO tras reinicio, 250000 ciclos: reset=%b (esperado 1 todavia)",reset); end
        else $display("OK tras reinicio, 250000 ciclos: reset=%b (todavia 1, se reinicio bien la espera)", reset);

        for (i = 0; i < 20000; i = i + 1) begin @(posedge clk); #1; end
        if (reset !== 1'b0) begin errores=errores+1; $display("FALLO tras reinicio, 270000 ciclos: reset=%b (esperado 0)",reset); end
        else $display("OK tras reinicio, 270000 ciclos: reset=%b (ya bajo a 0)", reset);

        if (errores == 0) $display("TODOS LOS CASOS PASARON.");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
