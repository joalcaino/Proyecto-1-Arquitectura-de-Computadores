// debounce.v
// Filtra los rebotes mecanicos de un boton fisico.
// Proyecto 1 - Arquitectura de Computadores.
//
// Idea: mientras la señal cruda del boton (que rebota, cambia rapido varias
// veces al presionar/soltar) sea DISTINTA de la señal ya estabilizada, se
// cuenta con contador_incremental_18bits. Si la señal cruda deja de cambiar
// y se mantiene igual por 262144 ciclos de reloj seguidos, se la acepta
// como el nuevo valor estable. Si en cualquier momento vuelve a coincidir
// con la estable (rebote), el contador se limpia y hay que esperar otros
// 262144 ciclos de estabilidad para que se acepte cualquier cambio futuro.
//
// Umbral real: a 25MHz (reloj confirmado de la Nandland Go Board, Fase 6),
// 262144 ciclos = 262144 / 25e6 s = ~10.5 ms, que es un tiempo tipico de
// rebote mecanico real. Se probo primero con un umbral de 256 ciclos
// (~10 microsegundos) que resulto ser 1000 veces demasiado corto en la
// placa real -- los botones generaban varios pulsos falsos por cada
// apreton porque el rebote mecanico real dura mucho mas que eso. Bug
// descubierto probando en hardware real (no aparece en simulacion con
// señales limpias, sin rebote, como las que arma un testbench).
//
// Reutiliza contador_incremental_18bits.v, mux2_1.v y dff.v, todos ya
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

    wire [17:0] cnt;
    contador_incremental_18bits contador (
        .incrementar(diferente), .limpiar(limpiar_cnt), .clk(clk), .Q(cnt)
    );

    // lleno = 1 cuando el contador llego a todos 1 (262144 ciclos distinto, ~10.5ms a 25MHz)
    wire lleno;
    and (lleno, cnt[0], cnt[1], cnt[2], cnt[3], cnt[4], cnt[5], cnt[6], cnt[7],
                cnt[8], cnt[9], cnt[10], cnt[11], cnt[12], cnt[13], cnt[14],
                cnt[15], cnt[16], cnt[17]);

    wire tras_actualizar, siguiente;
    mux2_1 sel_actualizar (.a(boton_estable), .b(boton_crudo), .sel(lleno), .salida(tras_actualizar));
    mux2_1 sel_reset      (.a(tras_actualizar), .b(1'b0),      .sel(reset), .salida(siguiente));

    dff ff_estable (.D(siguiente), .CLK(clk), .Q(boton_estable));

endmodule
