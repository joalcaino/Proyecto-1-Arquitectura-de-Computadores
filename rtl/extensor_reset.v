// extensor_reset.v
// Extiende la señal de reset "cruda" (generador_reset.v) para que se
// mantenga activa un rato despues de soltar los botones, no solo mientras
// se mantienen apretados.
// Proyecto 1 - Arquitectura de Computadores.
//
// Por que hace falta: reset_bruto (de generador_reset.v) tiene que ser
// puramente combinacional (AND de los pines crudos, sin memoria) para
// tener un valor bien definido desde el instante en que se enciende la
// placa (ver el gotcha correspondiente en el proyecto). Pero justamente
// por ser puramente combinacional, reset_bruto seria tan "temblorosa" como
// el rebote mecanico real de los botones al SOLTARLOS -- no hay ningun
// filtro de por medio. Bug encontrado probando en la placa real: al soltar
// el par de botones del reset, contador_operacion terminaba otra vez en
// 101 (el mismo patron del bug original de debounce) en vez de quedarse en
// 000 -- el rebote de la soltada se colaba como pulsos falsos de
// subir/bajar justo en el instante en que reset_bruto ya habia bajado a 0,
// pero el debounce de esos botones todavia no se habia asentado.
//
// Solucion: en vez de usar reset_bruto directamente en el resto del
// diseño, se extiende: la señal "reset" final se queda en 1 mientras
// reset_bruto=1 (igual que antes) Y ADEMAS se queda en 1 un rato despues
// de que reset_bruto vuelve a 0, hasta que pase el mismo umbral real de
// debounce (~10.5ms a 25MHz, preescaler de 6 bits + contador de 12 bits,
// igual arquitectura que debounce.v) sin que reset_bruto vuelva a
// activarse. Asi, cualquier rebote de la soltada queda cubierto por el
// reset extendido, y solo se deja pasar el control a los botones una vez
// que todo esta realmente asentado.
//
// El contador de esta extension se "satura" (deja de incrementar) al
// llegar al maximo, en vez de dar la vuelta como contador_incremental_Nbits
// normalmente hace -- si no, el reset se volveria a activar solo cada
// ~10.5ms para siempre mientras nadie toca los botones, lo cual borraria
// el estado de la calculadora periodicamente sin que nadie apriete nada.
//
// Nota sobre arranque: si el contador de esta extension arranca en un
// estado indefinido al encender la placa (como cualquier registro armado
// con compuertas, ver el gotcha correspondiente), el peor caso posible es
// que el reset quede activo un poco MAS de tiempo del necesario justo al
// encender (hasta que el contador de saturacion, contando siempre hacia
// adelante desde cualquier valor inicial, llegue a su maximo por primera
// vez) -- nunca un estado incorrecto o inseguro, solo un arranque con un
// poquito mas de espera.
//
// Reutiliza contador_incremental_6bits.v y contador_incremental_12bits.v,
// ambos ya verificados (mismos bloques que debounce.v).

module extensor_reset (
    input  wire reset_bruto,
    input  wire clk,
    output wire reset
);

    wire reset_bruto_n;
    not (reset_bruto_n, reset_bruto);

    // Preescaler: igual que en debounce.v, tick=1 un ciclo cada 64 ciclos.
    // Se limpia con reset_bruto (arranca de nuevo cada vez que se aprieta
    // el chord de reset).
    wire [5:0] cnt_prescaler;
    contador_incremental_6bits prescaler (
        .incrementar(1'b1), .limpiar(reset_bruto), .clk(clk), .Q(cnt_prescaler)
    );
    wire tick;
    and (tick, cnt_prescaler[0], cnt_prescaler[1], cnt_prescaler[2],
               cnt_prescaler[3], cnt_prescaler[4], cnt_prescaler[5]);

    // Contador de espera: cuenta mientras reset_bruto=0 (soltado), un
    // "tick" a la vez, y se DETIENE (satura) al llegar al maximo -- no da
    // la vuelta -- para no reactivar el reset solo cada 10.5ms. Se limpia
    // (vuelve a 0) de inmediato si reset_bruto vuelve a 1.
    wire [11:0] cnt_espera;
    wire espera_completa, espera_completa_n;
    and (espera_completa, cnt_espera[0], cnt_espera[1], cnt_espera[2], cnt_espera[3],
                          cnt_espera[4], cnt_espera[5], cnt_espera[6], cnt_espera[7],
                          cnt_espera[8], cnt_espera[9], cnt_espera[10], cnt_espera[11]);
    not (espera_completa_n, espera_completa);

    wire incrementar_espera;
    and (incrementar_espera, reset_bruto_n, tick, espera_completa_n);

    contador_incremental_12bits contador_espera (
        .incrementar(incrementar_espera), .limpiar(reset_bruto), .clk(clk), .Q(cnt_espera)
    );

    // reset final: activo mientras se aprieta el chord, O mientras todavia
    // no ha pasado el tiempo de espera completo desde que se solto.
    or (reset, reset_bruto, espera_completa_n);

endmodule
