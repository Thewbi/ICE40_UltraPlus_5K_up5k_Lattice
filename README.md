# ICE40_UltraPlus_5K_up5k_Lattice

Examples for the ICE40 UltraPlus 5k (ICE40 UP5K) Breakout Board.

# Installing oss-cad-suite on Windows

Install the oss-cad-suite on windows which also contains yosys. Download the latest release of the oss-cad-suite from https://github.com/YosysHQ/oss-cad-suite-build/releases. You will get the file oss-cad-suite-windows-x64-20250315.exe. First unblock the installer (Properties > General > Unblock). Then run the .exe file. It will automatically extract to a folder called oss-cad-suite in the current folder.

# Using the oss-cad-suite

Create the environment without none of the yosys .exe files will execute successfully.

```
set PATH=%PATH%;C:\Users\wolfg\Downloads\oss-cad-suite\lib\
cd <your_project_folder>
C:\Users\wolfg\Downloads\oss-cad-suite\environment.bat
```

# Compiling

Compiling verilog code to a bistream for the ICE40 UP5K.

## Generate .blif file and .json file.

The first step is to use yosys.exe to compile verilog source code to a .blif and a .json file.

.blif is the Berkeley Logic Interchange Format for exchanging simple sequential logic between programms.
See: https://yosyshq.readthedocs.io/projects/yosys/en/0.42/_downloads/843c6be0c639905141f4dabd87d46dd9/APPNOTE_010_Verilog_to_BLIF.pdf

The .json file that is generated contains ports, cells and nets.

We will create a build subfolder to store the generated .blif and .json file into. Using a separated build folder allows us to ignore that folder from version control and also to easily clean the project by erasing the build folder.

Specify the top module with the -top parameter

Using the oss-cad-suite:

```
cd <your_project_folder>
mkdir build
yosys.exe -p "synth_ice40 -top top -blif build/blinky.blif -json build/blinky.json" top.v
```

If you want to compile more than one verilog file, just list all files separated by spaces after top.v

If yosys.exe outputs something like

```
2.50. Executing CHECK pass (checking for obvious problems).
Checking module top...
Found and reported 0 problems.

2.51. Executing BLIF backend.

2.52. Executing JSON backend.
```

then the compilation did work.

## Perform Place and Route

The next step towards a bitstream file is place and route where the abstract TTL logic is fit to the hardware available on the ICE40 chip.

The output of this stage is an .asc file which is produced by the nextpnr application.

For IceStick:

```
nextpnr-ice40 --hx1k --package tq144 --json blinky.json --asc blinky.asc --pcf icestick.pcf -q
```

For Ice40 UltraPlus 5K eval board:

```
nextpnr-ice40 --package sg48 --up5k --json build/blinky.json --asc build/blinky.asc --pcf ice40_ultraplus_5k.pcf -q
```

.pcf files are constraint files and are used to define symbols that can be used in the verilog source code and are then mapped to the hardware of the ICE40 chip. Examples are ports that are connected to the system clock, the LEDs and the UART TX and RX lines.

## Convert .asc file to .bin file

In this stage, the bitstream file .bin is generated which can be used to program the ICE40 UP5K breakout board.

```
icepack build/blinky.asc build/blinky.bin
```

## Changing the USB driver

To program the ICE40 FPGA, we will use the tool iceprog from the oss-cad-suite. iceprog is platform independant and uses open source USB drivers to talk to the FTDI chip on the breakout board. The open source drivers are most easily installed using the Zadig tool on windows.

Zadig is a tool that can change the USB driver used per USB device that is detected by the Windows Operating System. First download Zadig.

Plug in the ICE40 UP5K eval board into your computer via a USB cable that transmits data and not only charge.

In Zadig: Options > List all Devices

Find "Dual RS232-HS (Interface 0)" or maybe the name differs. What is important is that you change the driver of the interface 0 which is the FTDI chips interface on which it receives the firmware.

On Windows:
Select the "WinUSB (v6.1.7600.16385)" driver from the drop-down

On macos:
Select the "libusbk (v3.0.7.0)" driver from the drop-down

Click "Replace Driver"

"The driver was installed successfully!"

Close Zadig.

## Flash / Program

Make sure the eval board is still plugged in.

### Program into SRAM

This is the fastest method for development and does not charge the flash. Flash has a finite amount of write cycles before it breaks. There are thousands of write cycles available but if you can write to SRAM and do that even faster, why waste cycles on flash?

Initially, when the ICE40 UP5K board is delivered, the jumpers on J6 are applied so that programming the SRAM chip is disabled!
Probably this is done so that a user does not accidently write an application into volatile SRAM and then reboots the board which then resets SRAM and the application is lost.

The instructions for activating SRAM programming via the jumpers J6 are explained on the small sheet of paper that comes with the ICE40 UP5K board. The instructions are reproduced here: https://gojimmypi.github.io/FPGA-Programming-iCE40UP5K-B-EVN/

To program to (S)RAM, change the jumpers on J6 from horizontal orientation to vertical orientation!

When the application is programmed to SRAM, it is lost after a power cycle.

```
iceprog -S -d i:0x0403:0x6010:0 build/led.bin
```

The parameter S stands for SRAM since the type of RAM used on the breakout board is SRAM.

### Program into Flash

Programming the Flash takes longer but is persistent and the application stays stored on the eval board even accross power cycles.

```
iceprog build/led.bin
iceprog -d i:0x0403:0x6010:0 build/led.bin
C:\Users\wolfg\Downloads\oss-cad-suite\bin\iceprog.exe -d i:0x0403:0x6010:0 build/led.bin
```
