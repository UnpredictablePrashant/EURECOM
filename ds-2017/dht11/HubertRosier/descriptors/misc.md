### <a name="powerupdelay"></a> `POWERUP_DELAY`
#### Description
The goal of this process is to set the busy to 1 until the sensor is ready to send a message.


#### Signals and variables  
##### Signals  

| Name          | Type         | Direction | Description                                                              |
| :----         | :----        | :----     | :----                                                                    |
| `clk`         | `std_ulogic` | in        | Master clock. The design is synchronized on the rising edge of `clk`     |
| `count`       | `integer`    | in        | the number of us elapsed since the last counter reset                    |
| `busy_powerup`| `std_ulogic` | out       | tells if the sensor is ready (`0`) or not (`1`)                          |

#### Block diagram

```
            _ _ _ _ _ _
           |            |                                  
  count -->|  POWERUP_  |------> busy_powerup 
           |   DELAY    |                                                                            
           |_ _ _ _ _ _ |
                  ^                                                                                         |
                 clk
```
---------

### <a name="counter"></a> `COUNTER`
#### Description

This process is a simple counter, that allows us to count in micro-seconds, using the timer entity.
The signal `count` holds the number of us elapsed since the last reset.

#### Signals and variables
##### Signals

| Name                 | Type         | Direction | Description                                                              |
| :----                | :----        | :----     | :----                                                                    |
| `clk`                | `std_ulogic` | in        | Master clock. The design is synchronized on the rising edge of `clk`     |
| `s_reset_count_n`    | `std_ulogic` | in        | Synchronous active low reset                                             |
| `pulse`              | `std_ulogic` | in        | Asserted high for one clk CP every `timeout` us                          |
| `count`              | `std_ulogic` | out       | Signal that holds the number of us since the last reset of the counter   |

#### Block diagram

```
                     _ _ _ _ _
                    |         |
 s_reset_count_n -->|         |
                    | COUNTER |------> count
          pulse  -->|         |
                    |_ _ _ _ _|
                         ^
                         |
                        clk

```

---------

#### <a name="updatedata"</a> `UPDATE_DATA`
##### Description

Simple process that reset `do` when `sresetn` is unset and update the value of `do`
with the message read when `s_update_do` is set.

##### Signals and variables
##### Signals

| Name          | Type                              | Direction | Description                                                            |
| :----         | :----                             | :----     | :----                                                                  |
| `clk`         | `std_ulogic`                      | in        | Master clock. The design is synchronized on the rising edge of `clk`   |
| `global_reset`| `std_ulogic`                      | in        | reset all the processes                                                |
| `s_update_do` | `std_ulogic`                      | in        | starts the process `UPDATE_DATA` that will put the message read to `do`|
| `do_tmp`      | `std_ulogic_vector (39 downto 0)` | in        | this is the output of the 40bits register                              |
| `do`          | `std_ulogic_vector (39 downto 0)` | out       | holds the last data sent by the sensor                                 |

##### Block diagram

```
                    _ _ _ _ _
                   |         |
   global_reset -->|  UPDATE |
    s_update_do -->|         |------> do
         do_tmp -->|   DATA  |
                   |_ _ _ _ _|
                        ^
                        |
                       clk

```

