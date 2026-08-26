// detector_flanco.v
// Convierte una senal sostenida (por ejemplo, un boton ya estabilizado por
// debounce.v, que se mantiene en 1 mientras el boton sigue apretado) en un
// pulso de UN SOLO ciclo de reloj, generado en el primer flanco de reloj
// despues de que la senal de entrada paso de 0 a 1.
// Proyecto 1 - Arquitectura de Computadores.
//
// Es lo que pide el enunciado para confirmar/ejecutar ("pulso de un ciclo
// por apreton, detectado en el flanco de subida tras el debounce, no por
// nivel") -- y se reutiliza igual para los otros 3 botones, para que
// mantener apretado no repita la accion en cada ciclo de reloj.
//
// Usa DOS flip-flops en cadena (senal_reg1, senal_reg2), no uno solo: la
// senal de entrada es asincrona (puede cambiar en cualquier momento entre
// flancos, no solo justo en el flanco), asi que comparar la senal cruda
// contra una sola copia demorada no alcanza -- en el mismo flanco en que
// senal_reg1 recien capturo el 1, ambas comparaciones verian "1" a la vez.
// Con dos flip-flops en cadena, senal_reg2 siempre refleja el valor que
// tenia senal_reg1 ANTES de este flanco, garantizando la comparacion
// correcta: pulso = senal_reg1 AND NOT(senal_reg2).
//
// Reutiliza mux2_1.v y dff.v ya verificados.
//
// NOTA: los identificadores de Verilog solo admiten ASCII (letras sin
// tilde, digitos, _ y $); por eso "senal" va sin ~n, a diferencia del
// texto en espanol de los comentarios.

module detector_flanco (
    input  wire senal,
    input  wire clk,
    input  wire reset,
    output wire pulso
);

    wire d1_efectivo, d2_efectivo;
    wire senal_reg1, senal_reg2, senal_reg2_n;

    mux2_1 sel_reset1 (.a(senal),      .b(1'b0), .sel(reset), .salida(d1_efectivo));
    dff ff1 (.D(d1_efectivo), .CLK(clk), .Q(senal_reg1));

    mux2_1 sel_reset2 (.a(senal_reg1), .b(1'b0), .sel(reset), .salida(d2_efectivo));
    dff ff2 (.D(d2_efectivo), .CLK(clk), .Q(senal_reg2));

    not (senal_reg2_n, senal_reg2);
    and (pulso, senal_reg1, senal_reg2_n);

endmodule
