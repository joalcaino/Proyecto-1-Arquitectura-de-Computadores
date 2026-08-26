// decodificador_hex_7seg_tb.v
// Testbench exhaustivo (16 digitos x 7 segmentos = 112 chequeos) del
// decodificador hexadecimal. La tabla "esperado" es activa-ALTA (misma
// tabla estandar de 7 segmentos usada para generar las constantes del
// modulo); como el modulo entrega salidas activas-BAJAS, se compara
// contra el complemento de esa tabla.

`timescale 1ns/1ps

module decodificador_hex_7seg_tb;

    reg [3:0] digito;
    wire seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g;
    integer errores;
    integer i;

    // Tabla activa-ALTA estandar: {a,b,c,d,e,f,g}, un digito por indice.
    reg [6:0] tabla [0:15];

    decodificador_hex_7seg dut (
        .digito(digito),
        .seg_a(seg_a), .seg_b(seg_b), .seg_c(seg_c), .seg_d(seg_d),
        .seg_e(seg_e), .seg_f(seg_f), .seg_g(seg_g)
    );

    task verificar;
        input [3:0] dig;
        input [6:0] esperado_alto; // {a,b,c,d,e,f,g} activo-alto
        reg   [6:0] obtenido_alto;
        begin
            // Las salidas del DUT son activas-bajas: invertimos para comparar
            // contra la tabla activa-alta.
            obtenido_alto = {~seg_a, ~seg_b, ~seg_c, ~seg_d, ~seg_e, ~seg_f, ~seg_g};
            if (obtenido_alto !== esperado_alto) begin
                errores = errores + 1;
                $display("FALLO digito=%0d (%b): obtenido=%b esperado=%b", dig, dig, obtenido_alto, esperado_alto);
            end else begin
                $display("OK digito=%0d (%b): segmentos(activo-alto)=%b", dig, dig, obtenido_alto);
            end
        end
    endtask

    initial begin
        $dumpfile("decodificador_hex_7seg_tb.vcd");
        $dumpvars(0, decodificador_hex_7seg_tb);
        errores = 0;

        tabla[0]  = 7'b1111110;
        tabla[1]  = 7'b0110000;
        tabla[2]  = 7'b1101101;
        tabla[3]  = 7'b1111001;
        tabla[4]  = 7'b0110011;
        tabla[5]  = 7'b1011011;
        tabla[6]  = 7'b1011111;
        tabla[7]  = 7'b1110000;
        tabla[8]  = 7'b1111111;
        tabla[9]  = 7'b1111011;
        tabla[10] = 7'b1110111;
        tabla[11] = 7'b0011111;
        tabla[12] = 7'b1001110;
        tabla[13] = 7'b0111101;
        tabla[14] = 7'b1001111;
        tabla[15] = 7'b1000111;

        for (i = 0; i < 16; i = i + 1) begin
            digito = i[3:0];
            #1;
            verificar(i[3:0], tabla[i]);
        end

        if (errores == 0) $display("TODOS LOS CASOS PASARON (112/112).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
