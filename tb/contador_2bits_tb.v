// contador_2bits_tb.v
// Testbench de contador_2bits.v: reset a 00, y verifica el ciclo completo
// 00->01->10->11->00 al avanzar, mas que retiene el valor cuando
// avanzar=0.

`timescale 1ns/1ps

module contador_2bits_tb;

    reg avanzar, reset, clk;
    wire [1:0] Q;
    integer i, errores;
    reg [1:0] secuencia [0:4];

    contador_2bits dut (.avanzar(avanzar), .reset(reset), .clk(clk), .Q(Q));

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("contador_2bits_tb.vcd");
        $dumpvars(0, contador_2bits_tb);
        errores = 0;
        avanzar = 0; reset = 0;

        secuencia[0] = 2'b01; secuencia[1] = 2'b10; secuencia[2] = 2'b11;
        secuencia[3] = 2'b00; secuencia[4] = 2'b01;

        reset = 1;
        @(posedge clk); #1;
        reset = 0;
        if (Q !== 2'b00) begin errores=errores+1; $display("FALLO reset: Q=%b",Q); end
        else $display("OK reset: Q=%b", Q);

        // Retener: sin avanzar, Q no debe cambiar
        @(posedge clk); #1;
        if (Q !== 2'b00) begin errores=errores+1; $display("FALLO retener: Q=%b",Q); end
        else $display("OK retener: Q=%b", Q);

        // Avanza 5 veces: 01,10,11,00,01 (confirma el wrap en 11->00)
        for (i = 0; i < 5; i = i + 1) begin
            avanzar = 1;
            @(posedge clk); #1;
            avanzar = 0;
            if (Q !== secuencia[i]) begin
                errores = errores + 1;
                $display("FALLO paso %0d: Q=%b (esperado %b)", i, Q, secuencia[i]);
            end else begin
                $display("OK paso %0d: Q=%b", i, Q);
            end
        end

        if (errores == 0) $display("TODOS LOS CASOS PASARON.");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
