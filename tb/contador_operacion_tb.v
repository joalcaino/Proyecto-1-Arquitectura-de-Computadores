// contador_operacion_tb.v
// Testbench de contador_operacion.v: aplica reset para partir de un estado
// conocido (000), y verifica el ciclo completo
// 000->001->010->011->100->101->000 al subir, y el camino inverso al
// bajar, confirmando que nunca pasa por 110 ni 111.

`timescale 1ns/1ps

module contador_operacion_tb;

    reg subir, bajar, reset, clk;
    wire [2:0] Q;
    integer i, errores;
    reg [2:0] secuencia_subir [0:6];
    reg [2:0] secuencia_bajar [0:6];

    contador_operacion dut (.subir(subir), .bajar(bajar), .reset(reset), .clk(clk), .Q(Q));

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("contador_operacion_tb.vcd");
        $dumpvars(0, contador_operacion_tb);
        errores = 0;
        subir = 0; bajar = 0; reset = 0;

        secuencia_subir[0] = 3'b001; secuencia_subir[1] = 3'b010; secuencia_subir[2] = 3'b011;
        secuencia_subir[3] = 3'b100; secuencia_subir[4] = 3'b101; secuencia_subir[5] = 3'b000;
        secuencia_subir[6] = 3'b001;

        secuencia_bajar[0] = 3'b101; secuencia_bajar[1] = 3'b100; secuencia_bajar[2] = 3'b011;
        secuencia_bajar[3] = 3'b010; secuencia_bajar[4] = 3'b001; secuencia_bajar[5] = 3'b000;
        secuencia_bajar[6] = 3'b101;

        // Reset: fuerza estado inicial conocido 000
        reset = 1;
        @(posedge clk); #1;
        reset = 0;

        if (Q !== 3'b000) begin errores=errores+1; $display("FALLO estado inicial: Q=%b (esperado 000)",Q); end
        else $display("OK estado inicial: Q=%b", Q);

        // Sube 7 veces: 001,010,011,100,101,000,001 (confirma el wrap en 101->000)
        for (i = 0; i < 7; i = i + 1) begin
            subir = 1;
            @(posedge clk); #1;
            subir = 0;
            if (Q !== secuencia_subir[i]) begin
                errores = errores + 1;
                $display("FALLO SUBIR paso %0d: Q=%b (esperado %b)", i, Q, secuencia_subir[i]);
            end else begin
                $display("OK SUBIR paso %0d: Q=%b", i, Q);
            end
        end

        // Reset de nuevo antes de probar bajar
        reset = 1;
        @(posedge clk); #1;
        reset = 0;

        // Baja 7 veces desde 000: primer paso ya da el wrap (000->101), luego
        // 100,011,010,001,000,101 (confirma que el ciclo se repite bien)
        for (i = 0; i < 7; i = i + 1) begin
            bajar = 1;
            @(posedge clk); #1;
            bajar = 0;
            if (Q !== secuencia_bajar[i]) begin
                errores = errores + 1;
                $display("FALLO BAJAR paso %0d: Q=%b (esperado %b)", i, Q, secuencia_bajar[i]);
            end else begin
                $display("OK BAJAR paso %0d: Q=%b", i, Q);
            end
        end

        if (errores == 0) $display("TODOS LOS CASOS PASARON (14/14: 7 subir + 7 bajar).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
