// contador_4bits_tb.v
// Testbench de contador_4bits.v: aplica reset para partir de un estado
// conocido (0000), sube 16 veces seguidas y verifica que recorre
// 1,2,...,15,0 (wrap completo); despues baja 16 veces y verifica el
// camino inverso; y verifica que retiene el valor cuando ni subir ni
// bajar estan activos.

`timescale 1ns/1ps

module contador_4bits_tb;

    reg subir, bajar, reset, clk;
    wire [3:0] Q;
    integer i, errores;
    reg [3:0] esperado;

    contador_4bits dut (.subir(subir), .bajar(bajar), .reset(reset), .clk(clk), .Q(Q));

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("contador_4bits_tb.vcd");
        $dumpvars(0, contador_4bits_tb);
        errores = 0;
        subir = 0; bajar = 0; reset = 0;

        // Reset: fuerza estado conocido 0000
        reset = 1;
        @(posedge clk); #1;
        reset = 0;

        if (Q !== 4'b0000) begin errores=errores+1; $display("FALLO estado inicial: Q=%b (esperado 0000)",Q); end
        else $display("OK estado inicial: Q=%b", Q);

        // Sube 16 veces seguidas: debe recorrer 1,2,...,15,0
        for (i = 0; i < 16; i = i + 1) begin
            subir = 1;
            @(posedge clk); #1;
            subir = 0;
            esperado = (i + 1) & 4'hF;
            if (Q !== esperado) begin
                errores = errores + 1;
                $display("FALLO SUBIR paso %0d: Q=%b (esperado %b)", i, Q, esperado);
            end
        end
        $display("Tras 16 subidas: Q=%b (esperado 0000)", Q);

        // Retener: sin subir ni bajar, Q no debe cambiar
        @(posedge clk); #1;
        if (Q !== 4'b0000) begin errores=errores+1; $display("FALLO retener: Q=%b (esperado 0000)",Q); end
        else $display("OK retener: Q=%b", Q);

        // Baja 16 veces seguidas: debe recorrer 15,14,...,0
        for (i = 0; i < 16; i = i + 1) begin
            bajar = 1;
            @(posedge clk); #1;
            bajar = 0;
            esperado = (16 - i - 1) & 4'hF;
            if (Q !== esperado) begin
                errores = errores + 1;
                $display("FALLO BAJAR paso %0d: Q=%b (esperado %b)", i, Q, esperado);
            end
        end
        $display("Tras 16 bajadas: Q=%b (esperado 0000)", Q);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (34/34: 16 subir + 16 bajar + 2 chequeos extra).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
