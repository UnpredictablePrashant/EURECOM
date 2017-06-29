# Timing attack against a DES software implementation

## Important remarks

In the following instructions you are asked to type some commands. These commands are preceded by a `$` sign representing the prompt of the current shell. It is not a part of the command, do not type it.

**Notations**: they are the same as in the [DES standard](http://soc.eurecom.fr/HWSec/labs/doc/des.pdf). If you do not remember what `K16` or `C0D0` is, please have a look at the DES standard.

**Programming languages**: the lab is available in two versions: C language and Python language. Select the language your are most comfortable with. It is not a programming lab, so if you encounter pure programming issues, do not waste time and ask for help.

## Initial setup

### Generate a SSH key pair

If you do not have one already, generate a SSH key pair (note: if you do not know how to use an SSH agent and do not want to learn this now, leave the *passphrase* empty) and pass it to your SSH agent:

```bash
$ mkdir -p ~/.ssh
$ ssh-keygen -f ~/.ssh/gitlab
$ ssh-add ~/.ssh/gitlab
```

From now on, the SSH agent will use your SSH key to authenticate you when the Gitlab server will request your credentials.

### Activate your Gitlab account 

If it is not activated already, visit [https://gitlab.eurecom.fr/](https://gitlab.eurecom.fr/) sign in with your LDAP credentials, and copy-paste your public key (it is in `~/.ssh/gitlab.pub`) in the **Profile Settings / SSH Keys** section of your Gitlab account.

### Request access to the hwsec-2017 project

Visit the project's main page ([Hardware Security course, 2017](https://gitlab.eurecom.fr/renaud.pacalet/hwsec-2017)), sign-in if you are not already, and click on the **Request Access** button. I will then receive an e-mail, declare you as a project member and you will be allowed to pull the git repository and to push your contributions. **Wait until you receive the confirmation e-mail before continuing**.

### Clone the git repository:

Once you received the e-mail that confirms that you are now a project member, clone the git repository:

```bash
$ cd some/where
$ git clone git@gitlab.eurecom.fr:renaud.pacalet/hwsec-2017.git
$ cd hwsec-2017
$ ls
```

The only files that you are asked to modify during the lab are:
* `id.mk`: a form that you will first edit and fill with your first and last names, your e-mail address and your preferred programming language.
* `ta.c`: a C source file that you will use as a starting point for your own attack if you chose the C language.
* `ta.py`: a python source file that you will use as a starting point for your own attack if you chose the python language.
* `p.c`: a C source file that defines the P permutation and that you will edit to fix the flaw (no python version, sorry).

### Create your personal branch

In order to separate your work from that of others, you will work in your own personal branch. Name it with your Gitlab identifier:
```bash
$ git checkout -b <gitlab-id>
```

Example:

```bash
$ git checkout -b pacalet
```

You are ready to start contributing.

### Fill the form

Edit the  `id.mk` form and fill it. Add-commit-push your first contribution:

```bash
$ git add id.mk
$ git commit -m 'My first commit'
$ git push --set-upstream origin <gitlab-id>
```
where `<gitlab-id>` is the name of your branch (and also your Gitlab identifier). Note: git remembers that you push in the remote `<gitlab-id>` branch, so, the next time you will push, just type:
```bash
$ git push
```

## General description

In this lab, you will try to exploit a flaw in a DES software implementation which computation time depends on the input messages and on the secret key: its P permutation was implemented by a not-too-smart software designer who did not know anything about timing attacks (and not much about programming). The pseudo-code of his implementation of the P permutation is the following:

```
// Permutation table. Input bit #16 is output bit #1 and
// input bit #25 is output  bit #32.
p_table = {16,  7, 20, 21,
           29, 12, 28, 17,
            1, 15, 23, 26,
            5, 18, 31, 10,
            2,  8, 24, 14,
           32, 27,  3,  9,
           19, 13, 30,  6,
           22, 11,  4, 25};

p_permutation(val) {
  res = 0;                    // Initialize the result to all zeros
  for i in 1 to 32 {          // For all input bits #i (32 of them)
    if get_bit(i, val) == 1   // If input bit #i is set
      for j in 1 to 32        // For all 32 output bits #j (32 of them)
	if p_table[j] == i    // If output bits #j is input bit #i
          k = j;              // Remember output bit index
        endif
      endfor                  // output bit #k is now input bit #i
      set_bit(k, res);        // Set bit #k of result
    endif
  endfor
  return res;                 // Return result
}
```

Do you understand why, apart from being very inefficient, this implementation is a nice target for a timing attack? What model of the computation time could be used by an attacker?

## Some useful material

* [The DES standard](http://soc.eurecom.fr/HWSec/labs/doc/des.pdf)
* [Timing Attacks on Implementations of Diffie-Hellman, RSA, DSS, and Other Systems (Paul Kocher, CRYPTO'96)](http://www.cryptography.com/resources/whitepapers/TimingAttacks.pdf)
* [The introduction lecture](http://soc.eurecom.fr/HWSec/lectures/introduction/main.pdf)
* [The lecture on side channel attacks](http://soc.eurecom.fr/HWSec/lectures/side_channels/main.pdf)
* For the C language version:
    * [A collection of useful declarations and functions dedicated to the DES processing, Pearson correlation coefficients, management of partial knowledge of a secret key, etc.](http://soc.eurecom.fr/HWSec/labs/doc/ta/C/html/files.html)
* For the python language version:
    * [The **des** library, dedicated to the Data Encryption Standard (DES)](http://soc.eurecom.fr/HWSec/labs/doc/ta/python/html/des.html)
    * [The **km** library, to manage the partial knowledge about a DES (Data Encryption Standard) secret key](http://soc.eurecom.fr/HWSec/labs/doc/ta/python/html/km.html)
    * [The **pcc** library, dedicated to the computation of Pearson Correlation Coefficients (PCC)](http://soc.eurecom.fr/HWSec/labs/doc/ta/python/html/pcc.html)

## Directions

### Build all executables

```bash
$ make all
```

### Acquisition phase

Run the acquisition phase:
```bash
$ ./ta_acquisition 100000
100%
Experiments stored in: ta.dat
Secret key stored in:  ta.key
Last round key (hex):
0x79629dac3cf0
``` 

This will randomly draw a 64-bits DES secret key, 100000 random 64-bits plaintexts and encipher them using the flawed DES software implementation. Each enciphering will also be accurately timed using the hardware timer of your computer. Be patient, the more acquisitions you request, the longer it takes. Two files will be generated:
* `ta.key` containing the 64-bits DES secret key, its 56-bits version (without the parity bits), the 16 corresponding 48-bits round keys and, for each round key, the eight 6-bits subkeys.
* `ta.dat` containing the 100000 ciphertexts and timing measurements.

Note: the 48-bits last round key is printed on the standard output (`stdout`), all other printed messages are sent to the standard error (`stderr`).

Note: you can also chose the secret key with:
```bash
$ ./ta_acquisition 100000 0x0123456789abcdef
```
where `0x0123456789abcdef` is the 64-bits DES secret key you want to use, in hexadecimal form.

Note: if for any reason you cannot run `ta_acquisition`, use the provided files in the `data` sub-directory, instead:
```bash
$ cp data/ta.dat data/ta.key .
```

Let us look at the few first lines of `ta.dat`:
```bash
$ head -4 ta.dat
0x743bf72164b3b7bc 80017.500000
0x454ef17782801ac6 76999.000000
0x9800a7b2214293ed 74463.900000
0x1814764423289ec1 78772.500000
```

Each line is an acquisition corresponding to one of the 100000 random plaintexts. The first field on the line is the 64 bits ciphertext returned by the DES engine, in hexadecimal form. With the numbering convention of the DES standard, the leftmost character (7 in the first acquisition of the above example) corresponds to bits 1 to 4. The following one (4) corresponds to bits 5 to 8 and so on until the rightmost (c) which corresponds to bits 61 to 64. In the first acquisition of the above example, bit number 6 is set while bit number 8 is unset. Please check your understanding of this numbering convention, if you miss something here, there are very little chances that you complete the lab. The second field is the timing measurement.

### Attack phase

The acquisition phase is over, it is now time to design a timing attack. You will start from a provided example application (`ta.c` or `ta.py`). It shows how to use the most useful features of the provided software libraries. It is not a real timing attack. In particular, it assumes that the last round key is all zeros, instead of trying to recover it from the acquisitions. Your job is thus to turn it into a real timing attack and to retrieve the real last round key. Of course, you can easily find out the last round key by looking at the `ta.key` file, but in real life things would not be so easy. So, use the `ta.key` file for verification only. The provided example application:
* takes two arguments: the name of a data file and a number of acquisitions to use,
* reads the specified number of acquisitions from the data file,
* stores the ciphertexts and timing measurements in two arrays named `ct` and `t`,
* assumes that the last round key is all zeros, and based on this, computes the 4-bits output of SBox #1 in the last round of the last acquisition, and prints its Hamming weight,
* computes and prints the average value of the timing measurements of all acquisitions and, finally,
* prints the assumed all zeros last round key in hexadecimal format.

All printed messages are sent to the standard error (`stderr`). The only message that is sent to the standard output (`stdout`) is the 48-bits last round key, in hexadecimal form.

The example application uses some functions of the provided software libraries. To see the complete list of what these libraries offer, look at their documentation (see the [Some useful material](#some-useful-material) section). To compile and run the example application (C version) just type:
```bash
$ make ta
$ ./ta ta.dat 100000
Hamming weight: 1
Average timing: 169490.540600
Last round key (hex):
0x000000000000
```

For the python version there is no need to compile, so simply run:
```bash
$ ./ta.py ta.dat 100000
Hamming weight: 1
Average timing: 169490.540600
Last round key (hex):
0x000000000000
```

As is, this application is not very useful, so, edit the `ta.c` (`ta.py`) file and transform it into a successful timing attack to recover the 48-bits last round key.

**Important note**: whatever the changes you make, preserve the following interface specification:
* your program takes exactly two arguments: the name of a data file and a number of acquisitions to use,
* your program can output anything on the standard error (`stderr`), use it freely for debugging,
* your program must output only the last round key on the standard output (`stdout`), in hexadecimal format, with 12 hexits and preceded by `0x`, the hexadecimal format indicator (e.g. `0x0123456789ab`).

Imagine what your attack will be, what model of timing you will be using, what statistical tools and the general algorithm. Code your ideas and as soon as you think it should work, save the file and run again:
```bash
$ make ta
$ ./ta ta.dat 100000
Hamming weight: 1
Average timing: 169490.540600
Last round key (hex):
0xaa0acc89efd5
```
or:
```bash
$ ./ta.py ta.dat 100000
Hamming weight: 1
Average timing: 169490.540600
Last round key (hex):
0xaa0acc89efd5
```
If the printed 48-bits last round key is the same as in `ta.key`, your attack works.

Once you successfully recovered the last round key, try to reduce the number of acquisitions you are using: the less acquisitions the more practical your attack.

### Countermeasure

Last, but not least, design a countermeasure by rewriting the P permutation function. The `p.c` file contains the C (no python version, sorry) source code of the function. Edit it and fix the flaw, save the file and compile the new version of the `ta_acquisition` application:
```bash
$ make all
```
This will compile the acquisition application with your implementation of the P permutation function. Fix the errors if any.

Run again the acquisition phase:
```bash
$ ./ta_acquisition 100000
```
This will first check the functional correctness of the modified DES implementation. Fix the errors if any until the application runs fine and creates a new `ta.dat` file containing 100000 acquisitions. Try to attack with these acquisitions and see whether it still works... Do you think your implementation is really protected against timing attacks? Explain. If you are not convinced that your implementation is 100% safe, explain what we could do to improve it.

### Checking your work

When you will be satisfied with your work, check its compliance with the interface specifications:
```bash
$ make ccheck # C version
$ make pycheck # python version
```

### Submitting your work

If the check passes, add-commit-push:
```bash
$ git add id.mk ta.c p.c # C version
$ git add id.mk ta.py p.c # python version
$ git commit -m 'My timing attack'
$ git pull; git push # Accept the merge if you are asked to
```

The daemon responsible for the automatic evaluation will be started just before the lab and will run until the written exam. It will send you an e-mail with your results for each new version you submit. Be patient, if the server is heavily loaded, its response time can be significant.

<!--
## The hall of fame

**Important note**: it is just a game and has no impact at all on the course final evaluation.

If your attack succeeds you qualify for the <a href="hf_ta.php">Hall of Fame</a>. And if your attack succeeds with fewer acquisitions than anybody else you will be sacred Queen or King of the Timing Attack. In order to participate the competition, your attack application must adhere to some interface specifications. Please visit the <a href="hf_ta.php">Hall of Fame</a> page for the details.

Good luck.
-->
