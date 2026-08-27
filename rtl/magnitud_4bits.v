// magnitud_4bits.v
// Convierte un valor de 4 bits en complemento a dos a su "magnitud" (valor
// absoluto) de 4 bits, para mostrar en el display hexadecimal junto con el
// signo (decodificador_signo.v) por separado.
// Proyecto 1 - Arquitectura de Computadores.
//
// Bug que motivo este modulo: antes, el digito hexadecimal se armaba
// directamente desde el patron de bits crudo del valor (complemento a dos),
// mostrando por ejemplo 1001 (=-7 en complemento a dos) como "-9" en vez de
// "-7" -- el signo salia bien (bit mas significativo), pero el digito
// mostraba el patron de bits crudo, no la magnitud real. Encontrado
// probando en la placa real (jugando con subir/bajar se veia la secuencia
// 0,1,...,7,-8,-9,-A,...,-F en vez de 0,1,...,7,-8,-7,-6,...,-1).
//
// Idea: si el valor es negativo (signo=1), la magnitud es su complemento a
// dos: magnitud = ~valor + 1 (la misma operacion que usa la ALU para
// restar, aca aplicada como "0 - valor"). Si es positivo o cero (signo=0),
// la magnitud es el valor mismo, sin cambios.
//
// Reutiliza sumador_restador_4bits.v (con A=0000, B=valor, invB=1, Cin=1,
// que calcula 0 - valor) y mux2_1_4bits.v, ambos ya verificados.

module magnitud_4bits (
    input  wire [3:0] valor,
    input  wire       signo,     // 1 = negativo (mismo bit que valor[3])
    output wire [3:0] magnitud
);

    wire [3:0] negado;

    // negado = 0 - valor = ~valor + 1 (complemento a dos de valor)
    sumador_restador_4bits negador (
        .A(4'b0000), .B(valor), .invA(1'b0), .invB(1'b1), .Cin(1'b1),
        .S(negado)
    );

    mux2_1_4bits sel_magnitud (
        .a(valor), .b(negado), .sel(signo), .salida(magnitud)
    );

endmodule
