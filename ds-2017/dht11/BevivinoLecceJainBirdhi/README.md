# DHT11 Documentation

## Authors

* Maria Teresa Bevivino
* Michela Lecce
* Sejal Jain
* Prerna Birdhi

## Specifications:  
#### Global
- 4 ms Communication  
- 40 bits complete data (Most Significant Bits first)  


#### To start:   
##### MCU drive:  
1. GND (meaning 0) at least 18 ms  
2. VCC (meaning 1) between (20-40) μs

##### DHT drive:  
1. GND for 80 μs  
2. VCC for 80 μs  

#### To send data:
For every bit of data :  

  1. GND for 50 μs  
  2. VCC for 26-28 μs to send 0 OR VCC for 70 μs to send 1

### Inputs and Outputs  
#### Button:  


We use the push button to start to read for the sensor.  
But :   
  - After power up, the button should have no effect until 1 sec  
  - Use debouncing function to correct default of the button  

#### Switches:  


  - 1 switch to select the data to display : temperature or humidity (SW0). When the switch is set to 1, we read the humidity level, when it is 0, we read the temperature.  
  - 2 switches to select 4 bits out of the 16 bits (4 bits nibbles) of the data to display (SW1 and SW2).  

When SW1=0 and SW2=0, we display the 4 less significant bits of the data.  
When SW1=0 and SW2=1, we display the 5th to 8th less significant bits.  
When SW1=1 and SW2=0, we display the 5th to 8th most significant bits.  
When SW1=1 and SW2=1, we display the 4 most significant bits of the data.  

```
    SW1,SW2   SW1,SW2  SW1,SW2  SW1,SW2
     1   1     1  0     0  1     0  0
   +--------+--------+--------+--------+
   |  0101  |  0110  |  0001  |  1100  |  -> 16 bits to display
   +--------+--------+--------+--------+
```

  - 1 switch (SW3) to select what to display. When the switch is set to 0, we display the data, when it is 1, we put the LEDs in an "error/check state":   

```
      3      2      1      0    
   +------+------+------+------+
   |  PE  | SW0  |  B   |  CE  |
   +------+------+------+------+
```

PE (Protocol error): if this LED in on this means that there was an error in the protocol, for example the MCU is waiting for a bit of data that is not coming or the DTH is not doing what is expected.  
SW0: display the value of SW0 (when this bit is set, it means that the switch 0 is set).  
B (busy bit): indicates that the delay after the power up is not passed or that the sensor is currently sending data. When the bit is set,  we shouldn't try to read from the sensor.  
CE (Checksum error): if this bit is set, it means that the checksum sent and the one computed are different -> the data read from the sensor might be false.  

Remark: when the PE bit is set, we can use the other LED to display the kind of protocol error occurs but this may be not worthwhile and complicated.  

##### Overview

```
    SW0,SW1,SW2  
     1   1   1      1  1  0      1  0  1      1  0  0  |  0   1   1     0  1  0      0  0  1      0  0  0  |  not displayed
   +------------+------------+------------+------------+------------+------------+------------+------------+-----------------+
   |    1010    |    0110    |    0001    |    0100    |    0010    |    1110    |    0011    |    1100    |     01011001    |  -> 40 bits from the DHT11 sensor 
   +------------+------------+------------+------------+------------+------------+------------+------------+-----------------+
                      Humidity data                    |                   Temperature                     |     CHECK SUM

```

#### LEDs :  


We use the 4 LEDs to display 4 bits of data (the 4 bits chosen by the switches SW1 and SW2 or the specific states specified above).  


```
      11     10     01     00
   +------+------+------+------+
   |  L3  |  L2  |  L1  |  L0  |
   +------+------+------+------+
   
```

## Block diagram
The architecture of this controller is made mainly of a datapath and an FSM. Some components are put outside the dht11_ctrl wrapper, like the checksum, debouncer and the display component, but they are virtually part of the datapath as well.
Inside the datapath we have:
* counter
* checker
* global_checker
* checksum
* sampler
* shift register
* display
* debouncer

#### Datapath comprehensive diagram
![alt text][diagdp]

[diagdp]:  Img/datapath_Diagram.jpg  "Comprehensive datapath diagram"

### Counter

The counter is parametric with the frequency and the value neede to be vounted. It has a signal to make it start, one to acknowledge the finish, the synchronous negative reset and of course the clock.
What it actually counts is the time in us. In this implementation is needed to count the first 18 ms for which the controller should drive the line to communicate with the sensor.

### Sampler

This component measures the time it passes between the time it receives the start to the first edge it meets. To accomplish this two flip flops in cascade are instatiated, so that giving to them the line as input and xoring thei two outputs it is possible to see if there has been an edge.
The problem faced it was that there where not possible assumption to make on the timing since the sensor is very imprecise, so to avoid to see edges too early the sampler first counts 1us and then starts detecting edge. Every time interval in this system lasts way more than 1 us so this "deaf time" is enough to guarantee the soundness of the measure.

### Checker and Global Checker

The checker is the entity that checks if the value sampled by the sampler is acceptable or not. The confront is made in number of clock thicks measured since all the functioning is parametrized with the frequency. The global checker is the wrapper for all the checker instatiated.


### Shift Register

This component take as imput a single bit value from the FSM and stores it shifting it to the left. It gives the all data in parallel in output.

### Debouncer

The debouncer is already given and it is needed to avoid false starts when pressing the start button. 

### Checksum

This combinatorial component is used to check the correctenss of the received data. The last 8 bits of the transmitted data are the sum of the previously 32 sent, so to check that there are no transmission errors. If there is and error the component will signal it as output.

### Display

This component is completely combinatorial and it receives as input the data, the status bits and the value of the switches. In this way according to the switch it is possible to see the status and the value of the received data on the board's leds. The status bits represent if there is a protocol error, a checksum error or if the system is busy in the communication with the sensor. Data are visualized one nibble at time, and for each temperature and humidity data there are four nibble, two fo the decimal part and two for the integer one.

## FSM

The FSM performs the control through the processing. In particular it is necessary to respect the correctness of the protocol and the timing in the communication between the sensor and the 
controller. If the protocol is not respected then the communication will be interrupted, the protocol error signal will be risen and the system will wait for a new start or a reset. 
The FSM in particular comprehends also a counter because for the transmission it will wait to receive 40 bits before evolving in the DATA_READY state.

#### FSM diagram
![alt text][diagfsm]

[diagfsm]:  Img/FSM_Diagram.jpg  "fsm diagram"

## AXI

#### AXI controller block diagram
![alt text][diagblaxi]

[diagblaxi]:  Img/Diagram1.jpg  "block axi diagram"

## AXI FSM

#### AXI FSM diagram
![alt text][diagfsmaxi]

[diagfsmaxi]:  Img/Diagram2.jpg  "fsm axi diagram"

## AXI controller

On top of the controller made to communicate with the sensor stands another controller that cares about the communication with a master system with an AXI protocol.
The AXI protocol works in such a way that there is the master that in this case should be the PC and the slave, that is the controller. The protocol works in such a way that there are three channels:
* W: data
* AW: address
* B: control 
 

Each of these channels have its control signals, in particular there are the VALID and READY signals which are used by the master and the slave to perfom the handshake to let each other know that there are data in input and that these have been accepted. There is also the RESP signal that tells that there is a valid response in output. The FSM designed to perform this protocol considers two scenarios: the one in which the master wants to read and the one where it wants to write. The case in which the master wants to write always give an error in output, even if the address is valid, this is because there is no way the master can write something in the controller's memory. In the case it wants to read first is checked that the address is valid. Then data are put in output and the response from the master is waited.
This FSM could also be done in two separate FSM performing the read and the write, but since there are no perfomance requirement and the controller cannot handle the two request together a single FSM has been made, which anyway give the priority to the reading operation.

## Functional validation

Each of the component designed has been validated though a specific testbench. The whole system then has been validated through two different simulation environments, one for the stand alone verion and one for the AXI communication protocol, which are:
* [simulation/dht11_axi_sim.vhd](simulation/dht_axi_sim.vhd): a complete simulation environment for dht11_axi(rtl) where the protocol between the master and the slave is simulated.
* [simulation/dht11_ctrl_sim.vhd](simulation/dht11_ctrl_sim.vhd): a complete simulation environment for dht11_ctrl(rtl) with two generic parameters, the margin for protocol error detection and the clock frequency.

## Synthesis

Each of the two implementation, the stand alone and the AXI one have been synthesized correclty. In the reports it is possible to check if the synthesis was correct and the statistics concerning the area used and the timing. The files used to produce the synthesis are:
* [synthesis/dht11_axi_top.syn.tcl](synthesis/dht11_axi_top.syn.tcl) for the AXI version
* [synthesis/dht11_sa_top.syn.tcl](synthesis/dht11_sa_top.syn.tcl) for the stand alone one


Reports are collected in the directory [synthesis/Report](synthesis/Report), and are about the log file of the synthesis operation and two reports about the area occupation and the timing performances.
For what concerns the SA version it is possible to see that the occupation in term of logic slices is less than 2%. Logic slices are made up of two logic cells (that consists of a LUT, a FF and a connection with adjacent cells). No area for latch instantiation is used, so there is no latch inferred.
For the timing statistics it is possible to see that the slack on both the max and min delay paths is positive.
For the AXI version in useda bit more than the 2% of LUTs slices adn slack is positive also in this case.
After checking the correctness of these parameters the binary file to upload on the zybo board to check the functioning on the board. The uploaded file is [synthesis/boot.bin](synthesis/boot.bin).

## Experiments on the Zybo
After uploading the binary file on the board it was possible to check the operations on the boad. In this implementation with the SW3 on 1 it was possible to see the status register and check if the operations went on correctly.
Otherwise with SW3 to 0 data were displayed. In the experiments performed everything was working fine, there was no protocol error and the temperature recorded was 32° (actually a bit more than the one recorded for the environment, but that depends on the quality of the sensor).
