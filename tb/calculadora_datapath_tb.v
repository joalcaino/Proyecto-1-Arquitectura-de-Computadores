// calculadora_datapath_tb.v
// Testbench de una secuencia dirigida de operaciones encadenadas, usando
// resultados anteriores como segundo operando, para verificar que el
// datapath completo (selector op2 + ALU + registro) funciona en conjunto
// tal como lo describe el diagrama de bloques.

`timescale 1ns/1ps

module calculadora_datapath_tb;

    reg  [3:0] op1, op2_externo;
    reg        selector_op2, confirmar;
    reg        OP2, OP1, OP0;
    reg        clk;
    wire [3:0] resultado;

    integer errores;

    calculadora_datapath dut (
        .op1(op1), .op2_externo(op2_externo), .selector_op2(selector_op2),
        .OP2(OP2), .OP1(OP1), .OP0(OP0),
        .confirmar(confirmar), .clk(clk), .resultado(resultado)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    task verificar;
        input [255:0] nombre;
        input [3:0] esperado;
        begin
            if (resultado !== esperado) begin
                errores = errores + 1;
                $display("FALLO %0s: resultado=%b (esperado %b)", nombre, resultado, esperado);
            end else begin
                $display("OK %0s: resultado=%b", nombre, resultado);
            end
        end
    endtask

    initial begin
        $dumpfile("calculadora_datapath_tb.vcd");
        $dumpvars(0, calculadora_datapath_tb);
        errores = 0;

        // 1) Reinicio: fuerza resultado = 0000 sin importar los operandos
        op1 = 4'd9; op2_externo = 4'd3; selector_op2 = 0;
        {OP2,OP1,OP0} = 3'b000; confirmar = 1;
        @(posedge clk); #1;
        verificar("reinicio", 4'b0000);

        // 2) Suma: op1=5, op2 externo=3, sel=externo -> 5+3=8
        op1 = 4'd5; op2_externo = 4'd3; selector_op2 = 0;
        {OP2,OP1,OP0} = 3'b001; confirmar = 1;
        @(posedge clk); #1;
        verificar("suma 5+3", 4'd8);

        // 3) Retener: confirmar=0, cambiar entradas no debe afectar resultado
        confirmar = 0;
        op1 = 4'd1; op2_externo = 4'd1; {OP2,OP1,OP0} = 3'b001;
        @(posedge clk); #1;
        verificar("retener tras suma", 4'd8);

        // 4) Resta usando resultado anterior (8) como B: op1=2, sel=anterior -> 2-8 = -6 mod16 = 10
        op1 = 4'd2; selector_op2 = 1;
        {OP2,OP1,OP0} = 3'b010; confirmar = 1;
        @(posedge clk); #1;
        verificar("resta 2-8 (mod16)", 4'd10);

        // 5) Shift left: op2 externo=2 (monto=2), op1=1 (0001) -> 0001<<2 = 0100 = 4
        op1 = 4'b0001; op2_externo = 4'd2; selector_op2 = 0;
        {OP2,OP1,OP0} = 3'b100; confirmar = 1;
        @(posedge clk); #1;
        verificar("shift left 0001<<2", 4'b0100);

        // 6) Resta inversa usando resultado anterior (4) como B: op1=9 -> B-A = 4-9 = -5 mod16 = 11
        op1 = 4'd9; selector_op2 = 1;
        {OP2,OP1,OP0} = 3'b011; confirmar = 1;
        @(posedge clk); #1;
        verificar("resta inversa 4-9 (mod16)", 4'd11);

        // 7) Reinicio de nuevo
        {OP2,OP1,OP0} = 3'b000; confirmar = 1;
        @(posedge clk); #1;
        verificar("reinicio final", 4'b0000);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (7/7).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
