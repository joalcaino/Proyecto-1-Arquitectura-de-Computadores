// calculadora_control.v
// FSM de 4 estados que controla la calculadora completa, uniendo todo lo
// construido hasta ahora. Proyecto 1 - Arquitectura de Computadores.
//
// Estados (registro de 2 bits, contador_2bits.v):
//   00 = ELEGIR_OPERACION   -> subir/bajar mueven el codigo de operacion (LEDs)
//   01 = INGRESA_OP1        -> subir/bajar mueven op1 (7-seg)
//   10 = INGRESA_OP2        -> subir/bajar mueven op2; boton_anterior elige
//                              usar el resultado anterior en vez de op2
//   11 = MOSTRAR_RESULTADO  -> subir/bajar no hacen nada; confirmar reinicia
//
// confirmar SIEMPRE avanza al siguiente estado (con vuelta 11->00). Al
// confirmar desde INGRESA_OP2 ademas se "ejecuta": ese mismo pulso carga
// el resultado de la ALU en el registro de calculadora_datapath.
//
// Las 4 entradas de boton (subir, bajar, confirmar, anterior) deben venir
// YA procesadas por debounce.v + detector_flanco.v (pulsos de un solo
// ciclo), no las señales crudas de los pines.
//
// Reutiliza contador_2bits, contador_operacion, contador_4bits (x2),
// mux2_1, dff y calculadora_datapath, todos ya verificados.

module calculadora_control (
    input  wire boton_subir_pulso,
    input  wire boton_bajar_pulso,
    input  wire boton_confirmar_pulso,
    input  wire boton_anterior_pulso,
    input  wire reset,
    input  wire clk,

    output wire [1:0] estado,
    output wire [2:0] op_actual,
    output wire [3:0] op1_actual,
    output wire [3:0] op2_actual,
    output wire       selector_op2_activo,
    output wire [3:0] resultado
);

    // ---- Registro de estado ----
    contador_2bits reg_estado (
        .avanzar(boton_confirmar_pulso), .reset(reset), .clk(clk), .Q(estado)
    );

    // ---- Decodificacion del estado ----
    wire estado1_n, estado0_n;
    wire en_elegir, en_op1, en_op2, en_resultado;

    not (estado1_n, estado[1]);
    not (estado0_n, estado[0]);
    and (en_elegir,    estado1_n,  estado0_n);  // 00
    and (en_op1,       estado1_n,  estado[0]);  // 01
    and (en_op2,       estado[1],  estado0_n);  // 10
    and (en_resultado, estado[1],  estado[0]);  // 11

    // ---- Codigo de operacion (solo se mueve en ELEGIR_OPERACION) ----
    wire subir_op, bajar_op;
    and (subir_op, boton_subir_pulso, en_elegir);
    and (bajar_op, boton_bajar_pulso, en_elegir);

    contador_operacion reg_op (
        .subir(subir_op), .bajar(bajar_op), .reset(reset), .clk(clk), .Q(op_actual)
    );

    // ---- op1 (solo se mueve en INGRESA_OP1) ----
    wire subir_op1, bajar_op1;
    and (subir_op1, boton_subir_pulso, en_op1);
    and (bajar_op1, boton_bajar_pulso, en_op1);

    contador_4bits reg_op1 (
        .subir(subir_op1), .bajar(bajar_op1), .reset(reset), .clk(clk), .Q(op1_actual)
    );

    // ---- op2 (solo se mueve en INGRESA_OP2) ----
    wire subir_op2, bajar_op2;
    and (subir_op2, boton_subir_pulso, en_op2);
    and (bajar_op2, boton_bajar_pulso, en_op2);

    contador_4bits reg_op2 (
        .subir(subir_op2), .bajar(bajar_op2), .reset(reset), .clk(clk), .Q(op2_actual)
    );

    // ---- "usar resultado anterior": se activa en INGRESA_OP2, se limpia
    // al reiniciar la ronda (confirmar desde MOSTRAR_RESULTADO) o con reset ----
    wire set_selector, reiniciar_ronda, limpiar_selector;
    and (set_selector, boton_anterior_pulso, en_op2);
    and (reiniciar_ronda, boton_confirmar_pulso, en_resultado);
    or  (limpiar_selector, reiniciar_ronda, reset);

    wire tras_set_sel, sig_sel;
    mux2_1 sel_set   (.a(selector_op2_activo), .b(1'b1), .sel(set_selector),     .salida(tras_set_sel));
    mux2_1 sel_clear (.a(tras_set_sel),         .b(1'b0), .sel(limpiar_selector), .salida(sig_sel));
    dff ff_selector (.D(sig_sel), .CLK(clk), .Q(selector_op2_activo));

    // ---- Ejecutar: confirmar desde INGRESA_OP2 carga el resultado ----
    wire ejecutar;
    and (ejecutar, boton_confirmar_pulso, en_op2);

    // ---- Datapath completo (selector op2 + ALU + registro) ----
    calculadora_datapath dp (
        .op1(op1_actual),
        .op2_externo(op2_actual),
        .selector_op2(selector_op2_activo),
        .OP2(op_actual[2]), .OP1(op_actual[1]), .OP0(op_actual[0]),
        .confirmar(ejecutar),
        .reset(reset),
        .clk(clk),
        .resultado(resultado)
    );

endmodule
