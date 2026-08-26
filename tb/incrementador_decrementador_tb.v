// incrementador_decrementador_tb.v
// Testbench exhaustivo (16 casos cada uno) para incrementador_4bits.v y
// decrementador_4bits.v, incluyendo los casos de wrap-around
// (1111->0000 al incrementar, 0000->1111 al decrementar).

`timescale 1ns/1ps

module incrementador_decrementador_tb;

    reg  [3:0] A;
    wire [3:0] inc, dec;

    integer i;
    reg [3:0] esperado_inc, esperado_dec;
    integer errores;

    incrementador_4bits u_inc (.A(A), .resultado(inc));
    decrementador_4bits u_dec (.A(A), .resultado(dec));

    initial begin
        $dumpfile("incrementador_decrementador_tb.vcd");
        $dumpvars(0, incrementador_decrementador_tb);
        errores = 0;

        for (i = 0; i < 16; i = i + 1) begin
            A = i[3:0];
            #5;

            esperado_inc = (A + 1) & 4'hF;
            esperado_dec = (A - 1) & 4'hF;

            if (inc !== esperado_inc) begin
                errores = errores + 1;
                $display("FALLO INC: A=%b -> inc=%b (esperado %b)", A, inc, esperado_inc);
            end
            if (dec !== esperado_dec) begin
                errores = errores + 1;
                $display("FALLO DEC: A=%b -> dec=%b (esperado %b)", A, dec, esperado_dec);
            end
        end

        if (errores == 0) $display("TODOS LOS CASOS PASARON (32/32: 16 inc + 16 dec).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
