# Proyecto 1 — Calculadora de 4 bits (Diseño Lógico y FPGA)

Arquitectura de Computadores, Universidad de los Andes. Calculadora de 4 bits en complemento a dos, implementada en Verilog estructural (solo compuertas lógicas primitivas) y programada en una FPGA Lattice iCE40 HX1K (Nandland Go Board).

Integrantes: Josefa Alcaíno Lira, Felipe Izcúe Ferrer, Martín Norton Haigis.

## Estructura del repositorio

```
rtl/        Todos los módulos del diseño (solo compuertas: and, or, not, xor,
            nand, nor, xnor, buf — sin always/<=/if/case/operadores de alto nivel).
tb/         Testbenches de cada módulo (sí pueden usar Verilog de alto nivel,
            son solo el modelo de referencia para verificar, no se suben a la FPGA).
constraints/ (si aplica) archivos auxiliares de restricciones.
docs/       Documentación auxiliar.
calculadora_top.pcf   Mapeo de pines de calculadora_top a la Nandland Go Board.
informe.pdf           Informe con diseño, tablas de verdad, mapas de Karnaugh y resultados.
```

## Requisitos

- **Icarus Verilog** (`iverilog` + `vvp`) y **GTKWave**, para simular y ver las señales.
- **OSS CAD Suite** (incluye Yosys, nextpnr-ice40, icepack, iceprog), para sintetizar y programar la FPGA.
- Una Nandland Go Board (iCE40HX1K, VQ100) conectada por USB.

## Cómo correr una simulación (Icarus Verilog)

Cada módulo en `rtl/` tiene su testbench correspondiente en `tb/` (mismo nombre + `_tb`). Para simular, por ejemplo, el módulo top completo:

```
iverilog -o sim.vvp $(ls rtl/*.v | grep -v '_tb.v') tb/calculadora_top_tb.v
vvp sim.vvp
```

Esto compila todos los módulos de `rtl/` junto con el testbench indicado, y corre la simulación. La consola muestra "OK ..." por cada caso que pasa, y "FALLO ..." con el detalle si algo no coincide con lo esperado. Al final imprime un resumen tipo `TODOS LOS CASOS PASARON` o `N CASOS FALLARON`.

Para simular otro módulo, cambia el testbench del final por el que corresponda (por ejemplo `tb/magnitud_4bits_tb.v`, `tb/debounce_tb.v`, etc.).

**Nota:** el testbench de `calculadora_top` (`calculadora_top_tb.v`) simula tiempos reales de debounce (~262.000 ciclos de reloj por cada apretón de botón simulado), así que puede tardar varios minutos en correr completo — es normal, no está colgado.

### Cambiar los valores/operaciones de una simulación

Durante la evaluación, el profesor indicará qué operación y valores probar. Para eso, edita directamente el bloque `initial` del testbench correspondiente (por ejemplo `tb/calculadora_top_tb.v`, sección `initial begin ... end`), cambiando los valores que se ingresan con `presionar(SUBIR)`/`presionar(BAJAR)` o el operando de un testbench más simple, guarda el archivo, y vuelve a correr los dos comandos de arriba (`iverilog` + `vvp`).

## Cómo ver las señales en GTKWave

Cada testbench genera un archivo `.vcd` (por ejemplo `calculadora_top_tb.vcd`) en la misma carpeta donde se corrió `vvp`. Para abrirlo:

```
gtkwave calculadora_top_tb.vcd
```

Dentro de GTKWave, en el panel de la izquierda selecciona el módulo (`calculadora_top_tb` → `dut`), y arrastra las señales que quieras ver (por ejemplo `clk`, `boton_subir_crudo`, `estado`, `resultado`, `leds`) a la ventana de formas de onda.

## Cómo reconstruir el bitstream y programar la FPGA

Con OSS CAD Suite (terminal WSL en Windows, o el shell correspondiente en Linux/Mac), parado en la raíz del repositorio:

```
yosys -p "read_verilog rtl/*.v; synth_ice40 -top calculadora_top -noabc -json calculadora_top.json"
nextpnr-ice40 --hx1k --package vq100 --json calculadora_top.json --pcf calculadora_top.pcf --asc calculadora_top.asc --ignore-loops
icepack calculadora_top.asc calculadora_top.bin
sudo iceprog calculadora_top.bin
```

Notas importantes:

- El flag `-noabc` es necesario porque el diseño arma todos sus flip-flops con compuertas puras (no usa el flip-flop nativo del chip, está prohibido por el enunciado). Sin `-noabc`, algunas versiones de Yosys fallan con `ERROR: Found combinatorial logic loop` al toparse con esos flip-flops. Si tu versión de Yosys no reconoce `-noabc`, corre `yosys -p "help synth_ice40" 2>&1 | grep -E "^    -"` para ver los flags disponibles (versiones más viejas usaban `-noabc9`).
- `nextpnr-ice40` va a reportar bastantes warnings de "logic loop" y terminar con `No Fmax available; no interior timing paths found in design` — esto es esperado y no es un error: como el diseño no usa flip-flops nativos, no existe análisis de timing formal posible para él. Lo relevante es que termine con `Program finished normally`.
- En WSL, si `iceprog` falla con `Can't find iCE FTDI USB device`, hay que volver a conectar el dispositivo USB a WSL desde una PowerShell como administrador: `usbipd list` (para ver el BUSID de la placa) y `usbipd attach --wsl --busid <BUSID>`.

## Cómo se usa la calculadora en la placa

1. **Elegir operación:** el botón superior izquierdo sube el código de operación (LEDs), el inferior izquierdo lo baja. Los códigos van de `000` (reinicio) a `101` (shift right).
2. **Confirmar:** el botón superior derecho avanza al siguiente paso.
3. **Ingresar op1:** subir/bajar ajustan el valor (se muestra en los displays: signo en el primero, hexadecimal en el segundo). Confirmar para avanzar.
4. **Ingresar op2:** igual que op1, o presionar el botón inferior derecho para usar el resultado de la operación anterior en su lugar. Confirmar para ejecutar.
5. **Resultado:** se muestra en los displays. Presionar confirmar de nuevo vuelve a elegir operación.
6. **Reset:** mantener presionados juntos los botones superior izquierdo e inferior izquierdo.
