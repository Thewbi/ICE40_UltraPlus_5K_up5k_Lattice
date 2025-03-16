# Hint

This example does not work!
I cannot get UART / RS232 to work on the ICE40 UP5K eval board!

Same problems as this poor guy who never got a response to his question: https://github.com/YosysHQ/icestorm/issues/284

# Quickstart

```
cd <your_project_folder>
mkdir build
set PATH=%PATH%;C:\Users\wolfg\Downloads\oss-cad-suite\lib\
C:\Users\wolfg\Downloads\oss-cad-suite\environment.bat
yosys.exe -p "synth_ice40 -top top -blif build/aout.blif -json build/aout.json" top.v uart_rx.v uart_tx.v uart_baud_tick_gen.v
nextpnr-ice40 --package sg48 --up5k --json build/aout.json --asc build/aout.asc --pcf ice40_ultraplus_5k.pcf -q
icepack build/aout.asc build/aout.bin
iceprog -S -d i:0x0403:0x6010:0 build/aout.bin
```