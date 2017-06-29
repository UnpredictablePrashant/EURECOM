<!-- vim: set textwidth=0: -->

# Continuity test

The small wires we will be using for the DHT11 project are cheap and not 100% reliable. This very simple exercise uses the Zybo board to test the wires.

## Interface

Create a file named `ct.vhd` in your personal subdirectory of `20170413_exercises`, put the necessary library and packages-use declarations and design a entity named `ct` (for Continuity Test) with the following input-output ports:

| Name       | Type                            | Direction | Description                                                         |
| :----      | :----                           | :----     | :----                                                               |
| `switch0`  | `std_ulogic`                    | in        | Will be wired to `SW0`, the rightmost user slide-switch of the Zybo |
| `wire_in`  | `std_ulogic`                    | in        | Will be wired to pin number 1 of the `JE` Pmod connector            |
| `wire_out` | `std_ulogic`                    | out       | Will be wired to pin number 2 of the `JE` Pmod connector            |
| `led`      | `std_ulogic_vector(3 downto 0)` | out       | Will be wired to the 4 user LEDs                                    |

## Architecture

In the same VHDL source file add a fully combinatorial architecture named `arc` that:

* sends the `switch0` input to the `wire_out` output,
* sends the constant value `'1'` to `led(0)`,
* sends the constant value `'0'` to `led(1)`,
* sends the `wire_in` input to `led(2)`,
* sends the inverse of `wire_in` input to `led(3)`.

## Compilation

Check (at least) that your design compiles:

### With `ghdl`:

```bash
o=/tmp/build.$USER/sim
rm -rf $o
mkdir -p $o
cd $o
ghdl -a --std=08 $r/ct.vhd
cd $r
```

### With Modelsim:

```bash
export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
o=/tmp/build.$USER/sim
rm -rf $o
mkdir -p $o
cd $o
vlib work
vmap work work
vcom -novopt -2008 $r/ct.vhd
cd $r
```

If it compiles you can add-commit-push, let me know and wait until you receive the email with the result of the automatic evaluation (see the **Commit** section below). But of course, it would be much better if you were validating your design yourself with your own simulation environment (see the **Simulation** section below) before pushing.

## Simulation

Create a file named `ct_sim.vhd` in your personal subdirectory containing `ct_sim.sim`, the VHDL model of a simulation environment for `ct.arc`. Compile and simulate your design:

### With `ghdl` and `gtkwave`:

```bash
o=/tmp/build.$USER/sim
rm -rf $o
mkdir -p $o
cd $o
ghdl -a --std=08 $r/ct.vhd $r/ct_sim.vhd
ghdl -e --std=08 ct_sim
./ct_sim --vcd=- | gtkwave --vcd
cd $r
```

### With Modelsim:

```bash
export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
o=/tmp/build.$USER/sim
rm -rf $o
mkdir -p $o
cd $o
vlib work
vmap work work
vcom -novopt -2008 $r/ct.vhd $r/ct_sim.vhd
vsim -novopt ct_sim
cd $r
```

## Commit

As soon as you are satisfied with the results, and before the time limit, commit your work:

```
cd $r
n=ct.vhd
git add $n; git commit -m 'Add $n'; git pull; git push
```

(to reduce the risk of collisions with others, copy paste the complete `git...` command line and execute the 4 `git` commands at once).

## Peer review

Discuss your solution with your neighbour. Have a look at mine. Ask questions.

## Logic synthesis

Notes for those who installed the Vivado synthesis tool by Xilinx on their personal computer:

* The version I used when designing this exercise is 2016.3. It could thus be that my synthesis script must be adapted if your version is not 2016.3.
* The default Vivado settings for the Zybo are provided by [Digilent](http://store.digilentinc.com/) but not installed in the official Vivado distribution. You will have to do it manually. See [this page](https://reference.digilentinc.com/reference/software/vivado/board-files?redirect=1) for Vivado versions 2015.1 and later or [this page](https://reference.digilentinc.com/reference/software/vivado/board-files-legacy?redirect=1) for older versions.

We will now synthesise our design with the Vivado tool by Xilinx to map it in the programmable logic part of the Zynq core of the Zybo. The `20170413_exercises/ct-syn.tcl` TCL script will automate the synthesis and the `20170413_exercises/boot.bif` file will tell the Xilinx tools what to do with the synthesis result. Copy the synthesis script in your personal subdirectory:

```
cd $r
cp ../ct-syn.tcl .
```

Before you can use the script, you will have to edit it and add information about the primary inputs and outputs (I/O). Indeed, Vivado needs to know to which I/O pin of the Zynq core it must route the I/O of our design. All the information we need is available in the [reference manual](https://gitlab.eurecom.fr/renaud.pacalet/ds-2017/raw/master/doc/zybo_rm.pdf) (in `doc/zybo_rm.pdf`) and [schematics](https://gitlab.eurecom.fr/renaud.pacalet/ds-2017/raw/master/doc/zybo_sch.pdf) (in `doc/zybo_sch.pdf`) of the Zybo. Open these two documents. Open your personal copy of the synthesis script with your favourite editor:

```
vim $r/ct-syn.tcl
```

The missing information shall be provided in the definition of the `ios` array, near the top of the file. Let us deal with the `switch0` case, as an example. We want to connect this primary input of our design to `SW0`, the rightmost user slide-switch of the Zybo. In the [reference manual](https://gitlab.eurecom.fr/renaud.pacalet/ds-2017/raw/master/doc/zybo_rm.pdf), look at Figure 14, page 22/26. You should see that the `SW0` slide switch of the Zybo is routed to the `G15` pin of the Zynq core.

We also need to find the voltage class to use for the signals, on the board, between the switch and the pin. It will be a LVCMOS (Low Voltage Complementary Metal Oxide Semiconductor) class but we need to identify its voltage level. The script will then instruct Vivado to configure the pin to operate with this voltage level. This voltage level can be found in the [schematics](https://gitlab.eurecom.fr/renaud.pacalet/ds-2017/raw/master/doc/zybo_sch.pdf). Page 2/13 we see that:

* The slide switches are positioned between `GND` (for ground) and `VCC3V3` (for 3.3V power supply).
* They are connected to signals (metal tracks) of the board named `SW0`...`SW3`, like in the [reference manual](https://gitlab.eurecom.fr/renaud.pacalet/ds-2017/raw/master/doc/zybo_rm.pdf).
* We also see that, to prevent the consequences of an accidental short circuit, they are connected to the Zynq core through a 10K ohms resistor.

Finally, if we go to page 10/13 of the same [schematics](https://gitlab.eurecom.fr/renaud.pacalet/ds-2017/raw/master/doc/zybo_sch.pdf), we see two groups (banks) of I/O pins of the Zynq core. The `SW0` signal is connected to bank 35 (pin `G15` as we already know from the [reference manual](https://gitlab.eurecom.fr/renaud.pacalet/ds-2017/raw/master/doc/zybo_rm.pdf)), which operation voltage is `VCC3V3`, as indicated above the yellow rectangle that represents the bank.

Add these two information (pin and voltage level) in your personal copy of the synthesis script:

```tcl
array set ios {
	"switch0"       { "G15" "LVCMOS33" }
	"wire_in"       {}
	"wire_out"      {}
	"led[0]"        {}
	"led[1]"        {}
	"led[2]"        {}
	"led[3]"        {}
}
```

Do the same for the 6 other inputs and outputs. Cross-check your findings with your neighbours. If everything looks fine, synthesize:

```bash
export PATH=$PATH:/packages/LabSoC/Xilinx/bin
p=/tmp/build.$USER/syn
rm -rf $p
mkdir -p $p
cd $p
cp $r/ct.vhd .
vivado -mode batch -source $r/ct-syn.tcl -notrace
bootgen -w -image $r/../boot.bif -o boot.bin 
cd $r
```

The synthesis result is in `$p/top.runs/impl_1/top_wrapper.bit`. It is a binary file called a *bitstream* that is be used by the Zynq core to configure the programmable logic. The last command (`bootgen`) packed it with the first (`fsbl.elf`) and second (`u-boot.elf`) stage software boot loaders that we already used when testing the `sab4z` example design and that can be found in `/packages/LabSoC/builds/zybo`. The result is a *boot image*: `boot.bin`.

## Test your design (and your wire) on the Zybo

Mount the micro SD card on a computer and define a shell variable that points to it:

```
SDCARD=<path-to-mounted-sd-card>
```

If your micro SD card does not yet contain the `sab4z` example design, prepare it:

```
cd /packages/LabSoC/builds/zybo
cp uImage devicetree.dtb uramdisk.image.gz $SDCARD
```

Or:

```
cd /tmp
wget https://perso.telecom-paristech.fr/~pacalet/archives/zybo/sdcard.tgz
tar -C $SDCARD -xf sdcard.tgz
```

Copy the new boot image to the micro SD card:

```
cp $p/boot.bin $SDCARD
sync
```

Unmount the micro SD card, eject it, plug it on the Zybo but do not power up now. First imagine how you will test the continuity of the wire: where will you plug it and what experiments will you conduct? Cross-check with your neighbours. Power on the Zybo and test the continuity of the wire.
