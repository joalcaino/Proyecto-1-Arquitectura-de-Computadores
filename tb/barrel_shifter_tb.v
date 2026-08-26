// barrel_shifter_tb.v
// Testbench exhaustivo para barrel_shifter_left.v y barrel_shifter_right.v.
// Recorre las 16x4 = 64 combinaciones de A y monto para cada direccion, y
// compara contra un shift logico de referencia (rellena con 0, no preserva
// signo), calculado con operadores de alto nivel PERMITIDOS SOLO en el
// testbench (no es el diseno que se sube a la FPGA, es el modelo esperado).

`timescale 1ns/1ps

module barrel_shifter_tb;

    reg  [3:0] A;
    reg  [1:0] monto;
    wire [3:0] R_left, R_right;

    integer ai, mi;
    reg [3:0] esperado_left, esperado_right;
    integer errores;

    barrel_shifter_left  dut_left  (.A(A), .monto(monto), .R(R_left));
    barrel_shifter_right dut_right (.A(A), .monto(monto), .R(R_right));

    initial begin
        $dumpfile("barrel_shifter_tb.vcd");
        $dumpvars(0, barrel_shifter_tb);

        errores = 0;

        for (ai = 0; ai < 16; ai = ai + 1) begin
            for (mi = 0; mi < 4; mi = mi + 1) begin
                A = ai[3:0];
                monto = mi[1:0];
                #5;

                esperado_left  = (A << monto) & 4'hF;
                esperado_right = (A >> monto) & 4'hF;

                if (R_left !== esperado_left) begin
                    errores = errores + 1;
                    $display("FALLO SHIFT LEFT: A=%b monto=%0d -> R=%b (esperado %b)",
                              A, monto, R_left, esperado_left);
                end

                if (R_right !== esperado_right) begin
                    errores = errores + 1;
                    $display("FALLO SHIFT RIGHT: A=%b monto=%0d -> R=%b (esperado %b)",
                              A, monto, R_right, esperado_right);
                end
            end
        end

        if (errores == 0)
            $display("TODOS LOS CASOS PASARON (128/128: 64 shift left + 64 shift right).");
        else
            $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
