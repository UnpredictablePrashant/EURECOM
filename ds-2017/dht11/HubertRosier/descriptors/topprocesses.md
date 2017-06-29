### <a name="checksum"></a> `CHECK_CHECKSUM`  
##### Description
This process computes the checksum and compares it to the value received in `data_40`.
If the two values are not the same, CE is set.
#### Signals and variables
##### Signals
| Name        | Type                             | Direction | Description                                          |
| :----       | :----                            | :----     | :----                                                |
| `data_40`   | `std_ulogic_vector(39 downto 0)` | in        | Holds the value of the 40 bits read from the dht11   |
| `CE`        | `std_ulogic`                     | out       | Signal set when there is a checksum error            |

##### Variables

| Name                | Type                           | Description                                        |
| :----               | :----                          | :----                                              |
| `computed_checksum` | `std_ulogic_vector(7 downto0)` | Contains the value of the computed checksum        |


```
             _ _ _ _ _
           |          |
data_40 -->| CHECKSUM |------> CE
           |_ _ _ _ _ |

```

---------

### <a name="printer"></a> `PRINTER`
#### Description
This process allows us to display 4 bits of chosen data on the 4 LEDs of the Zybo board.
We select the data with the switches (cf Specification). <-- TODO : LINK

#### Signals and variables
##### Signals

| Name        | Type                             | Direction | Description                                                                                          |
| :----       | :----                            | :----     | :----                                                                                                |
| `data_40`   | `std_ulogic_vector(39 downto 0)` | in        | Holds the value of the 40 bits read from the dht11                                                   |
| `SW0`       | `std_ulogic`                     | in        | When the switch0 is set, SW0 is set                                                                  |
| `SW1`       | `std_ulogic`                     | in        | When the switch1 is set, SW1 is set                                                                  |
| `SW2`       | `std_ulogic`                     | in        | When the switch2 is set, SW2 is set                                                                  |
| `SW3`       | `std_ulogic`                     | in        | When the switch3 is set, SW3 is set                                                                  |
| `CE`        | `std_ulogic`                     | in        | CE is set when there is a checksum error                                                             |
| `PE`        | `std_ulogic`                     | in        | PE is set when there is a protocol error                                                             |
| `Busy`      | `std_ulogic`                     | in        | Indicates that the delay after power on isn't finished, or that the sensor is currently reading data |
| `LED`       | `std_ulogic_vector(3 downto 0)`  | out       | Represent the LEDs used to display 4 bits of data                                                    |

##### Variables

| Name        | Type                            | Description                                                    |
| :----       | :----                           | :----                                                          |
| `switches`  | `std_ulogic_vector(2 downto 0)` | Holds the value of the switches SW0, SW1 and SW2 in one vector |

#### Block diagram
```
            _ _ _ _ _
           |         | 4 bits
    SW0 -->|         |--/--->  4 LEDS
    SW1 -->|         |
    SW2 -->| PRINTER |<----- data_40
    SW3 -->|         |
   Busy -->|         |
           |_ _ _ _ _|
             ^    ^
             |    |
            PE    CE
```


-----------------------
