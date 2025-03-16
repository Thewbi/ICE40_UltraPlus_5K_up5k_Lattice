# Quickstart

```
cd <your_project_folder>
mkdir build
set PATH=%PATH%;C:\Users\wolfg\Downloads\oss-cad-suite\lib\
C:\Users\wolfg\Downloads\oss-cad-suite\environment.bat
yosys.exe -p "synth_ice40 -top top -blif build/aout.blif -json build/aout.json" top.v uart.v util.v
nextpnr-ice40 --package sg48 --up5k --json build/aout.json --asc build/aout.asc --pcf upduino_v2.pcf -q
icepack build/aout.asc build/aout.bin
iceprog -S -d i:0x0403:0x6010:0 build/aout.bin
```