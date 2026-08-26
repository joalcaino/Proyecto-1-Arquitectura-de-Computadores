// decodificador_operacion_tb.v
// Testbench exhaustivo para decodificador_operacion.v.
// Recorre las 16 (R_arit) x 16 (shift_left) x 16 (shift_right) x 8 (OP) =
// 32768 combinaciones y compara contra la regla esperada:
//   OP == 000        -> R = 0000 (reinicio, forzado)
//   OP2 == 0          -> R = R_arit         (suma/resta/resta inversa)
//   OP2 == 1, OP0 == 0 -> R = shift_left     (shift left, y 110 don't-care)
//   OP2 == 1, OP0 == 1 -> R = shift_right    (shift right, y 111 don't-care)

`timescale 1ns/1ps

module decodificador_operacion_tb;

    reg  [3:0] R_arit, shift_left, shift_right;
    reg        OP2, OP1, OP0;
    wire [3:0] R;

    integer ra, sl, sr, op;
    reg [3:0] esperado;
    integer errores;

    decodificador_operacion dut (
        .R_arit(R_arit), .shift_left(shift_left), .shift_right(shift_right),
        .OP2(OP2), .OP1(OP1), .OP0(OP0), .R(R)
    );

    initial begin
        $dumpfile("decodificador_operacion_tb.vcd");
        $dumpvars(0, decodificador_operacion_tb);

        errores = 0;

        for (ra = 0; ra < 16; ra = ra + 1) begin
          for (sl = 0; sl < 16; sl = sl + 1) begin
            for (sr = 0; sr < 16; sr = sr + 1) begin
              for (op = 0; op < 8; op = op + 1) begin
                R_arit = ra[3:0];
                shift_left = sl[3:0];
                shift_right = sr[3:0];
                {OP2, OP1, OP0} = op[2:0];
                #1;

                if (op == 3'b000)
                    esperado = 4'b0000;
                else if (OP2 == 1'b0)
                    esperado = R_arit;
                else if (OP0 == 1'b0)
                    esperado = shift_left;
                else
                    esperado = shift_right;

                if (R !== esperado) begin
                    errores = errores + 1;
                    $display("FALLO: R_arit=%b shift_left=%b shift_right=%b OP=%b%b%b -> R=%b (esperado %b)",
                              R_arit, shift_left, shift_right, OP2, OP1, OP0, R, esperado);
                end
              end
            end
          end
        end

        if (errores == 0)
            $display("TODOS LOS CASOS PASARON (32768/32768).");
        else
            $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
