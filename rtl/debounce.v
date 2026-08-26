// debounce.v
// Filtra los rebotes mecanicos de un boton fisico.
// Proyecto 1 - Arquitectura de Computadores.
//
// Idea: mientras la señal cruda del boton (que rebota, cambia rapido varias
// veces al presionar/soltar) sea DISTINTA de la señal ya estabilizada, se
// cuenta con contador_incremental_8bits. Si la señal cruda deja de cambiar
// y se mantiene igual por 256 ciclos de reloj seguidos, se la acepta como
// el nuevo valor estable. Si en cualquier momento vuelve a coincidir con
// la estable (rebote), el contador se limpia y hay que esperar otros 256
// ciclos de estabilidad para que se acepte cualquier cambio futuro.
//
// NOTA: el umbral de 256 ciclos hay que ajustarlo en la Fase 6 segun la
// frecuencia real del oscilador de la Nandland Go Board (dato que se busca
// en la documentacion de la placa, no se inventa) para que equivalga a
// unos ~10ms reales. Con un incrementador_8bits mas ancho (o encadenando
// dos) se puede lograr un umbral mayor si hiciera falta.
//
// Reutiliza contador_incremental_8bits.v, mux2_1.v y dff.v, todos ya
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

    wire [7:0] cnt;
    contador_incremental_8bits contador (
        .incrementar(diferente), .limpiar(limpiar_cnt), .clk(clk), .Q(cnt)
    );

    // lleno = 1 cuando el contador llego a 11111111 (256 ciclos distinto)
    wire lleno;
    and (lleno, cnt[0], cnt[1], cnt[2], cnt[3], cnt[4], cnt[5], cnt[6], cnt[7]);

    wire tras_actualizar, siguiente;
    mux2_1 sel_actualizar (.a(boton_estable), .b(boton_crudo), .sel(lleno), .salida(tras_actualizar));
    mux2_1 sel_reset      (.a(tras_actualizar), .b(1'b0),      .sel(reset), .salida(siguiente));

    dff ff_estable (.D(siguiente), .CLK(clk), .Q(boton_estable));

endmodule
