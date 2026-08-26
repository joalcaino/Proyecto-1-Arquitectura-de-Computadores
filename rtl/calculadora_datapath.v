// calculadora_datapath.v
// Modulo top de la parte "logica" de la calculadora (sin botones/FSM/7-seg
// todavia): une el selector de op2, la ALU y el registro, exactamente como
// la Figura 1 (diagrama de bloques) del informe.
// Proyecto 1 - Arquitectura de Computadores.
//
//   op2_externo, resultado (realimentado) -> mux2_1_4bits (sel=selector_op2) -> B
//   op1 (=A) y B -> alu -> R_next (resultado candidato, combinacional)
//   R_next -> registro_4bits (carga con "confirmar", clockeado por clk) -> resultado
//
// "resultado" es a la vez la salida hacia afuera (7-seg, mas adelante) y la
// realimentacion que entra de nuevo al mux como posible segundo operando de
// la siguiente operacion.
//
// No agrega compuertas nuevas: solo conecta mux2_1_4bits, alu y
// registro_4bits, todos ya verificados por separado.

module calculadora_datapath (
    input  wire [3:0] op1,          // primer operando (A)
    input  wire [3:0] op2_externo,  // segundo operando ingresado externamente
    input  wire       selector_op2, // 0 = op2 externo, 1 = resultado anterior
    input  wire       OP2,
    input  wire       OP1,
    input  wire       OP0,
    input  wire       confirmar,    // pulso de confirmar/ejecutar
    input  wire       clk,
    output wire [3:0] resultado
);

    wire [3:0] B;       // segundo operando ya seleccionado
    wire [3:0] R_next;  // salida combinacional de la ALU (candidato a resultado)

    mux2_1_4bits selector_b (
        .a(op2_externo), .b(resultado), .sel(selector_op2), .salida(B)
    );

    alu alu_inst (
        .A(op1), .B(B), .OP2(OP2), .OP1(OP1), .OP0(OP0), .R(R_next)
    );

    registro_4bits reg_inst (
        .D_nuevo(R_next), .confirmar(confirmar), .clk(clk), .Q(resultado)
    );

endmodule
