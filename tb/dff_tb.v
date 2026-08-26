// dff_tb.v
// Testbench del flip-flop D: genera un reloj, cambia D en momentos variados
// (a veces antes del flanco, a veces despues) y verifica que Q solo se
// actualiza en el flanco de subida, capturando el valor de D vigente justo
// antes de ese flanco, y que se mantiene fijo el resto del tiempo.

`timescale 1ns/1ps

module dff_tb;

    reg D, CLK;
    wire Q;
    integer errores;
    reg q_antes;

    dff dut (.D(D), .CLK(CLK), .Q(Q));

    // Reloj de periodo 20ns
    initial CLK = 0;
    always #10 CLK = ~CLK;

    initial begin
        $dumpfile("dff_tb.vcd");
        $dumpvars(0, dff_tb);
        errores = 0;

        D = 0;
        @(posedge CLK); #1; // primer flanco: fija un estado conocido (Q debe quedar en 0)
        if (Q !== 1'b0) begin errores=errores+1; $display("FALLO estado inicial: Q=%b (esperado 0)",Q); end
        else $display("OK estado inicial: Q=%b", Q);

        // Cambia D bien antes del proximo flanco -> debe capturarse
        D = 1; #5;
        @(posedge CLK); #1;
        if (Q !== 1'b1) begin errores=errores+1; $display("FALLO captura D=1: Q=%b (esperado 1)",Q); end
        else $display("OK captura D=1: Q=%b", Q);

        // Con D fijo en 1, entre flancos Q no debe cambiar
        #5;
        if (Q !== 1'b1) begin errores=errores+1; $display("FALLO estabilidad entre flancos: Q=%b (esperado 1)",Q); end
        else $display("OK estabilidad entre flancos: Q=%b", Q);

        // Cambia D a 0 antes del siguiente flanco -> debe capturarse
        D = 0; #5;
        @(posedge CLK); #1;
        if (Q !== 1'b0) begin errores=errores+1; $display("FALLO captura D=0: Q=%b (esperado 0)",Q); end
        else $display("OK captura D=0: Q=%b", Q);

        // Cambia D DESPUES del flanco (a mitad de ciclo) -> no debe verse
        // reflejado hasta el PROXIMO flanco
        q_antes = Q;
        #4; // seguimos dentro del mismo semiciclo bajo, lejos de cualquier flanco
        D = 1;
        #2; // todavia no llega el flanco de subida
        if (Q !== q_antes) begin errores=errores+1; $display("FALLO cambio de D no debe verse antes del flanco: Q=%b (esperado %b)",Q,q_antes); end
        else $display("OK D cambia pero Q no se mueve hasta el flanco: Q=%b", Q);

        @(posedge CLK); #1; // ahora si debe capturar el D=1 pendiente
        if (Q !== 1'b1) begin errores=errores+1; $display("FALLO captura tardia: Q=%b (esperado 1)",Q); end
        else $display("OK captura tardia: Q=%b", Q);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (5/5).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
