DHT11 controller project

## Authors

* Axel Strubel ([axel.strubel@eurecom.fr](mailto:axel.strubel@eurecom.fr))

* Cedric Osornio ([cedric.osornio@eurecom.fr](mailto:cedric.osornio@eurecom.fr))

* Fernando Mendoza ([luis-fernando.mendoza-miranda@eurecom.fr](mailto:luis-fernando.mendoza-miranda@eurecom.fr))

### The Shift Register

The Shift Register is another type of sequential logic circuit that can be used for the storage or the transfer of data in the form of binary numbers. This sequential device loads the data present on its inputs and then moves or "shifts" it to its output once every clock cycle, hence the name Shift Register.

A shift register basically consists of several single bit "D-Type Data Latches", one for each data bit, either a logic “0” or a “1”, connected together in a serial type daisy-chain arrangement so that the output from one data latch becomes the input of the next latch and so on.

Data bits may be fed in or out of a shift register serially, that is one after the other from either the left or the right direction, or all together at the same time in a parallel configuration.

The number of individual data latches required to make up a single Shift Register device is usually determined by the number of bits to be stored with the most common being 8-bits (one byte) wide constructed from eight individual data latches.

Shift Registers are used for data storage or for the movement of data and are therefore commonly used inside calculators or computers to store data such as two binary numbers before they are added together, or to convert the data from either a serial to parallel or parallel to serial format. The individual data latches that make up a single shift register are all driven by a common clock ( Clk ) signal making them synchronous devices.

Shift register IC’s are generally provided with a clear or reset connection so that they can be "SET" or “RESET” as required. Generally, shift registers operate in one of four different modes with the basic movement of data through a shift register being:

* Serial-in to Parallel-out (SIPO)  -  the register is loaded with serial data, one bit at a time,
  with the stored data being available at the output in parallel form.
* Serial-in to Serial-out (SISO)  -  the data is shifted serially "IN" and “OUT” of the register, 
  one bit at a time in either a left or right direction under clock control.
* Parallel-in to Serial-out (PISO)  -  the parallel data is loaded into the register 
  simultaneously and is shifted out of the register serially one bit at a time under clock control.
* Parallel-in to Parallel-out (PIPO)  -  the parallel data is loaded simultaneously into the register, 
  and transferred together to their respective outputs by the same clock pulse.

The effect of data movement from left to right through a shift register can be presented graphically as:

alt text [images/shiftregister.gif](http://www.electronics-tutorials.ws/sequential/seq15a.gif)

# Shift register

Shift registers are a very common hardware element that can be found in many designs. This exercise consists in designing one.

## Interface

Create a file named sr.vhd in your personal subdirectory of 20170427_exercises, put the necessary library and packages-use declarations and design a entity named sr (for Shift Register) with the following input-output ports:

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Direction</td>
    <td>Description</td>
  </tr>
  <tr>
    <td>clk</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Master clock. The design is synchronized on the rising edge of clk.</td>
  </tr>
  <tr>
    <td>sresetn</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Synchronous, active low reset.</td>
  </tr>
  <tr>
    <td>shift</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Shift command input. The register shifts when shift is asserted high.</td>
  </tr>
  <tr>
    <td>di</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Serial input of the shift register.</td>
  </tr>
  <tr>
    <td>do</td>
    <td>std_ulogic_vector(3 downto 0)</td>
    <td>out</td>
    <td>Current value of the shift register.</td>
  </tr>
</table>


## Architecture

In the same VHDL source file add an architecture named arc that:

* Uses clk as its master clock. The design is synchronized on the rising edge of clk.

* Contains a 4-bits internal register named reg.

* Uses sresetn as its *synchronous*, active low reset to force reg to all-zeroes.

* Sends reg to do.

* Shifts reg by one position to the right each time the shift signal is asserted high on a rising edge of clk (and sresetn is not active). The leftmost entering bit is di. The rightmost leaving bit is lost.

## Data Selector

data selector/multiplexer A logic circuit that may be considered as a single-pole multiway switch whose output is determined by the position of the switch wiper (see diagram). The wiper position is controlled by a select signal, normally digital, that indicates which of the inputs is to be connected to the output. In this way a number of channels of data may be placed sequentially on a time-shared output bus under the control of the select signal, a process known as time-division multiplexing. Inputs to and outputs from a multiplexer may be in digital or analog form. See also decoder/demultiplexer.

##### Default State SW0, sw1, sw2

<table>
  <tr>
    <td>S</td>
    <td>SW1</td>
    <td>SW2</td>
    <td>SW3</td>
  </tr>
  <tr>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
  </tr>
  <tr>
    <td>1</td>
    <td>0</td>
    <td>0</td>
    <td>1</td>
  </tr>
  <tr>
    <td>2</td>
    <td>0</td>
    <td>1</td>
    <td>0</td>
  </tr>
  <tr>
    <td>3</td>
    <td>1</td>
    <td>0</td>
    <td>0</td>
  </tr>
  <tr>
    <td>4</td>
    <td>0</td>
    <td>1</td>
    <td>1</td>
  </tr>
  <tr>
    <td>5</td>
    <td>1</td>
    <td>0</td>
    <td>1</td>
  </tr>
  <tr>
    <td>6</td>
    <td>1</td>
    <td>1</td>
    <td>0</td>
  </tr>
  <tr>
    <td>7</td>
    <td>1</td>
    <td>1</td>
    <td>1</td>
  </tr>
</table>


## Block diagram	

![image alt text](image_0.png)

## Technical details

## Functional validation

## Synthesis

## Experiments on the Zybo

