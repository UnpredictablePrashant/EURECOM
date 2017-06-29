
### <a name="shiftregister"></a> `Shift_reg`

#### Description

This entity is used to store the last message sent by the sensor.
It is a 40bits shift register. When the signal `shift` is set the process will shift all the bits stored to the register
to their left and put in the most right register the value of the signal `di`.  

The value of the 40 bits is also send out of the entity via the signal `do`.  
We can reset the values of the register with the signal `sresetn` which is a synchronous active low reset.

#### Signals and variables
##### Signals

| Name      | Type                             | Direction | Description                                                              |
| :----     | :----                            | :----     | :----                                                                    |
| `clk`     | `std_ulogic`                     | in        | Master clock. The design is synchronized on the rising edge of `clk`     |
| `shift`   | `std_ulogic`                     | in        | when set, shift the value of all the registers to the register of their right and insert in the left most one the value of `di` |
| `di`      | `std_ulogic`                     | in        | holds the value to store to the left most register when `shift` is set |
| `sresetn` | `std_ulogic`                     | in        | *Synchronous*, active low reset of the registers |
| `do`      | `std_ulogic_vector(39 downto 0)` | out       | contains the value of the 40 registers to output them |

##### Variables

| Name  | Type                              | Description                            |
| :---- | :----                             | :----                                  |
| `reg` | `std_ulogic_vector(39 downto 0)`  | contains the value of the 40 registers |

#### Block diagram

```
                _ _ _ _ _
               |         |
      shift -->|         |----->  do
         di -->|   SR    |
    sresetn -->|         |
               |_ _ _ _ _|
                    ^
                    |
                   clk
```

---------

### <a name="timer"></a> `Timer`
#### Description

This entity is used to transform the clock period into time (us).
The first counter `counter1` is counting the clock periods, and assert the signal `tick` when it has reached one micro second.
The second one is counting the micro seconds, and assert the signal `pulse` when it has reached `timeout` micro seconds.

#### Signals and variables  

##### Generic values  
| Name                 | Type                          | Description                                             |
| :----                | :----                         | :----                                                   |
| `freq`               | `positive range 1 to 1000`    | Master clock frequency in MHz (also clk period per us)  |
| `timeout`            | `positive range 1 ro 1000000` | Number of us between 2 output pulses                    |


##### Signals  
| Name                 | Type         | Direction | Description                                                              |
| :----                | :----        | :----     | :----                                                                    |
| `clk`                | `std_ulogic` | in        | Master clock. The design is synchronized on the rising edge of `clk`     |
| `sresetn`            | `std_ulogic` | in        | Synchronous active low reset                                             |
| `pulse`              | `std_ulogic` | out       | Asserted high for one clk CP every `timeout` us                          |

##### Variables  
| Name        | Type                          | Description                                                                    |
| :----       | :----                         | :----                                                                          |
| `counter1`  | natural range 0 to `freq`-1   |  Holds the value of the 1st counter : from `freq`-1 to 0 each clk period       |
| `counter2`  | integer range 0 to `timeout`-1|  Holds the value of the 2nd counter : from `timeout`-1 to 0 each `tick` period |
| `tick`      | `std_ulogic`                  |  Asserted high during one clk CP every us                                      |

#### Block diagram

```
               _ _ _ _ _
              |         |
   sresetn -->|  TIMER  |------> pulse
              |_ _ _ _ _|
                   ^
                   |
                  clk
```

---------
