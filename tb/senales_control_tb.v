// senales_control_tb.v
// Testbench exhaustivo para senales_control.v: recorre los 8 codigos de
// operacion posibles y compara contra la Tabla "Senales de control del
// sumador/restador compartido segun la operacion" del informe (para 100,
// 101, 110, 111 se espera invA=invB=Cin=0, ya que no se usan en esos casos).

`timescale 1ns/1ps

module senales_control_tb;

    reg  OP2, OP1, OP0;
    wire invA, invB, Cin;

    integer op;
    reg exp_invA, exp_invB, exp_Cin;
    integer errores;

    senales_control dut (
        .OP2(OP2), .OP1(OP1), .OP0(OP0),
        .invA(invA), .invB(invB), .Cin(Cin)
    );

    initial begin
        $dumpfile("senales_control_tb.vcd");
        $dumpvars(0, senales_control_tb);

        errores = 0;

        for (op = 0; op < 8; op = op + 1) begin
            {OP2, OP1, OP0} = op[2:0];
            #5;

            case (op)
                3'b000: begin exp_invA = 0; exp_invB = 0; exp_Cin = 0; end // reinicio
                3'b001: begin exp_invA = 0; exp_invB = 0; exp_Cin = 0; end // suma
                3'b010: begin exp_invA = 0; exp_invB = 1; exp_Cin = 1; end // resta
                3'b011: begin exp_invA = 1; exp_invB = 0; exp_Cin = 1; end // resta inversa
                default: begin exp_invA = 0; exp_invB = 0; exp_Cin = 0; end // shifts / no definidos
            endcase

            if (invA !== exp_invA || invB !== exp_invB || Cin !== exp_Cin) begin
                errores = errores + 1;
                $display("FALLO: OP=%b%b%b -> invA=%b invB=%b Cin=%b (esperado invA=%b invB=%b Cin=%b)",
                          OP2, OP1, OP0, invA, invB, Cin, exp_invA, exp_invB, exp_Cin);
            end else begin
                $display("OK:    OP=%b%b%b -> invA=%b invB=%b Cin=%b", OP2, OP1, OP0, invA, invB, Cin);
            end
        end

        if (errores == 0)
            $display("TODOS LOS CASOS PASARON (8/8).");
        else
            $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
