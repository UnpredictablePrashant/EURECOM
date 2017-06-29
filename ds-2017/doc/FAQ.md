<!-- vim: set textwidth=0: -->
# Frequently Asked Questions

## Zybo

* [My Zybo is connected to the computer with the USB cable, I switch the power
  on but the board does not power on](#Q01-01)

## GNU/Linux

* [I am not allowed to modify `~/.bashrc`](#Q02-01)
* [I modified `~/.bashrc` (or `~/.bashrc`) but still, I cannot use the Modelsim commands](#Q01-02)

## VHDL tools

* [Where can I find a free Modelsim edition?](#Q03-01)
* [Where to find ghdl and gtkwave?](#Q03-02)

## VHDL compilation

* [I got an error about "*cannot read output*"](#Q04-01)
* [I got a "*nonresolved signal X has multiple sources*" error](#Q04-02)

## VHDL simulation

* [I tried to simulate my design but got an error about no "*design unit*" with this name](#Q05-01)
* [I tried to simulate my design but nothing happens and the simulation ends immediately](#Q05-02)

----

## Zybo

### <a name="Q01-01"></a>My Zybo is connected to the computer with the USB cable, I switch the power on but the board does not power on

Check the blue jumper that selects the power source and make sure it selects the USB, not the *Wall* power plug. Check also the blue jumper that selects the boot medium and make sure it selects the SD card, not the JTAG or the QSPI flash. Look at the commented Zybo picture on the home page of [SAB4Z](https://gitlab.telecom-paristech.fr/renaud.pacalet/sab4z) to identify the jumpers.

## GNU/Linux

### <a name="Q02-01"></a>I am not allowed to modify `~/.bashrc`

Put your customizations in `~/.bashrc+`, instead of `~/.bashrc`. Your `~/.bashrc` is a symbolic link that point to a file on which you do not have write permissions. But it *sources* `~/.bashrc+`.

### <a name="Q02-02"></a>I modified `~/.bashrc` (or `~/.bashrc`) but still, I cannot use the Modelsim commands

Your modifications will take effect only for new shells. Launch a new shell.

## VHDL tools

### <a name="Q03-01"></a>Where can I find a free Modelsim edition?

* [https://www.mentor.com/company/higher_ed/modelsim-student-edition](https://www.mentor.com/company/higher_ed/modelsim-student-edition)
* [https://www.altera.com/products/design-software/model---simulation/modelsim-altera-software.html](https://www.altera.com/products/design-software/model---simulation/modelsim-altera-software.html)

### <a name="Q03-02"></a>Where to find ghdl and gtkwave?

* ghdl: [https://github.com/tgingold/ghdl/releases/](https://github.com/tgingold/ghdl/releases/)
* gtkwave: [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)

## VHDL compilation

### <a name="Q04-01"></a>I got an error about "*cannot read output*"

You tried to read a primary output port of your entity from within the architecture. This is not allowed in VHDL version prior VHDL2008. Either compile and simulate with VHDL2008 (option `-2008` with Modelsim and `-std=08` with GHDL) or declare an internal intermediate signal:

    signal MyOutput_local: ...
    ...
    MyOutput <= MyOutput_local;
    ...

and use this internal signal for reading and writing everywhere else.

### <a name="Q04-02"></a>I got a "*nonresolved signal X has multiple sources*" error

You are trying to assign a value to a signal, which type is *non resolved*, from more than one process:

    P1: process...
    ...
      sig <= ...;
    ...
    end process P1;
    
    P2: process...
    ...
      sig <= ...;
    ...
    end process P2;

This is a nice short-circuit situation. As short-circuits are undesirable VHDL forbids multiple sources for signals of a *non resolved* type. If you really **know** what you are doing, use a *resolved* type, instead, like, for instance, `std_logic`. But do **not** use *resolved* types if your intention is not to model a situation where several hardware devices drive the same signal.

## VHDL simulation

### <a name="Q05-01"></a>I tried to simulate my design but got an error about no "*design unit*" with this name

You launched the simulation on something that is not the name of an `entity` (or `configuration`). Most likely, you passed a file name to the simulator instead of an `entity` name.

### <a name="Q05-02"></a>I tried to simulate my design but nothing happens and the simulation ends immediately

The design you try to simulate is probably not a simulation environment. Most likely, you are trying to simulate the model of a circuit with primary inputs. As nothing drives these inputs, the simulation engine immediately concludes that there is nothing to come in the future. This is one of the situations where a simulator stops the simulation. Design, compile and simulate a simulation environment that instantiates your circuit and drives its inputs with some processes.
