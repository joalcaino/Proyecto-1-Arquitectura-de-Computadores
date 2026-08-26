// decodificador_signo_tb.v
// Testbench exhaustivo (2 casos: signo=0 y signo=1) del decodificador de
// signo para el primer display de 7 segmentos.

`timescale 1ns/1ps

module decodificador_signo_tb;

    reg signo;
    wire seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g;
    integer errores;

    decodificador_signo dut (
        .signo(signo),
        .seg_a(seg_a), .seg_b(seg_b), .seg_c(seg_c), .seg_d(seg_d),
        .seg_e(seg_e), .seg_f(seg_f), .seg_g(seg_g)
    );

    task verificar;
        input nombre_signo;
        input [6:0] esperado_bajo; // {a,b,c,d,e,f,g} activo-bajo
        reg   [6:0] obtenido_bajo;
        begin
            obtenido_bajo = {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g};
            if (obtenido_bajo !== esperado_bajo) begin
                errores = errores + 1;
                $display("FALLO signo=%0d: obtenido=%b esperado=%b", nombre_signo, obtenido_bajo, esperado_bajo);
            end else begin
                $display("OK signo=%0d: segmentos(activo-bajo)=%b", nombre_signo, obtenido_bajo);
            end
        end
    endtask

    initial begin
        $dumpfile("decodificador_signo_tb.vcd");
        $dumpvars(0, decodificador_signo_tb);
        errores = 0;

        signo = 0; #1;
        verificar(1'b0, 7'b1111111); // todo apagado (blanco)

        signo = 1; #1;
        verificar(1'b1, 7'b1111110); // solo g encendido (guion)

        if (errores == 0) $display("TODOS LOS CASOS PASARON (2/2).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
