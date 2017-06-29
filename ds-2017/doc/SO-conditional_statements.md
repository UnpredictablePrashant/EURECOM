# Authors
Fabio CARACCI
Prashant DEY
Chin-Te LIAO
------
# [Conditional statements](#Conditional_statements)
## [Sequential statements](#Sequential_statements)

* [If-Else](#If-Else)
* [Case-When](#Case-When)
* [For-Loop](#For-Loop)

## [Concurrent statements](#Concurrent_statements)

* [With-Select](#With-Select)
* [When-Else](#When-Else)
* [Generate](#Generate)

## [Sample Problems](#Sample-Problems)

## [References] (#References)

----

# <a name="Conditional_statements"></a>Conditional statements

Like the **programming** languages, VHDL (**Hardware Description** Language) also uses conditional statements. There are the three classical conditional statement *if-elsif-else* and something more *Case-When / With-Select / When-Else / ...*.

----

## <a name="Sequential_statements"></a>Sequential statements

**These statements need to be written inside processes.** It means that the lines of code are executed sequencially like the programming languages.

----

### <a name="If-Else"></a>If-Else

The `if` statement in VHDL is a sequential statement that conditionally executes other sequential statements, depending upon the value of some condition. An `if` statement may optionally contain an `else` part, executed if the condition is false. There are no special rules of brackets in VHDL, unlike in some programming languages, to incorporate more than one sequential statement inside an `if` statement: simply list the statements one after the other. It is important to note that we have to use `then` after the condition has been mentioned. To end the `if-else` statement we also need to mention `end if` which means that you are ending the preceeding conditional statement.

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

#### Elsif
Sometimes it is needed to use more than one condition. Like other programming language, VHDL also have "else if" conditional statement and is used as `elsif`. It is to be used after `if` statement and before the optional `else` statement.

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

#### Nested if-elsif-else
Nested `if-else-elsif` is also possible in VHDL. A proper `end if` statement is required to end each conditional statement and also to distinguish between the nested conditions.

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

---

### <a name="Case-When"></a>Case-When

Unlike nested conditional statement,`case-when` statement provides better readability with the same functionality when cases that different jobs will be assigned according to a variable.  
The usage of this statement has some similarities with the Switch-Case of C language but with some differences.  
For example, there's no need to use "break" statement in VHDL while is essential for C language in the end of every "case".
Without ` when others` (not recommended), all possible choices must be included.
A range or a selection may be specified as a choice: `when 1 to 3` or `when 1|3|6` but they must not overlap and they are not usable with vector types.

This statemnt is often used for the next state and output generation of a finite state machine.

This example create a decoder:
```vhdl
process(key)
begin
    case key is
        when "00" => out_signal <= "1000";
        when "01" => out_signal <= "0100";
        when "10" => out_signal <= "0010";
        when others => out_signal <= "0001";
    end case;
end process;
```

----

### <a name="For-Loop"></a>For-Loop
Some sequential statements may be required to be repeated for certain rounds. In such cases use `for loop` can be used. It is a sequential statement. The *variable* doesn't need to be declared before and the loop *range* must be a static range. 

```vhdl
for variable in bottom_limit to upper_limit loop  -- or downto
	<sequencial statements>
end loop;
```

-------------------------------------------------

## <a name="Concurrent_statements"></a>Concurrent statements

Very useful are the following VHDL statements that allow to implement a similar “Switch-Case” statement in C language.
These statements will act at the same way, but some differences are present.
They can be useful, for instance, while implementing a Multiplexer or assigning the states of a FSM. **Since the following statements are concurrent, they don't need to be written inside processes.**

----

### <a name="With-Select"></a>With-Select

This statement is functionally equivalent to the `Case` sequential statement. If you want to assign to a signal **out_signal** a value or another signal, depending on the current value of a selecting signal **selecting_signal**, you can simply use the `With-Select` statement.

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

For the last assigning is always better to use `when others`, like a `default` in C.

----

### <a name="When-Else"></a>When-Else

This statement is the same as the previous one, but is more general because a conditional assignments can be used instead of a definite value/signal. It is functionally equivalent to a series of `if --> elsif --> elsif --> ...`
```vhdl
out_signal <= "1000" when (sel1 = "00") else 
     "0100" when (sel1 = "11" and sel2 = "11") else 
     "0010" when (sel2 = "00") else 
     "0001";
```
**The order matter.**

----

### <a name="Generate"></a>Generate
Generate is an useful concurrent statement that usually helps to easily create arrays of components.  
The following example will create a register file composed by 32 registers.
```vhdl
ENTITY reg_file IS
	port(
		DIN: in std_ulogic_vector(31 downto 0);
		CLK, RESET: in std_ulogic;
		DOUT: out std_ulogic_vector(31 downto 0));
END reg_file;

ARCHITECTURE bhv OF reg_file IS
COMPONENT register
	port(
		D,CLK,RESET : in  std_ulogic;
		Q           : out std_ulogic);
END COMPONENT;

BEGIN
gen_reg_file:
	for i in 0 to 31 GENERATE -- 0 to 31 is a "range"
   	REG_X : REGISTER port map (DIN(i), CLK, RESET, DOUT(i));
	END GENERATE gen_reg_file;
END bhv;
```
Moreover conditions can be applied to the generate statements, such that the creation depends on them, however these conditions have to be **constants** and cannot change during the execution and so `generate` don't need to be written inside a process even if `if-else` or `case-when` statements are used.
```vhdl
gen_1:
	if <condition> generate
	-- declarations can be added here if needed
	-- a "begin" should be added if declarations are present
		<concurrent statements>
	elsif <condition> generate
		<concurrent statements>
	...
	else generate
		<concurrent statement>
end generate gen_1;

gen_2:
	case <expression> generate
	when <choice> =>
	 	<concurrent statements>
	when <choice> =>
	 	<concurrent statements>
	...
end generate gen_2;
```
Notes: each `generate` must have a label; `generate` statements can be nested.  

---

A `for...generate` statement is more like a pre-processor macro of the C language. It is evaluated during compilation (or synthesis) and the concurrent statements (processes, concurrent signal assignments, entity or component instantiations...) it encloses are instantiated the specified number of times. This kind of loop is actually unrolled at compilation (or synthesis), just like if you had written it yourself as unrolled.

So, why using them instead of unrolling the code? Because:
* It is more compact
* The number of iterations can be defined by generic parameters or an expression involving only constants and generic parameters
* It is thus much simpler to re-compile or re-synthesize with a different number of iterations

Example:

```vhdl
entity adder is
  generic(n: positive); -- number of bits
  port(
    a, b: in std_ulogic_vector(n-1 downto 0);
    ci: in std_ulogic; -- carry input
    s: out std_ulogic_vector(n-1 downto 0);
    co: out std_ulogic; -- carry output
  );
end entity adder;

architecture arc of adder is
  signal c: std_ulogic_vector(n downto 0); -- n+1 internal carries
begin
  g: for i in 0 to n-1 generate
    process(a(i), b(i), c(i)) -- a process, that is a concurrent satement
    begin
      s(i) <= a(i) xor b(i) xor c(i); -- sum bit
      c(i+1) <= (a(i) and b(i)) or (a(i) and c(i)) or (b(i) and c(i)); -- carry bit
    end process;
  end generate g;
  c(0) <= ci; -- carry input
  co <= c(n); -- carry output
end architecture arc;

```

and thus instanciating the adder:

```vhdl
...
architecture arc of enclosing is
...
  signal x, y, z: std_ulogic_vector(1 to 37);
  signal u, v: std_ulogic;
...
begin
...
  u0: entity work.adder(arc)
    generic map(n => 37) -- 37-bits adder
    port map(
      a => x,
      b => y,
      ci => u,
      s => z,
      co => v
    );
...

```
