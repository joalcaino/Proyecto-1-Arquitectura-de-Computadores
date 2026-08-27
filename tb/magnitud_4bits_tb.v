// magnitud_4bits_tb.v
// Testbench exhaustivo (16/16) de magnitud_4bits.v: para cada uno de los 16
// valores de 4 bits en complemento a dos, verifica que la magnitud mostrada
// sea la correcta (el valor mismo si es positivo/cero, o su complemento a
// dos si es negativo), comparando contra el modelo de referencia calculado
// con operadores normales de Verilog (solo permitido en tb/).

`timescale 1ns/1ps

module magnitud_4bits_tb;

    reg  [3:0] valor;
    reg        signo;
    wire [3:0] magnitud;
    integer i, errores;
    reg [3:0] esperado;
    reg signed [4:0] valor_con_signo;

    magnitud_4bits dut (.valor(valor), .signo(signo), .magnitud(magnitud));

    initial begin
        errores = 0;
        for (i = 0; i < 16; i = i + 1) begin
            valor = i[3:0];
            signo = i[3]; // bit mas significativo = signo, misma convencion que decodificador_signo
            #1;
            if (signo == 1'b0) begin
                esperado = valor; // positivo/cero: magnitud = el valor mismo
            end else begin
                esperado = (~valor) + 4'b0001; // negativo: complemento a dos
            end
            if (magnitud !== esperado) begin
                errores = errores + 1;
                $display("FALLO valor=%b (signo=%b): magnitud=%b (esperado %b)", valor, signo, magnitud, esperado);
            end else begin
                $display("OK valor=%b (signo=%b): magnitud=%b", valor, signo, magnitud);
            end
        end

        if (errores == 0) $display("TODOS LOS CASOS PASARON (16/16).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
