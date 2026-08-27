// contador_incremental_12bits_tb.v
// Testbench del contador incremental de 12 bits: verifica que cuenta
// correctamente hasta el maximo (4095 = todos 1), que "limpiar" lo
// resetea a mitad de camino, y que retiene el valor cuando incrementar=0.
// No es exhaustivo bit a bit -- se apoya en que incrementador_12bits.v es
// una extension mecanica ya verificada del mismo patron que
// incrementador_8bits.v / incrementador_18bits.v (mas full_adder encadenados).

`timescale 1ns/1ps

module contador_incremental_12bits_tb;

    reg  incrementar, limpiar, clk;
    wire [11:0] Q;
    integer errores, i;

    contador_incremental_12bits dut (
        .incrementar(incrementar), .limpiar(limpiar), .clk(clk), .Q(Q)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    task verificar;
        input [255:0] nombre;
        input [11:0] esperado;
        begin
            if (Q !== esperado) begin
                errores = errores + 1;
                $display("FALLO %0s: Q=%0d (esperado %0d)", nombre, Q, esperado);
            end else begin
                $display("OK %0s: Q=%0d", nombre, Q);
            end
        end
    endtask

    initial begin
        $dumpfile("contador_incremental_12bits_tb.vcd");
        $dumpvars(0, contador_incremental_12bits_tb);
        errores = 0;

        incrementar = 0; limpiar = 1;
        @(posedge clk); #1;
        verificar("estado inicial (limpiar)", 12'd0);

        limpiar = 0; incrementar = 1;
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk); #1;
        end
        verificar("tras 10 incrementos", 12'd10);

        incrementar = 0;
        @(posedge clk); #1;
        verificar("retiene (incrementar=0)", 12'd10);

        limpiar = 1;
        @(posedge clk); #1;
        verificar("limpiado a mitad de camino", 12'd0);
        limpiar = 0;

        incrementar = 1;
        for (i = 0; i < 4095; i = i + 1) begin
            @(posedge clk);
        end
        #1;
        verificar("en el maximo (4095, todos 1)", 12'd4095);

        @(posedge clk); #1;
        verificar("da la vuelta tras el maximo", 12'd0);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (5/5).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
