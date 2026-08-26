// d_latch.v
// Latch D (sensible a nivel), construido a partir de sr_latch.v.
// Proyecto 1 - Arquitectura de Computadores.
//
// Mientras EN=1, el latch es "transparente": Q sigue a D en todo momento.
// Cuando EN=0, Q queda congelado en el ultimo valor que tenia D justo antes
// de que EN bajara (retiene / hold).
//
// Se arma convirtiendo D y su complemento en las senales S y R del latch SR,
// pero solo cuando EN=1 (si EN=0, S=R=0 y el SR-latch queda en modo hold).
//
// Solo primitivas de compuertas: not, and (mas el sr_latch, hecho con nor).

module d_latch (
    input  wire D,
    input  wire EN,
    output wire Q
);

    wire Dn, S, R, Qn;

    not (Dn, D);
    and (S, D,  EN);
    and (R, Dn, EN);

    sr_latch nucleo (.S(S), .R(R), .Q(Q), .Qn(Qn));

endmodule
