<!-- vim: set textwidth=0: -->

# State machine

This exercise consists in designing a Moore finite state machine.

## Interface

Create a file named `sm.vhd` in your personal subdirectory of `20170504_exercises`, put the necessary library and packages-use declarations and design a entity named `sm` (for State Machine) with the following input-output ports:

| Name       | Type                            | Direction | Description                                                             |
| :----      | :----                           | :----     | :----                                                                   |
| `clk`      | `std_ulogic`                    | in        | Master clock. The design is synchronized on the rising edge of `clk`.   |
| `sresetn`  | `std_ulogic`                    | in        | *Synchronous*, active low reset.                                        |
| `go`       | `std_ulogic`                    | in        | Go command input.                                                       |
| `stp`      | `std_ulogic`                    | in        | Stop command input.                                                     |
| `spin`     | `std_ulogic`                    | in        | Spin command input.                                                     |
| `up`       | `std_ulogic`                    | out       | Up output.                                                              |

## Specifications

`sm` is a 3-states Moore state machine which states are `IDLE`, `RUN` and `HALT`. It uses `clk` as its master clock. The design is synchronized on the rising edge of `clk`. It uses `sresetn` as its *synchronous*, active low reset. The `IDLE` state is the reset state. The following table details the value of the output and the state transitions when the reset is not active (`-` means *don't care*):

| State      | `up` | (`go`,`stp`,`spin`) | Next state |
| :----      | :--- | :----               | :----      |
| `IDLE`     | `0`  | (`0`,`-`,`-`)       | `IDLE`     |
| `IDLE`     | `0`  | (`1`,`-`,`-`)       | `RUN`      |
| `RUN`      | `1`  | (`-`,`0`,`-`)       | `RUN`      |
| `RUN`      | `1`  | (`-`,`1`,`-`)       | `HALT`     |
| `HALT`     | `0`  | (`-`,`-`,`1`)       | `HALT`     |
| `HALT`     | `0`  | (`1`,`-`,`0`)       | `RUN`      |
| `HALT`     | `0`  | (`0`,`-`,`0`)       | `IDLE`     |

Draw a state diagram of `sm` and a block diagram of its architecture. Translate all this in a VHDL architecture named `arc` in the `sm.vhd` VHDL source file.

## Compilation

Check (at least) that your design compiles:

### With `ghdl`:

```bash
cd $o
ghdl -a --std=08 $r/sm.vhd
cd $r
```

### With Modelsim:

```bash
cd $o
vcom -novopt -2008 $r/sm.vhd
cd $r
```

If it compiles you can add-commit-push and wait until you receive the email with the result of the automatic evaluation (see the **Commit** section below). But of course, it would be much better if you were validating your design yourself with your own simulation environment (see the **Simulation** section below) before pushing.

## Simulation

Create a file named `sm_sim.vhd` in your personal subdirectory containing `sm_sim.sim`, the VHDL model of a simulation environment for `sm.arc`. Compile and simulate your design:

### With `ghdl` and `gtkwave`:

```bash
cd $o
ghdl -a --std=08 $r/sm.vhd $r/sm_sim.vhd
ghdl -e --std=08 sm_sim
./sm_sim --vcd=- | gtkwave --vcd
cd $r
```

### With Modelsim:

```bash
cd $o
vcom -novopt -2008 $r/sm.vhd $r/sm_sim.vhd
vsim -novopt sm_sim
cd $r
```

## Commit

As soon as you are satisfied with the results, and before the time limit, commit your work:

```
cd $r
n=sm.vhd
git add $n; git commit -m 'Add $n'; git pull; git push
```

(to reduce the risk of collisions with others, copy paste the complete `git...` command line and execute the 4 `git` commands at once).

## Peer review

Discuss your solution with your neighbour. Have a look at mine. Ask questions.

