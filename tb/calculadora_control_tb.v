// calculadora_control_tb.v
// Testbench de calculadora_control.v: simula una demo completa apretando
// botones (pulsos de un solo ciclo, como si ya vinieran de debounce +
// detector_flanco), en dos rondas de operacion, la segunda usando el
// resultado anterior como segundo operando.

`timescale 1ns/1ps

module calculadora_control_tb;

    reg subir, bajar, confirmar, anterior, reset, clk;
    wire [1:0] estado;
    wire [2:0] op_actual;
    wire [3:0] op1_actual, op2_actual, resultado;
    wire selector_op2_activo;

    integer i, errores;

    calculadora_control dut (
        .boton_subir_pulso(subir), .boton_bajar_pulso(bajar),
        .boton_confirmar_pulso(confirmar), .boton_anterior_pulso(anterior),
        .reset(reset), .clk(clk),
        .estado(estado), .op_actual(op_actual),
        .op1_actual(op1_actual), .op2_actual(op2_actual),
        .selector_op2_activo(selector_op2_activo), .resultado(resultado)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    task pulso_subir;   begin subir=1; @(posedge clk); #1; subir=0; end endtask
    task pulso_bajar;   begin bajar=1; @(posedge clk); #1; bajar=0; end endtask
    task pulso_confirmar; begin confirmar=1; @(posedge clk); #1; confirmar=0; end endtask
    task pulso_anterior;  begin anterior=1; @(posedge clk); #1; anterior=0; end endtask

    task check2;
        input [255:0] nombre;
        input [1:0] valor, esperado;
        begin
            if (valor !== esperado) begin
                errores = errores + 1;
                $display("FALLO %0s: valor=%b (esperado %b)", nombre, valor, esperado);
            end else $display("OK %0s: valor=%b", nombre, valor);
        end
    endtask

    task check3;
        input [255:0] nombre;
        input [2:0] valor, esperado;
        begin
            if (valor !== esperado) begin
                errores = errores + 1;
                $display("FALLO %0s: valor=%b (esperado %b)", nombre, valor, esperado);
            end else $display("OK %0s: valor=%b", nombre, valor);
        end
    endtask

    task check4;
        input [255:0] nombre;
        input [3:0] valor, esperado;
        begin
            if (valor !== esperado) begin
                errores = errores + 1;
                $display("FALLO %0s: valor=%b (esperado %b)", nombre, valor, esperado);
            end else $display("OK %0s: valor=%b", nombre, valor);
        end
    endtask

    initial begin
        $dumpfile("calculadora_control_tb.vcd");
        $dumpvars(0, calculadora_control_tb);
        errores = 0;
        subir=0; bajar=0; confirmar=0; anterior=0; reset=1;

        @(posedge clk); #1;
        reset = 0;
        check2("estado tras reset", estado, 2'b00);
        check3("op tras reset", op_actual, 3'b000);
        check4("resultado tras reset", resultado, 4'b0000);

        // ===== RONDA 1: suma 5 + 3 =====
        // Elegir operacion: subir una vez (000->001 = suma)
        pulso_subir;
        check3("op elegido (suma)", op_actual, 3'b001);

        pulso_confirmar;
        check2("estado tras confirmar 1", estado, 2'b01);

        // Ingresar op1 = 5
        for (i = 0; i < 5; i = i + 1) pulso_subir;
        check4("op1 = 5", op1_actual, 4'd5);

        pulso_confirmar;
        check2("estado tras confirmar 2", estado, 2'b10);

        // Ingresar op2 = 3 (externo, sin usar anterior)
        for (i = 0; i < 3; i = i + 1) pulso_subir;
        check4("op2 = 3", op2_actual, 4'd3);

        pulso_confirmar; // ejecuta: 5+3=8
        check2("estado tras confirmar 3 (resultado)", estado, 2'b11);
        check4("resultado ronda 1 (5+3)", resultado, 4'd8);

        // Vuelve al inicio
        pulso_confirmar;
        check2("estado vuelve a elegir", estado, 2'b00);

        // ===== RONDA 2: resta usando resultado anterior (8) - op1=3 =====
        // Elegir operacion: subir una vez mas (001->010 = resta)
        pulso_subir;
        check3("op elegido (resta)", op_actual, 3'b010);

        pulso_confirmar;
        check2("estado tras confirmar (op1)", estado, 2'b01);

        // op1 actual sigue en 5 (no se reinicio); bajar 2 veces -> 3
        pulso_bajar;
        pulso_bajar;
        check4("op1 = 3", op1_actual, 4'd3);

        pulso_confirmar;
        check2("estado tras confirmar (op2)", estado, 2'b10);

        // Usar resultado anterior en vez de op2
        pulso_anterior;
        check2("selector_op2_activo tras anterior", {1'b0, selector_op2_activo}, 2'b01);

        pulso_confirmar; // ejecuta: 3 - 8 = -5 mod16 = 11
        check2("estado tras confirmar (resultado 2)", estado, 2'b11);
        check4("resultado ronda 2 (3-8 mod16)", resultado, 4'd11);

        // Vuelve al inicio: selector_op2_activo debe limpiarse
        pulso_confirmar;
        check2("estado vuelve a elegir (2)", estado, 2'b00);
        check2("selector_op2_activo se limpia", {1'b0, selector_op2_activo}, 2'b00);

        if (errores == 0) $display("TODOS LOS CASOS PASARON.");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
