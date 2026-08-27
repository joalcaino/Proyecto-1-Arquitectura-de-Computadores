// contador_incremental_6bits_tb.v
// Testbench del contador incremental de 6 bits (usado como preescaler en
// debounce.v): verifica que cuenta hasta el maximo (63 = todos 1), que
// "limpiar" lo resetea a mitad de camino, y que retiene el valor cuando
// incrementar=0. Mismo patron ya verificado en contador_incremental_8bits.v,
// contador_incremental_12bits.v y contador_incremental_18bits.v.

`timescale 1ns/1ps

module contador_incremental_6bits_tb;

    reg  incrementar, limpiar, clk;
    wire [5:0] Q;
    integer errores, i;

    contador_incremental_6bits dut (
        .incrementar(incrementar), .limpiar(limpiar), .clk(clk), .Q(Q)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    task verificar;
        input [255:0] nombre;
        input [5:0] esperado;
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
        $dumpfile("contador_incremental_6bits_tb.vcd");
        $dumpvars(0, contador_incremental_6bits_tb);
        errores = 0;

        incrementar = 0; limpiar = 1;
        @(posedge clk); #1;
        verificar("estado inicial (limpiar)", 6'd0);

        limpiar = 0; incrementar = 1;
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk); #1;
        end
        verificar("tras 10 incrementos", 6'd10);

        incrementar = 0;
        @(posedge clk); #1;
        verificar("retiene (incrementar=0)", 6'd10);

        limpiar = 1;
        @(posedge clk); #1;
        verificar("limpiado a mitad de camino", 6'd0);
        limpiar = 0;

        incrementar = 1;
        for (i = 0; i < 63; i = i + 1) begin
            @(posedge clk);
        end
        #1;
        verificar("en el maximo (63, todos 1)", 6'd63);

        @(posedge clk); #1;
        verificar("da la vuelta tras el maximo", 6'd0);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (5/5).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
