**DHT11 controller project**

### Authors

* Axel Strubel ([axel.strubel@eurecom.fr](mailto:axel.strubel@eurecom.fr))

* Cedric Osornio ([cedric.osornio@eurecom.fr](mailto:cedric.osornio@eurecom.fr))

* Fernando Mendoza ([luis-fernando.mendoza-miranda@eurecom.fr](mailto:luis-fernando.mendoza-miranda@eurecom.fr))

### **Summary**

### **About all components**

### **The sensor DHT11**

	 	 	 	

This DFRobot DHT11 Temperature & Humidity Sensor features a temperature & humidity sensor complex with a calibrated digital signal output. By using the exclusive digital-signal-acquisition technique and temperature & humidity sensing technology, it ensures high reliability and excellent long-term stability. This sensor includes a resistive-type humidity measurement component and an NTC temperature measurement component, and connects to a high- performance 8-bit microcontroller, offering excellent quality, fast response, anti-interference ability and cost-effectiveness.

![image alt text](image_0.jpg)

Ref. [http://www.esp8266learning.com/wp-content/uploads/2016/03/dht11-breakout.jpg](http://www.esp8266learning.com/wp-content/uploads/2016/03/dht11-breakout.jpg)

Each DHT11 element is strictly calibrated in the laboratory that is extremely accurate on humidity calibration. The calibration coefficients are stored as programmes in the OTP memory, which are used by the sensor’s internal signal detecting process. The single-wire serial interface makes system integration quick and easy. Its small size, low power consumption and up-to-20 meter signal transmission making it the best choice for various applications, including those most demanding ones. The component is 4-pin single row pin package. It is convenient to connect and special packages can be provided according to users’ request.

### **The Shift Register**

The Shift Register is another type of sequential logic circuit that can be used for the storage or the transfer of data in the form of binary numbers. This sequential device loads the data present on its inputs and then moves or "shifts" it to its output once every clock cycle, hence the name Shift Register.

![image alt text](image_1.gif)

Ref. [http://www.electronics-tutorials.ws/sequential/seq15a.gif](http://www.electronics-tutorials.ws/sequential/seq15a.gif)

### **Data Selector**

Data selector/multiplexer A logic circuit that may be considered as a single-pole multi way switch whose output is determined by the position of the switch wiper (see diagram). The wiper position is controlled by a select signal, normally digital, that indicates which of the inputs is to be connected to the output. In this way a number of channels of data may be placed sequentially on a time-shared output bus under the control of the select signal, a process known as time-division multiplexing. Inputs to and outputs from a multiplexer may be in digital or analog form. See also decoder/demultiplexer.

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


### **Debouncer**

### The basic idea is to sample the switch signal at a regular interval and filter out any glitches. There are a couple of approaches to achieving this listed below. Both approaches assume a switch circuit like that shown in the explanation of switch bounce: a simple push switch with a pull-up resistor.

### ![image alt text](image_2.png)

Ref. [https://i.stack.imgur.com/FY9Cs.png](https://i.stack.imgur.com/FY9Cs.png)

### **Finite State Machine**

A finite-state machine (FSM) or finite-state automaton (FSA, plural: automata), finite automaton, or simply a state machine, is a mathematical model of computation. It is an abstract machine that can be in exactly one of a finite number of states at any given time.

![image alt text](image_3.gif)

### **Edge Detector or Syncronizer**

An arbiter helps order signals in asynchronous circuits. There are also electronic digital circuits called synchronizers that attempt to perform arbitration in one clock cycle. Synchronizers, unlike arbiters, are prone to failure.

![image alt text](image_4.png)

Ref. [https://asicdigitaldesign.files.wordpress.com/2007/05/synchro1a.png](https://asicdigitaldesign.files.wordpress.com/2007/05/synchro1a.png)

### **Checksum**

The purpose of detecting errors which may have been introduced during its transmission

![image alt text](image_5.jpg)

Ref. [http://www.embeddedlinux.org.cn/linux_net/0596002556/images/understandlni_1813.jpg](http://www.embeddedlinux.org.cn/linux_net/0596002556/images/understandlni_1813.jpg)

### **Multiplexor**

Is a device that selects one of several analog or digital input signals and forwards the selected input into a single line.

![image alt text](image_6.png)

Ref. [https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Multiplexer2.png/300px-Multiplexer2.png](https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Multiplexer2.png/300px-Multiplexer2.png)

### **Block diagram**

### **DHT11 Stand alone version**![image alt text](image_7.png)

Ref. Own

### **Finite-state Machine (FSM) diagram:**

## ![image alt text](image_8.png)

Ref. Own

### **State Diagram**

![image alt text](image_9.png)

### Ref. own

### **Technical details**

### **DHT11 Controller**

### Timer

* Functional: A timer which counts upwards from zero for measuring elapsed time in microseconds to track time in the FSM controller.

* Entity name: timer

* Generic parameters:

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Description</td>
  </tr>
  <tr>
    <td>freq</td>
    <td>positive range 1 to 1000</td>
    <td>Master clock frequency in MHz (also clock periods per micro-second)</td>
  </tr>
</table>


* I/O Ports:

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Direction</td>
    <td>Description</td>
  </tr>
  <tr>
    <td>timeout</td>
    <td>positive in range 1 to 1500000</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>clk</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Master clock. The design is synchronized on the rising edge of clk.</td>
  </tr>
  <tr>
    <td>fsm_reset</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Synchronous, active low reset.</td>
  </tr>
  <tr>
    <td>sresetn</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>timer_rst is used to reset the count, by setting this bit to 1 the counter returns to zero.</td>
  </tr>
  <tr>
    <td>pulse</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
</table>


#### **FSM Controller**

* Functional:

* Entity name: fsm

* I/O Ports:

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
    <td></td>
  </tr>
  <tr>
    <td>beg</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>sresetn</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>dsensor</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>pulse</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>data_drv</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
  <tr>
    <td>fsm_reset</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
  <tr>
    <td>pe</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
  <tr>
    <td>busy</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
  <tr>
    <td>timeout</td>
    <td>positive</td>
    <td>out</td>
    <td></td>
  </tr>
  <tr>
    <td>shift</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
  <tr>
    <td>dsi</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
</table>


### **Shift Register**

* Functional: A shift (left) register that transforms a 1-bit serial input signal from FSM Controller to a 40-bit output data.

* Entity name: shiftregister

* I/O Ports:

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
    <td>dsi</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Serial input from FSM Controller.</td>
  </tr>
  <tr>
    <td>dth</td>
    <td>std_ulogic_vector(39 downto 8)</td>
    <td>out</td>
    <td>32-bit output value of the SIPO shift register.</td>
  </tr>
  <tr>
    <td>do</td>
    <td>std_ulogic_vector(39 downto 0)</td>
    <td>out</td>
    <td></td>
  </tr>
  <tr>
    <td>sr_chk</td>
    <td>std_ulogic_vector(7 downto 0)</td>
    <td>out</td>
    <td></td>
  </tr>
</table>


### **Edge Detector**

* Functional: Synchronize data and detect edges

* Entity name: edge_detector

* I/O Ports: 

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
    <td>data_in</td>
    <td>std_logic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>sresetn</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Synchronous, active low reset.</td>
  </tr>
  <tr>
    <td>dsensor</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
</table>


### **Checksum Block**

* Functional: Synchronize data and detect edges

* Entity name: edge_detector

* I/O Ports:

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Direction</td>
    <td>Description</td>
  </tr>
  <tr>
    <td>dth</td>
    <td>std_ulogic_vector(39 downto 0)</td>
    <td>in</td>
    <td>40-bit complete data. do(7 downto 0) are the checksum bits.</td>
  </tr>
  <tr>
    <td>sr_chk</td>
    <td>std_ulogic_vector(7 downto 0)</td>
    <td>in</td>
    <td>CE (Checksum error): if this bit is set, it means that there is a checksum error.</td>
  </tr>
  <tr>
    <td>ce</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td></td>
  </tr>
</table>


### **Multiplexor 2 to 1 **

* Functional: Synchronize data and detect edges

* Entity name: edge_detector

* I/O Ports:

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Direction</td>
    <td>Description</td>
  </tr>
  <tr>
    <td>dsel</td>
    <td>std_ulogic_vector (3 downto 0)</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>derr</td>
    <td>std_ulogic_vector(3 downto 0)</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>dshow</td>
    <td>std_ulogic_vector</td>
    <td>out</td>
    <td></td>
  </tr>
</table>


### **Debouncer**

* Functional:

* Entity name: debouncer

* Generic:

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
    <td>srstn</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>Synchronous, active low reset.</td>
  </tr>
</table>


* I/O ports:

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
    <td>clock</td>
  </tr>
  <tr>
    <td> srstn</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>synchronous active low reset</td>
  </tr>
  <tr>
    <td>d</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td>input bouncing signal</td>
  </tr>
  <tr>
    <td>q</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td>output synchronized and debounced signal</td>
  </tr>
  <tr>
    <td>r</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td>rising edge detector</td>
  </tr>
  <tr>
    <td>f</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td>falling edge detector</td>
  </tr>
  <tr>
    <td>a</td>
    <td>std_ulogic</td>
    <td>out</td>
    <td>any edge detector</td>
  </tr>
</table>


### **Selector**

* Functional:

* Entity name: selector

* Generic:

##        

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Direction</td>
    <td>Description</td>
  </tr>
  <tr>
    <td>sw0</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>sw1</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>sw2</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>dth</td>
    <td>std_ulogic_vector (31 downto 0)</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>dsel</td>
    <td>std_ulogic_vector(3 downto 0)</td>
    <td>out</td>
    <td></td>
  </tr>
</table>


### **Error Block**

* Functional:

* Entity name: errblock

* Generic:

<table>
  <tr>
    <td>Name</td>
    <td>Type</td>
    <td>Direction</td>
    <td>Description</td>
  </tr>
  <tr>
    <td>ce</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>sw0</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>pe</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>busy</td>
    <td>std_ulogic</td>
    <td>in</td>
    <td></td>
  </tr>
  <tr>
    <td>derr</td>
    <td>std_ulogic_vector(3 downto 0)</td>
    <td>out</td>
    <td></td>
  </tr>
</table>


## **Functional validation**

## $ make com$ make U**=**<module> simi

## Then we combine them together (instantiate from DHT11 Controller) and confirm the overall behavior.

## $ make com$ make U**=**dht11_ctrl simi

## **Synthesis**

### **Interfaces configuration**

## 

### **Start synthesis:**

### **Building boot image**

## **Experiments on the Zybo**

