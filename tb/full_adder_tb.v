// full_adder_tb.v
// Testbench exhaustivo para full_adder.v (recorre las 8 combinaciones posibles
// de A, B, Cin y compara contra el resultado esperado).

`timescale 1ns/1ps

module full_adder_tb;

    reg  A, B, Cin;
    wire S, Cout;

    integer i;
    reg exp_S, exp_Cout;
    integer errores;

    full_adder dut (
        .A(A), .B(B), .Cin(Cin),
        .S(S), .Cout(Cout)
    );

    initial begin
        $dumpfile("full_adder_tb.vcd");
        $dumpvars(0, full_adder_tb);

        errores = 0;

        for (i = 0; i < 8; i = i + 1) begin
            {A, B, Cin} = i[2:0];
            #5;

            exp_S    = A ^ B ^ Cin;
            exp_Cout = (A & B) | (A & Cin) | (B & Cin);

            if (S !== exp_S || Cout !== exp_Cout) begin
                errores = errores + 1;
                $display("FALLO: A=%b B=%b Cin=%b -> S=%b Cout=%b (esperado S=%b Cout=%b)",
                          A, B, Cin, S, Cout, exp_S, exp_Cout);
            end else begin
                $display("OK:    A=%b B=%b Cin=%b -> S=%b Cout=%b",
                          A, B, Cin, S, Cout);
            end
        end

        if (errores == 0)
            $display("TODOS LOS CASOS PASARON (8/8).");
        else
            $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
