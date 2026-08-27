// calculadora_top_tb.v
// Testbench de integracion de punta a punta del modulo top: mueve los
// PINES CRUDOS de los botones (como si fuera un dedo apretando la
// placa real), pasando por reset, debounce, deteccion de flanco, la FSM
// completa y los dos displays de 7 segmentos. Secuencia de 2 rondas:
// una suma normal y una resta usando "resultado anterior" como
// segundo operando, revisando en cada paso los LEDs y los 14 segmentos.

`timescale 1ns/1ps

module calculadora_top_tb;

    reg  clk;
    reg  boton_subir_crudo, boton_bajar_crudo, boton_confirmar_crudo, boton_anterior_crudo;
    wire [3:0] leds;
    wire seg1_a, seg1_b, seg1_c, seg1_d, seg1_e, seg1_f, seg1_g;
    wire seg2_a, seg2_b, seg2_c, seg2_d, seg2_e, seg2_f, seg2_g;

    integer errores;

    calculadora_top dut (
        .clk(clk),
        .boton_subir_crudo(boton_subir_crudo),
        .boton_bajar_crudo(boton_bajar_crudo),
        .boton_confirmar_crudo(boton_confirmar_crudo),
        .boton_anterior_crudo(boton_anterior_crudo),
        .leds(leds),
        .seg1_a(seg1_a), .seg1_b(seg1_b), .seg1_c(seg1_c), .seg1_d(seg1_d),
        .seg1_e(seg1_e), .seg1_f(seg1_f), .seg1_g(seg1_g),
        .seg2_a(seg2_a), .seg2_b(seg2_b), .seg2_c(seg2_c), .seg2_d(seg2_d),
        .seg2_e(seg2_e), .seg2_f(seg2_f), .seg2_g(seg2_g)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    // Mantiene un boton "apretado" el tiempo suficiente para pasar el
    // umbral real de debounce (~262144 ciclos, ~10.5ms a 25MHz, logrado
    // con un preescaler de 6 bits + contador de 12 bits -- ver debounce.v)
    // y que el detector de flanco genere su pulso, y despues lo "suelta"
    // el tiempo suficiente para que el debounce tambien acepte la soltada
    // (deja todo listo para el siguiente apreton).
    //
    // NOTA: se referencian directamente los reg de arriba (subir/bajar/
    // confirmar/anterior) en vez de usar un argumento "output" del task,
    // porque en Verilog un argumento output de task solo se copia de
    // vuelta a la variable real cuando el task TERMINA (no durante los
    // @(posedge clk) intermedios) -- con "output" el DUT nunca habria
    // visto el boton en 1. Un task puede leer/escribir libremente las
    // variables de su propio modulo, asi que esto evita ese problema.
    //
    // AVISO: el umbral de debounce paso por varias versiones (256 ciclos ->
    // demasiado corto para el rebote real; un solo contador de 18 bits/
    // 262144 ciclos -> umbral correcto pero cadena de sumadores demasiado
    // larga, no cerraba tiempo a 25MHz en el chip real; un solo contador de
    // 12 bits/4096 ciclos -> cadena corta y segura, pero umbral otra vez
    // insuficiente; preescaler de 6 bits + contador de 12 bits -> version
    // actual, misma cadena corta y segura pero con el umbral de tiempo
    // largo completo, verificada en la placa). Ver el historial completo
    // en debounce.v. Con este umbral la secuencia de 13 pasos tarda varios
    // minutos en simular con Icarus -- es normal, no esta colgado.
    localparam SUBIR = 0, BAJAR = 1, CONFIRMAR = 2, ANTERIOR = 3;
    localparam HOLD = 262200; // >262144, con margen

    task presionar;
        input integer cual;
        begin
            case (cual)
                SUBIR:     boton_subir_crudo     = 1;
                BAJAR:     boton_bajar_crudo     = 1;
                CONFIRMAR: boton_confirmar_crudo = 1;
                ANTERIOR:  boton_anterior_crudo  = 1;
            endcase
            repeat (HOLD) @(posedge clk);
            case (cual)
                SUBIR:     boton_subir_crudo     = 0;
                BAJAR:     boton_bajar_crudo     = 0;
                CONFIRMAR: boton_confirmar_crudo = 0;
                ANTERIOR:  boton_anterior_crudo  = 0;
            endcase
            repeat (HOLD) @(posedge clk);
        end
    endtask

    task verificar;
        input [255:0] nombre;
        input [3:0] leds_esperado;
        input [6:0] signo_esperado; // {seg1_a..seg1_g}
        input [6:0] hex_esperado;   // {seg2_a..seg2_g}
        reg   [6:0] signo_obtenido, hex_obtenido;
        begin
            signo_obtenido = {seg1_a, seg1_b, seg1_c, seg1_d, seg1_e, seg1_f, seg1_g};
            hex_obtenido   = {seg2_a, seg2_b, seg2_c, seg2_d, seg2_e, seg2_f, seg2_g};
            if (leds !== leds_esperado || signo_obtenido !== signo_esperado || hex_obtenido !== hex_esperado) begin
                errores = errores + 1;
                $display("FALLO %0s: leds=%b(esp %b) signo=%b(esp %b) hex=%b(esp %b)",
                          nombre, leds, leds_esperado, signo_obtenido, signo_esperado, hex_obtenido, hex_esperado);
            end else begin
                $display("OK %0s: leds=%b signo=%b hex=%b", nombre, leds, signo_obtenido, hex_obtenido);
            end
        end
    endtask

    initial begin
        $dumpfile("calculadora_top_tb.vcd");
        $dumpvars(0, calculadora_top_tb);
        errores = 0;

        boton_subir_crudo = 0; boton_bajar_crudo = 0;
        boton_confirmar_crudo = 0; boton_anterior_crudo = 0;

        // ---- Reset: mantener subir+bajar juntos un ciclo, despues soltar
        // y esperar el tiempo COMPLETO de extension del reset (~262144
        // ciclos -- ver extensor_reset.v) antes de seguir. Este tiempo de
        // espera es nuevo: antes bastaba con 10 ciclos, pero ahora el
        // reset se queda extendido a proposito para filtrar el rebote de
        // la soltada (bug encontrado en la placa real). ----
        boton_subir_crudo = 1; boton_bajar_crudo = 1;
        @(posedge clk); #1;
        boton_subir_crudo = 0; boton_bajar_crudo = 0;
        repeat (HOLD) @(posedge clk); #1;
        verificar("reset", 4'b0000, 7'b1111111, 7'b1111111);

        // ---- Elegir operacion: subir una vez -> 001 (suma) ----
        presionar(SUBIR); #1;
        verificar("elegir suma", 4'b0001, 7'b1111111, 7'b1111111);

        // ---- Confirmar -> INGRESA_OP1 (op1 arranca en 0) ----
        presionar(CONFIRMAR); #1;
        verificar("entra op1 (=0)", 4'b0001, 7'b1111111, 7'b0000001);

        // ---- Subir x5 -> op1 = 5 ----
        presionar(SUBIR);
        presionar(SUBIR);
        presionar(SUBIR);
        presionar(SUBIR);
        presionar(SUBIR);
        #1;
        verificar("op1 = 5", 4'b0001, 7'b1111111, 7'b0100100);

        // ---- Confirmar -> INGRESA_OP2 (op2 arranca en 0) ----
        presionar(CONFIRMAR); #1;
        verificar("entra op2 (=0)", 4'b0001, 7'b1111111, 7'b0000001);

        // ---- Subir x3 -> op2 = 3 ----
        presionar(SUBIR);
        presionar(SUBIR);
        presionar(SUBIR);
        #1;
        verificar("op2 = 3", 4'b0001, 7'b1111111, 7'b0000110);

        // ---- Confirmar -> ejecuta 5+3=8 (1000, negativo en 4 bits) y MUESTRA_RESULTADO ----
        presionar(CONFIRMAR); #1;
        verificar("resultado 5+3=8", 4'b0001, 7'b1111110, 7'b0000000);

        // ---- Confirmar -> vuelve a ELEGIR_OPERACION ----
        presionar(CONFIRMAR); #1;
        verificar("vuelve a elegir", 4'b0001, 7'b1111111, 7'b1111111);

        // ==== Segunda ronda: resta usando "resultado anterior" ====

        // ---- Subir una vez mas -> 010 (resta) ----
        presionar(SUBIR); #1;
        verificar("elegir resta", 4'b0010, 7'b1111111, 7'b1111111);

        // ---- Confirmar -> INGRESA_OP1 (retiene op1=5 de la ronda anterior) ----
        presionar(CONFIRMAR); #1;
        verificar("entra op1 (=5, retenido)", 4'b0010, 7'b1111111, 7'b0100100);

        // ---- Bajar x3 -> op1 = 2 ----
        presionar(BAJAR);
        presionar(BAJAR);
        presionar(BAJAR);
        #1;
        verificar("op1 = 2", 4'b0010, 7'b1111111, 7'b0010010);

        // ---- Confirmar -> INGRESA_OP2 (retiene op2=3 de la ronda anterior) ----
        presionar(CONFIRMAR); #1;
        verificar("entra op2 (=3, retenido)", 4'b0010, 7'b1111111, 7'b0000110);

        // ---- Anterior -> selecciona el resultado previo (8) como op2 ----
        presionar(ANTERIOR); #1;
        verificar("op2 = anterior (8)", 4'b1010, 7'b1111110, 7'b0000000);

        // ---- Confirmar -> ejecuta 2-8 (mod16) = 1010 = -6 en complemento a dos.
        // El display de hex muestra la MAGNITUD (6), no el patron crudo (A) ----
        presionar(CONFIRMAR); #1;
        verificar("resultado 2-8=-6", 4'b1010, 7'b1111110, 7'b0100000);

        // ---- Confirmar -> vuelve a ELEGIR_OPERACION, selector se limpia ----
        presionar(CONFIRMAR); #1;
        verificar("vuelve a elegir, selector limpio", 4'b0010, 7'b1111111, 7'b1111111);

        if (errores == 0) $display("TODOS LOS CASOS PASARON (13/13).");
        else $display("%0d CASOS FALLARON.", errores);

        $finish;
    end

endmodule
