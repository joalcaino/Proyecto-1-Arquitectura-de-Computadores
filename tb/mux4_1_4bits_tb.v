// mux4_1_4bits_tb.v
// Testbench del mux 4 a 1 de 4 bits: barre 16 conjuntos distintos de
// valores de entrada, y para cada uno prueba los 4 valores de sel
// (64 chequeos en total).

`timescale 1ns/1ps

module mux4_1_4bits_tb;

    reg  [3:0] in0, in1, in2, in3;
    reg  [1:0] sel;
    wire [3:0] salida;
    integer errores, i;

    mux4_1_4bits dut (.in0(in0), .in1(in1), .in2(in2), .in3(in3), .sel(sel), .salida(salida));

    task verificar;
        input [3:0] esperado;
        begin
            if (salida !== esperado) begin
                errores = errores + 1;
                $display("FALLO in0=%b in1=%b in2=%b in3=%b sel=%b: salida=%b (esperado %b)",
                          in0, in1, in2, in3, sel, salida, esperado);
            end else begin
                $display("OK sel=%b: salida=%b", sel, salida);
            end
        end
    endtask

    initial begin
        $dumpfile("mux4_1_4bits_tb.vcd");
        $dumpvars(0, mux4_1_4bits_tb);
        errores = 0;

        for (i = 0; i < 16; i = i + 1) begin
            in0 = i[3:0];
            in1 = i[3:0] ^ 4'b0001;
            in2 = i[3:0] ^ 4'b0010;
            in3 = i[3:0] ^ 4'b0100;

            sel = 2'b00; #1; verificar(in0);
            sel = 2'b01; #1; verificar(in1);
            sel = 2'b10; #1; verificar(in2);
            sel = 2'b11; #1; verificar(in3);
        end

        if (errores == 0) $display("TODOS LOS CASOS PASARON (64/64).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
