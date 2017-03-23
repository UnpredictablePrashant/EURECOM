# Conditional Statements

Like the **programming** languages, VHDL (**Hardware Description** Language) also uses conditional statements. There are the three classical conditional statement **if-elsif-else** and something more **With-Select / When-Else / Case-When**.

## If - Else
The *if* statement in VHDL is a sequential statement that conditionally executes other sequential statements, depending upon the value of some condition. An *if* statement may optionally contain an *else* part, executed if the condition is false.  
There are no special rules of brackets in VHDL, unlike in some programming languages, to incorporate more than one sequential statement inside an *if* statement: simply list the statements one after the other.  
It is important to note that we have to use *then* after the condition has been mentioned. To end the *if-else* statement we also need to mention *end if* which means that you are ending the preceeding conditional statement.

Pseudo code:
```vhdl
process(...)
begin
    if condition then
        sequential statements
    else
        sequential statements
    end if;
end process;
```

The equality of a condition is checked using "=".  
For example:
```vhdl
process(flag, a, b)
begin
    if flag="1" then
        out<=a+b;
    else
        out<=a;
    end if;
end process;
```

----------------
## Elsif
Sometimes it is needed to use more than one condition. Like other programming language, VHDL also have "else if" conditional statement and is used as *elsif*. It is to be used after *if* statement and before the optional *else* statement.

Pseudo Code:
```vhdl
if condition_1 then
    sequential statements
elsif condition_2 then
    sequential statements
else
    sequential statements
end if;
```

For example:
```vhdl
process(flag1, flag2, a,b)
begin
    if flag1="1" then
        out<=a+b;
    elsif flag1="0" and flag2="1" then
        out<=b;
else
        out<=a;
    end if;
end process;
```
------------------------------------------

## Nested if-elsif-else
Nested *if-else-elsif* is also possible in VHDL. A proper *end if* statement is required to end each conditional statement and also to distinguish between the nested conditions.

Pseudo Code:
```vhdl
if condition_1 then
    sequential statements
    if sub_cond1 then
        sequential statements
    elsif sub_cond2 then
        sequential statements
    else
        sequential statements
    end if;
elsif condition_2 then
    sequential statements
else
    sequential statements
end if;
```

For example:
```vhdl
process(flag1, flag2, a,b)
begin
    if flag1="1" then
        if flag2="0" then
            out<=a+b;
        end if;
    elsif flag1="0" and flag2="1" then
        out<=b;
else
        out<=a;
    end if;
end process;

```

-------------------------------------------------

## With-Select / When-Else / Case-When

Very useful are the following VHDL statements that allow to implement a similar “Switch-Case” statement in C language.
These statements will act at the same way, but some differences are present.
They can be useful, for instance, while implementing a Multiplexer or assigning the states of a FSM.

### With-Select

If you want to assign to a signal **out_signal** a value or another signal, depending on the current value of a selecting signal **selecting_signal**, you can simply use the *With / Select* statement.

For example to create a decoder:
```vhdl
with selecting_signal select out_signal <=
    "1000" when "00",
    "0100" when "01",
    "0010" when "10",
    "0001" when others;
```
This code means:  
when **selecting_signal** is equal to "00", then assign "1000" to **out_signal**;  
when **selecting_signal** is equal to "01", then assign "0100" to **out_signal**;  
...


Instad, to create a multiplexer the following code can be used:
```vhdl
with selection_signal select out_signal <=
    in1_signal when "00",
    in2_signal when "01",
    in3_signal when "10",
    in4_signal when others;
```

For the last assigning is always better to use *when others*, like a *default* in C.

**This statement don't need to be written inside a process.**

### When-Else

This statement is the same as the previous one, but is more general because you can use a conditional assignments instead of definite value/signal. It's like a series of *if --> elsif --> elsif --> ...*
```vhdl
out_signal <= "1000" when (sel1 = "00") else 
     "0100" when (sel1 = "11" and sel2 = "11") else 
     "0010" when (sel2 = "00") else 
     "0001";
```
**This statement don't need to be written inside a process but THE ORDER MATTER!!!**

### Case-When

This statement is very similar to the *"Switch-Case"* of C laguage.
```vhdl
process(sel)
begin
    case sel is
        when "00" => out_signal <= "1000";
        when "01" => out_signal <= "0100";
        when "10" => out_signal <= "0010";
        when others => out_signal <= "0001";
    end case;
end process;
```
