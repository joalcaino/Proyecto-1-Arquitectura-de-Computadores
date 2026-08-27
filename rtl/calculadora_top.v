// calculadora_top.v
// Modulo TOP de toda la calculadora, listo para conectar a los pines
// reales de la Nandland Go Board (via el archivo .pcf).
// Proyecto 1 - Arquitectura de Computadores.
//
// Conecta, en orden:
//   1) generador_reset: reset = mantener presionados subir + bajar a la
//      vez, leido directamente de los pines crudos (sin flip-flops).
//   2) debounce x4: filtra rebotes de cada boton fisico.
//   3) detector_flanco x4: convierte cada boton ya estable en un pulso
//      de un solo ciclo (evita que mantener apretado repita la accion).
//   4) calculadora_control: la FSM completa (elegir operacion -> op1 ->
//      op2 -> resultado), que ya trae adentro el datapath (ALU+registro).
//   5) Seleccion de que valor de 4 bits se muestra en los displays segun
//      el estado: en blanco en ELEGIR_OPERACION (ya se ve en los LEDs),
//      op1 en INGRESA_OP1, (op2 o el resultado anterior, segun
//      selector_op2_activo) en INGRESA_OP2, resultado en MOSTRAR_RESULTADO.
//   6) decodificador_signo (primer display) + decodificador_hex_7seg
//      (segundo display), con un OR final que fuerza ambos displays
//      apagados mientras se esta eligiendo la operacion.
//   7) LEDs: los 3 bits del codigo de operacion (leds[2:0]) + un cuarto
//      LED que se prende si esta activo "usar resultado anterior"
//      (leds[3]), para dar retroalimentacion visual de esa eleccion.
//
// Reutiliza todos los bloques ya verificados por separado; el unico
// gate nuevo aca es el OR de apagado de displays (7+7 instancias, una
// por segmento) y el AND/NOT de en_elegir (2 instancias), calculados
// localmente para no tener que tocar calculadora_control.v ya entregado.

module calculadora_top (
    input  wire clk,
    input  wire boton_subir_crudo,
    input  wire boton_bajar_crudo,
    input  wire boton_confirmar_crudo,
    input  wire boton_anterior_crudo,

    output wire [3:0] leds,

    output wire seg1_a, seg1_b, seg1_c, seg1_d, seg1_e, seg1_f, seg1_g, // primer display: signo
    output wire seg2_a, seg2_b, seg2_c, seg2_d, seg2_e, seg2_f, seg2_g  // segundo display: hex
);

    // ---- 1) Reset global (combinacional, sin flip-flops) ----
    wire reset;
    generador_reset gen_reset (
        .boton_subir_crudo(boton_subir_crudo),
        .boton_bajar_crudo(boton_bajar_crudo),
        .reset(reset)
    );

    // ---- 2) Debounce de los 4 botones ----
    wire subir_estable, bajar_estable, confirmar_estable, anterior_estable;

    debounce db_subir (.boton_crudo(boton_subir_crudo), .clk(clk), .reset(reset), .boton_estable(subir_estable));
    debounce db_bajar (.boton_crudo(boton_bajar_crudo), .clk(clk), .reset(reset), .boton_estable(bajar_estable));
    debounce db_confirmar (.boton_crudo(boton_confirmar_crudo), .clk(clk), .reset(reset), .boton_estable(confirmar_estable));
    debounce db_anterior (.boton_crudo(boton_anterior_crudo), .clk(clk), .reset(reset), .boton_estable(anterior_estable));

    // ---- 3) Deteccion de flanco (pulso de un solo ciclo por apreton) ----
    wire subir_pulso, bajar_pulso, confirmar_pulso, anterior_pulso;

    detector_flanco fl_subir (.senal(subir_estable), .clk(clk), .reset(reset), .pulso(subir_pulso));
    detector_flanco fl_bajar (.senal(bajar_estable), .clk(clk), .reset(reset), .pulso(bajar_pulso));
    detector_flanco fl_confirmar (.senal(confirmar_estable), .clk(clk), .reset(reset), .pulso(confirmar_pulso));
    detector_flanco fl_anterior (.senal(anterior_estable), .clk(clk), .reset(reset), .pulso(anterior_pulso));

    // ---- 4) FSM + datapath completo ----
    wire [1:0] estado;
    wire [2:0] op_actual;
    wire [3:0] op1_actual, op2_actual, resultado;
    wire       selector_op2_activo;

    calculadora_control ctrl (
        .boton_subir_pulso(subir_pulso),
        .boton_bajar_pulso(bajar_pulso),
        .boton_confirmar_pulso(confirmar_pulso),
        .boton_anterior_pulso(anterior_pulso),
        .reset(reset),
        .clk(clk),
        .estado(estado),
        .op_actual(op_actual),
        .op1_actual(op1_actual),
        .op2_actual(op2_actual),
        .selector_op2_activo(selector_op2_activo),
        .resultado(resultado)
    );

    // ---- 5) Que valor de 4 bits se muestra segun el estado ----
    wire [3:0] op2_o_anterior, valor_mostrado;

    mux2_1_4bits sel_op2_ant (
        .a(op2_actual), .b(resultado), .sel(selector_op2_activo), .salida(op2_o_anterior)
    );

    mux4_1_4bits sel_valor (
        .in0(4'b0000),        // ELEGIR_OPERACION (00): no se usa, se apaga igual mas abajo
        .in1(op1_actual),     // INGRESA_OP1 (01)
        .in2(op2_o_anterior), // INGRESA_OP2 (10)
        .in3(resultado),      // MOSTRAR_RESULTADO (11)
        .sel(estado),
        .salida(valor_mostrado)
    );

    // ---- 6) Decodificadores de 7 segmentos ----
    wire signo_a, signo_b, signo_c, signo_d, signo_e, signo_f, signo_g;
    wire hex_a, hex_b, hex_c, hex_d, hex_e, hex_f, hex_g;

    decodificador_signo dec_signo (
        .signo(valor_mostrado[3]),
        .seg_a(signo_a), .seg_b(signo_b), .seg_c(signo_c), .seg_d(signo_d),
        .seg_e(signo_e), .seg_f(signo_f), .seg_g(signo_g)
    );

    decodificador_hex_7seg dec_hex (
        .digito(valor_mostrado),
        .seg_a(hex_a), .seg_b(hex_b), .seg_c(hex_c), .seg_d(hex_d),
        .seg_e(hex_e), .seg_f(hex_f), .seg_g(hex_g)
    );

    // Apagar ambos displays mientras se elige la operacion (estado 00):
    // en_elegir = NOT(estado[1]) AND NOT(estado[0]).
    wire estado1_n, estado0_n, en_elegir;
    not (estado1_n, estado[1]);
    not (estado0_n, estado[0]);
    and (en_elegir, estado1_n, estado0_n);

    // Activo-bajo: OR con en_elegir fuerza el segmento a 1 (apagado)
    // cuando en_elegir=1, y lo deja pasar sin cambios cuando en_elegir=0.
    or (seg1_a, signo_a, en_elegir);
    or (seg1_b, signo_b, en_elegir);
    or (seg1_c, signo_c, en_elegir);
    or (seg1_d, signo_d, en_elegir);
    or (seg1_e, signo_e, en_elegir);
    or (seg1_f, signo_f, en_elegir);
    or (seg1_g, signo_g, en_elegir);

    or (seg2_a, hex_a, en_elegir);
    or (seg2_b, hex_b, en_elegir);
    or (seg2_c, hex_c, en_elegir);
    or (seg2_d, hex_d, en_elegir);
    or (seg2_e, hex_e, en_elegir);
    or (seg2_f, hex_f, en_elegir);
    or (seg2_g, hex_g, en_elegir);

    // ---- 7) LEDs: codigo de operacion + indicador "usar resultado anterior" ----
    // buf en vez de "assign": son solo conexiones directas, pero se usa el
    // primitivo de compuerta para no salirse ni una vez del conjunto
    // permitido (and, or, not, xor, nand, nor, xnor, buf) en todo rtl/.
    buf (leds[0], op_actual[0]);
    buf (leds[1], op_actual[1]);
    buf (leds[2], op_actual[2]);
    buf (leds[3], selector_op2_activo);

endmodule
