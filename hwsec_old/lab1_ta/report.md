Lab 1 - Timing Attack on DES
============================

**Author**: Tarjei Husøy
**Computer used**: xxxxxxxxxxxxxx
**Secret key recovered**:  xxxxxxxx
**Minumum number of experiments used**: xxx


Introduction
------------

The initial `p_permutation` function is an excellent target for a TA due to a very strong correlation between the hamming weight of the value to be permuted and the time consumed. The correlation is due to a conditional on the bits of the input, causing 1s to go through an extra loop with 32 iterations of another conditional check and a variable assignment. 

An attacker can from this correlation build a timing model where a high hamming weight input will have an execution time far greater than that of a low hamming weight input, in the extreme case comparing all 1s input to all 0s input.


Preparations
------------

To understand a lot of the operations done both in the DES functions, the attack and with blinding, I needed a small helper function to print the bits of a given 64-bit integer. This helped me understand the masking operations performed during the attack, and help debugging. Since I've never worked on the bit level of variables before, printing a lot of the temporary values helped me understand what was going on in the original source, and what was happening as I worked on the source.


The attack
----------

Steps taken to complete the attack followed more or less this order:

* Wrapped all the logic in a loop to run it for all S-boxes.
* Added a masking pattern to compute hamming weights only for the given s-box
* Added PCC context to handle the hamming weights encountered
* Collect the maximum PCC correlation encountered for each S-box
* When the S-box is completed, accumulate the s-box guess with the rest of the key

This completes the attack, and allows retrieval of the secret key in 2075 guesses on the shared file.

I didn't allocate much time to improving this any further, but my strategy for pushing this number downwards would be to not only evaluate the best match from the PCC, but keep a min-heap of N elements when iterating over the results to collect the N best ranked guesses, and from those results build a tree with fanout N and height 8 of all possible keys, and then start traversing the three depth-first to see where we have a match. It should be possible to use the self-correcting property of the guesses to abort branches as soon as they don't yield good results any more, but I haven't tried to actually implement it. 

The benefit of this approach is that it's an embassignly parallell task, and if compiled with threads I could spawn threads for each branch, and thus utilize as much of the juice in your multi-core setup as possible. Maybe next time. You will see some early attempts at this in the source code, where instead of the min-heap I just collected all the results in an array, sort it after all the runs, and print the top 3. Was easier place the begin since C didn't have any stdlib heap functions, AFAIK, but it did have array sorting capabilities. Didn't get much further than this though.


Fixing the permutation function
-------------------------------

The crucial point in fixing the `p_permutation`\ function is removing any branching dependent on either input or the secret key. My final implementation looks like this:

```c
uint64_t des_p_ta (uint64_t val)
{
    uint64_t res = 0;
    int i, target_value, target_position;
    for (i = 1; i <= 32; i++) { /* for bit in the result*/
        target_position = p_table[i-1];
        target_value = get_bit(target_position, val);
        res = force_bit(i, target_value, res);
    }
    return res;
}
```

There are no conditionals in my implementation, all lookups are constant-time array index lookups, and I've been unable to break anything encrypted with this implementation for a large number of experiments (>100 000).

If we want to be totally certain there's no timing vulnerabilities in this implementation, we can compile and optimize the code, and deassamble the resulting object with `objdump` to see if there's any conditional jumps in the assembly. Removing the bounds checking for `force_bit` and `get_bit` there should be only a single jump in the object, because of the 1-32 bit loop. This doesn't depend on the key or the input, so this is okay. So how does our optimized assembly look like?

```assembly
Disassembly of section .text:

0000000000000000 <des_p_ta>:
   0:   53                      push   %rbx
   1:   41 b8 00 00 00 00       mov    $0x0,%r8d
   7:   ba 1f 00 00 00          mov    $0x1f,%edx
   c:   31 c0                   xor    %eax,%eax
   e:   bb 20 00 00 00          mov    $0x20,%ebx
  13:   41 bb 01 00 00 00       mov    $0x1,%r11d
  19:   0f 1f 80 00 00 00 00    nopl   0x0(%rax)
  20:   89 d9                   mov    %ebx,%ecx
  22:   41 2b 08                sub    (%r8),%ecx
  25:   49 89 fa                mov    %rdi,%r10
  28:   4d 89 d9                mov    %r11,%r9
  2b:   49 83 c0 04             add    $0x4,%r8
  2f:   49 d3 ea                shr    %cl,%r10
  32:   89 d1                   mov    %edx,%ecx
  34:   83 ea 01                sub    $0x1,%edx
  37:   49 d3 e1                shl    %cl,%r9
  3a:   4c 89 ce                mov    %r9,%rsi
  3d:   48 f7 d6                not    %rsi
  40:   48 21 c6                and    %rax,%rsi
  43:   4c 89 d0                mov    %r10,%rax
  46:   83 e0 01                and    $0x1,%eax
  49:   48 d3 e0                shl    %cl,%rax
  4c:   4c 21 c8                and    %r9,%rax
  4f:   48 09 f0                or     %rsi,%rax
  52:   83 fa ff                cmp    $0xffffffff,%edx
  55:   75 c9                   jne    20 <des_p_ta+0x20>
  57:   5b                      pop    %rbx
  58:   c3                      retq
  59:   0f 1f 80 00 00 00 00    nopl   0x0(%rax)

0000000000000060 <get_bit>:
  60:   b9 20 00 00 00          mov    $0x20,%ecx
  65:   29 f9                   sub    %edi,%ecx
  67:   48 d3 ee                shr    %cl,%rsi
  6a:   83 e6 01                and    $0x1,%esi
  6d:   89 f0                   mov    %esi,%eax
  6f:   c3                      retq

0000000000000070 <force_bit>:
  70:   b9 20 00 00 00          mov    $0x20,%ecx
  75:   48 63 c6                movslq %esi,%rax
  78:   29 f9                   sub    %edi,%ecx
  7a:   bf 01 00 00 00          mov    $0x1,%edi
  7f:   48 d3 e7                shl    %cl,%rdi
  82:   48 d3 e0                shl    %cl,%rax
  85:   48 21 f8                and    %rdi,%rax
  88:   48 f7 d7                not    %rdi
  8b:   48 21 d7                and    %rdx,%rdi
  8e:   48 09 f8                or     %rdi,%rax
  91:   c3                      retq
```

You can see here that there is only one jump in the entire object, which is because of the loop. We can then conclude that the implementation seems good for now. What we don't know is whether the CPU is leaking any information through channels outside our control, such as cache misses (unlikely), EMR (likely) and acoustics (likely), but that's outside the scope of this lab, I believe.
