// generador_reset_tb.v
// Testbench exhaustivo (4 combinaciones de los 2 botones) del generador
// de reset.

`timescale 1ns/1ps

module generador_reset_tb;

    reg boton_subir_crudo, boton_bajar_crudo;
    wire reset;
    integer errores;

    generador_reset dut (
        .boton_subir_crudo(boton_subir_crudo),
        .boton_bajar_crudo(boton_bajar_crudo),
        .reset(reset)
    );

    task verificar;
        input s, b;
        input esperado;
        begin
            if (reset !== esperado) begin
                errores = errores + 1;
                $display("FALLO subir=%b bajar=%b: reset=%b (esperado %b)", s, b, reset, esperado);
            end else begin
                $display("OK subir=%b bajar=%b: reset=%b", s, b, reset);
            end
        end
    endtask

    initial begin
        $dumpfile("generador_reset_tb.vcd");
        $dumpvars(0, generador_reset_tb);
        errores = 0;

        boton_subir_crudo = 0; boton_bajar_crudo = 0; #1; verificar(1'b0, 1'b0, 1'b0);
        boton_subir_crudo = 1; boton_bajar_crudo = 0; #1; verificar(1'b1, 1'b0, 1'b0);
        boton_subir_crudo = 0; boton_bajar_crudo = 1; #1; verificar(1'b0, 1'b1, 1'b0);
        boton_subir_crudo = 1; boton_bajar_crudo = 1; #1; verificar(1'b1, 1'b1, 1'b1);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (4/4).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
