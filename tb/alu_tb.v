// alu_tb.v
// Testbench funcional de la ALU completa (alu.v).
// Recorre las 16x16x8 = 2048 combinaciones de A, B y codigo de operacion,
// y compara contra el comportamiento esperado de cada operacion (informe,
// tabla de codigos de operacion). Los codigos 110 y 111 son no definidos
// (don't care) y no se verifican contra un valor especifico.

`timescale 1ns/1ps

module alu_tb;

    reg  [3:0] A, B;
    reg        OP2, OP1, OP0;
    wire [3:0] R;

    integer ai, bi, op;
    reg [3:0] esperado;
    integer errores, verificados;

    alu dut (.A(A), .B(B), .OP2(OP2), .OP1(OP1), .OP0(OP0), .R(R));

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        errores = 0;
        verificados = 0;

        for (ai = 0; ai < 16; ai = ai + 1) begin
          for (bi = 0; bi < 16; bi = bi + 1) begin
            for (op = 0; op < 8; op = op + 1) begin
                A = ai[3:0];
                B = bi[3:0];
                {OP2, OP1, OP0} = op[2:0];
                #5;

                case (op)
                    3'b000:  esperado = 4'b0000;                          // reinicio
                    3'b001:  esperado = (A + B) & 4'hF;                   // suma
                    3'b010:  esperado = (A - B) & 4'hF;                   // resta
                    3'b011:  esperado = (B - A) & 4'hF;                   // resta inversa
                    3'b100:  esperado = (A << B[1:0]) & 4'hF;             // shift left
                    3'b101:  esperado = (A >> B[1:0]) & 4'hF;             // shift right
                    default: esperado = R;                                // 110/111: no definido, no se chequea
                endcase

                if (op != 3'b110 && op != 3'b111) begin
                    verificados = verificados + 1;
                    if (R !== esperado) begin
                        errores = errores + 1;
                        $display("FALLO: A=%0d B=%0d OP=%b%b%b -> R=%0d (esperado %0d)",
                                  A, B, OP2, OP1, OP0, R, esperado);
                    end
                end
            end
          end
        end

        if (errores == 0)
            $display("TODOS LOS CASOS PASARON (%0d/%0d verificados; 110/111 no se chequean por ser don't care).",
                      verificados, verificados);
        else
            $display("%0d CASOS FALLARON de %0d verificados.", errores, verificados);

        $finish;
    end

endmodule
