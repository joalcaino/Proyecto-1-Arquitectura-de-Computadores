// generador_reset.v
// Genera la señal de reset global de toda la calculadora, a partir de
// mantener presionados dos de los botones fisicos al mismo tiempo
// (subir + bajar). Proyecto 1 - Arquitectura de Computadores.
//
// Por que no se puede generar el reset con un contador/registro propio:
// nuestro dff.v esta armado 100% con compuertas (latch SR de 2 NOR
// cruzadas), no con el flip-flop nativo del chip. Un latch asi, sin nada
// que lo fuerce a un valor, arranca en un estado realmente indefinido al
// encender la placa (es una propiedad fisica del circuito, no solo un
// tema de simulacion) -- confirmado con la documentacion de Lattice: la
// garantia de "arranca en 0" aplica al flip-flop NATIVO del iCE40
// (SB_DFF), no a un latch armado a mano con compuertas sueltas.
//
// Por eso el reset no puede salir de otro contador nuestro (tendria el
// mismo problema). Tiene que salir de algo sin memoria: se lee el pin
// crudo de los botones directamente (sin pasar por debounce ni por
// ningun flip-flop) y se combinan con un AND. Como es puramente
// combinacional, su valor esta siempre bien definido desde el instante
// en que se enciende la placa.
//
// Se usan las señales CRUDAS (antes de debounce.v), no las procesadas:
// el debounce mismo necesita "reset" para arrancar bien, asi que no se
// puede depender de su salida para generar el propio reset.

module generador_reset (
    input  wire boton_subir_crudo,
    input  wire boton_bajar_crudo,
    output wire reset
);

    and (reset, boton_subir_crudo, boton_bajar_crudo);

endmodule
