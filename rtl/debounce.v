// debounce.v
// Filtra los rebotes mecanicos de un boton fisico.
// Proyecto 1 - Arquitectura de Computadores.
//
// Idea: mientras la señal cruda del boton (que rebota, cambia rapido varias
// veces al presionar/soltar) sea DISTINTA de la señal ya estabilizada, se
// cuenta con contador_incremental_12bits. Si la señal cruda deja de cambiar
// y se mantiene igual por 4096 ciclos de reloj seguidos, se la acepta
// como el nuevo valor estable. Si en cualquier momento vuelve a coincidir
// con la estable (rebote), el contador se limpia y hay que esperar otros
// 4096 ciclos de estabilidad para que se acepte cualquier cambio futuro.
//
// Umbral real: a 25MHz (reloj confirmado de la Nandland Go Board, Fase 6),
// 4096 ciclos = 4096 / 25e6 s = ~163.8 microsegundos.
//
// Historia de este numero (dos bugs encontrados probando en la placa real,
// ninguno de los dos aparece en simulacion con Icarus porque Icarus no
// simula demoras de tiempo reales, solo la logica):
//   1) Primera version: 256 ciclos (~10 microsegundos). Resulto ser 1000
//      veces demasiado corto para el rebote mecanico real -- cada apreton
//      generaba varios pulsos falsos.
//   2) Se subio a 18 bits / 262144 ciclos (~10.5ms) para dar bastante mas
//      margen. Pero esto alargo mucho la cadena de 18 sumadores encadenados
//      de contador_incremental_18bits, y esa cadena combinacional resulto
//      demasiado profunda para "asentarse" dentro de un ciclo de reloj a
//      25MHz en el chip real (nuestros flip-flops estan hechos de
//      compuertas, no de las piezas nativas de memoria del chip, y por eso
//      las herramientas de sintesis no pueden verificar formalmente los
//      tiempos -- ver el gotcha de "--ignore-loops" en el proyecto).
//      Resultado: NINGUN boton respondia en la placa (aunque en simulacion
//      pasaba 100%).
//   3) Se bajo a 12 bits / 4096 ciclos (~164 microsegundos) como punto
//      intermedio: 16x mas margen que el umbral original que resulto
//      demasiado corto, pero con una cadena de solo 12 sumadores (4 mas
//      que la version de 8 bits que si funcionaba en el chip), para no
//      volver a romper el tiempo del reloj real. Verificado en la placa.
//
// Reutiliza contador_incremental_12bits.v, mux2_1.v y dff.v, todos ya
// verificados.

module debounce (
    input  wire boton_crudo,
    input  wire clk,
    input  wire reset,
    output wire boton_estable
);

    wire diferente, igual, limpiar_cnt;
    xor (diferente, boton_crudo, boton_estable);
    not (igual, diferente);
    or  (limpiar_cnt, igual, reset);

    wire [11:0] cnt;
    contador_incremental_12bits contador (
        .incrementar(diferente), .limpiar(limpiar_cnt), .clk(clk), .Q(cnt)
    );

    // lleno = 1 cuando el contador llego a todos 1 (4096 ciclos distinto, ~164us a 25MHz)
    wire lleno;
    and (lleno, cnt[0], cnt[1], cnt[2], cnt[3], cnt[4], cnt[5], cnt[6], cnt[7],
                cnt[8], cnt[9], cnt[10], cnt[11]);

    wire tras_actualizar, siguiente;
    mux2_1 sel_actualizar (.a(boton_estable), .b(boton_crudo), .sel(lleno), .salida(tras_actualizar));
    mux2_1 sel_reset      (.a(tras_actualizar), .b(1'b0),      .sel(reset), .salida(siguiente));

    dff ff_estable (.D(siguiente), .CLK(clk), .Q(boton_estable));

endmodule
