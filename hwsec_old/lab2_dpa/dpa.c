/**********************************************************************************
Copyright Institut Telecom
Contributors: Renaud Pacalet (renaud.pacalet@telecom-paristech.fr)

This software is a computer program whose purpose is to experiment timing and
power attacks against crypto-processors.

This software is governed by the CeCILL license under French law and
abiding by the rules of distribution of free software.  You can  use,
modify and/ or redistribute the software under the terms of the CeCILL
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info".

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability.

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or
data to be ensured and,  more generally, to use and operate it in the
same conditions as regards security.

The fact that you are presently reading this means that you have had
knowledge of the CeCILL license and that you accept its terms. For more
information see the LICENCE-fr.txt or LICENSE-en.txt files.
**********************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <string.h>

#include <utils.h>
#include <traces.h>
#include <des.h>

/* The P permutation table, as in the standard. The first entry (16) is the
 * position of the first (leftmost) bit of the result in the input 32 bits word.
 * Used to convert target bit index into SBox index (just for printed summary
 * after attack completion). */
int p_table[32] = {
    16, 7, 20, 21,
    29, 12, 28, 17,
    1, 15, 23, 26,
    5, 18, 31, 10,
    2, 8, 24, 14,
    32, 27, 3, 9,
    19, 13, 30, 6,
    22, 11, 4, 25
};

tr_context ctx;                 /* Trace context (see traces.h) */
int target_bit;                 /* Index of target bit. */
int target_sbox;                /* Index of target SBox. */
int best_guess;                 /* Best guess */
int best_idx;                   /* Best argmax */
float best_max;                 /* Best max sample value */
float *dpa[64];                 /* 64 DPA traces */

/* A function to allocate cipher texts and power traces, read the
 * datafile and store its content in allocated context. */
void read_datafile(char *name, int n);

/* Compute the average power trace of the traces context ctx, print it in file
 * <prefix>.dat and print the corresponding gnuplot command in <prefix>.cmd. In
 * order to plot the average power trace, type: $ gnuplot -persist <prefix>.cmd
 * */
void average(char *prefix);

/* Decision function: takes a ciphertext and returns an array of 64 values for
 * an intermediate DES data, one per guess on a 6-bits subkey. In this example
 * the decision is the computed value of bit index <target_bit> of L15. Each of
 * the 64 decisions is thus 0 or 1.*/
void decision(uint64_t ct, int d[64]);

/* Apply P. Kocher's DPA algorithm based on decision function. Computes 64 DPA
 * traces dpa[0..63], best_guess (6-bits subkey corresponding to highest DPA
 * peak), best_idx (index of sample with maximum value in best DPA trace) and
 * best_max (value of sample with maximum value in best DPA trace). */
void dpa_attack(void);

int main(int argc, char **argv)
{
    int n;                        /* Number of experiments to use. */
    int g;                        /* Guess on a 6-bits subkey */

    /************************************************************************/
    /* Before doing anything else, check the correctness of the DES library */
    /************************************************************************/
    if (!des_check ()) {
        ERROR(-1, "DES functional test failed");
    }

    /*************************************/
    /* Check arguments and read datafile */
    /*************************************/
    /* If invalid number of arguments (including program name), exit with error
     * message. */
    if (argc != 4) {
        ERROR(-1, "usage: dpa <file> <n> <b>\n  <file>: name of the traces file in HWSec format\n\t(e.g. /datas/teaching/courses/HWSec/labs/data/HWSecTraces10000x00800.hws)\n  <n>: number of experiments to use\n  <b>: index of target bit in L15 (1 to 32, as in DES standard)\n");
    }
    /* Number of experiments to use is argument #2, convert it to integer and
     * store the result in variable n. */
    n = atoi(argv[2]);
    if (n < 1) {          /* If invalid number of experiments. */
        ERROR(-1, "invalid number of experiments: %d (shall be greater than 1)", n);
    }
    /* Target bit is argument #3, convert it to integer and store the result in
     * variable target_bit. */
    target_bit = atoi(argv[3]);
    if (target_bit < 1 || target_bit > 32) {     /* If invalid target bit index. */
        ERROR(-1, "invalid target bit index: %d (shall be between 1 and 32 included)", target_bit);
    }
    /* Compute index of corresponding SBox */
    target_sbox = (p_table[target_bit - 1] - 1) / 4 + 1;
    /* Read power traces and ciphertexts. Name of data file is argument #1. n is
     * the number of experiments to use. */
    read_datafile(argv[1], n);

    /*****************************************************************************
     * Compute and print average power trace. Store average trace in file
     * "average.dat" and gnuplot command in file "average.cmd". In order to plot
     * the average power trace, type: $ gnuplot -persist average.cmd
     *****************************************************************************/
    average("average");

    /***************************************************************
     * Attack target bit in L15=R14 with P. Kocher's DPA technique *
     ***************************************************************/
    dpa_attack();

    /*****************************************************************************
     * Print the 64 DPA traces in a data file named dpa.dat. Print corresponding
     * gnuplot commands in a command file named dpa.cmd. All DPA traces are
     * plotted in blue but the one corresponding to the best guess which is
     * plotted in red with the title "Trace X (0xY)" where X and Y are the decimal
     * and heaxdecimal forms of the 6 bits best guess.
     *****************************************************************************/
    /* Plot DPA traces in dpa.dat, gnuplot commands in dpa.cmd */
    tr_plot(ctx, "dpa", 64, best_guess, dpa);

    /*****************
     * Print summary *
     *****************/
    printf("Target bit: %d\n", target_bit);
    printf("Target SBox: %d\n", target_sbox);
    printf("Best guess: %d (0x%02x)\n", best_guess, best_guess);
    printf("Maximum of DPA trace: %e\n", best_max);
    printf("Index of maximum in DPA trace: %d\n", best_idx);
    printf("DPA traces stored in file 'dpa.dat'. In order to plot them, type:\n");
    printf("$ gnuplot -persist dpa.cmd\n");

    /*************************
     * Free allocated traces *
     *************************/
    for (g = 0; g < 64; g++) {     /* For all guesses for 6-bits subkey */
        tr_free_trace(ctx, dpa[g]);
    }
    tr_free(ctx);                /* Free traces context */
    return 0;                     /* Exits with "everything went fine" status. */
}

void read_datafile(char *name, int n)
{
    int tn;

    ctx = tr_init(name, n);
    tn = tr_number(ctx);
    if (tn != n) {
        tr_free(ctx);
        ERROR(-1, "Could not read %d experiments from traces file. Traces file contains %d experiments.", n, tn);
    }
}

void average(char *prefix)
{
    int i;                        /* Loop index */
    int n;                        /* Number of traces. */
    float *sum;                   /* Power trace for the sum */
    float *avg;                   /* Power trace for the average */

    n = tr_number(ctx);          /* Number of traces in context */
    sum = tr_new_trace(ctx);     /* Allocate a new power trace for the sum. */
    avg = tr_new_trace(ctx);     /* Allocate a new power trace for the average. */
    tr_init_trace(ctx, sum, 0.0);        /* Initialize sum trace to all zeros. */
    for (i = 0; i < n; i++) {     /* For all power traces */
        tr_acc(ctx, sum, tr_trace(ctx, i));     /* Accumulate trace #i to sum */
    }                           /* End for all power traces */
    /* Divide trace sum by number of traces and put result in trace avg */
    tr_scalar_div(ctx, avg, sum, (float) (n));
    tr_plot(ctx, prefix, 1, -1, &avg);
    printf("Average power trace stored in file '%s.dat'. In order to plot it, type:\n", prefix);
    printf("$ gnuplot -persist %s.cmd\n", prefix);
    tr_free_trace(ctx, sum);     /* Free sum trace */
    tr_free_trace(ctx, avg);     /* Free avg trace */
}

void decision(uint64_t ct, int d[64])
{
    int g;                        /* Guess */
    uint64_t r16l16;              /* R16|L16 (64 bits state register before final permutation) */
    uint64_t l16;                 /* L16 (as in DES standard) */
    uint64_t r16;                 /* R16 (as in DES standard) */
    uint64_t er15;                /* E(R15) = E(L16) */
    uint64_t l15;                 /* L15 (as in DES standard) */
    uint64_t rk;                  /* Value of last round key */

    r16l16 = des_ip(ct);         /* Compute R16|L16 */
    l16 = des_right_half(r16l16);        /* Extract right half */
    r16 = des_left_half(r16l16); /* Extract left half */
    er15 = des_e(l16);           /* Compute E(R15) = E(L16) */
    /* For all guesses (64). rk is a 48 bits last round key with all 6-bits
     * subkeys equal to current guess g (nice trick, isn't it?). */
    for (g = 0, rk = UINT64_C(0); g < 64; g++, rk += UINT64_C(0x041041041041)) {
        l15 = r16 ^ des_p(des_sboxes(er15 ^ rk));       /* Compute L15 */
        d[g] = (l15 >> (32 - target_bit)) & UINT64_C(1); /* Extract value of target bit */
    }                           /* End for guesses */
}

void dpa_attack(void)
{
    int i;                        /* Loop index */
    int n;                        /* Number of traces. */
    int g;                        /* Guess on a 6-bits subkey */
    int idx;                      /* Argmax (index of sample with maximum value in a trace) */
    int d[64];                    /* Decisions on the target bit */

    float *t;                     /* Power trace */
    float max;                    /* Max sample value in a trace */
    float *t0[64];                /* Power traces for the zero-sets (one per guess) */
    float *t1[64];                /* Power traces for the one-sets (one per guess) */

    int n0[64];                   /* Number of power traces in the zero-sets (one per guess) */
    int n1[64];                   /* Number of power traces in the one-sets (one per guess) */

    uint64_t ct;                  /* Ciphertext */

    for (g = 0; g < 64; g++) {    /* For all guesses for 6-bits subkey */
        dpa[g] = tr_new_trace(ctx);      /* Allocate a DPA trace */
        t0[g] = tr_new_trace(ctx);       /* Allocate a trace for zero-set */
        tr_init_trace(ctx, t0[g], 0.0);  /* Initialize trace to all zeros */
        n0[g] = 0;                /* Initialize trace count in zero-set to zero */
        t1[g] = tr_new_trace(ctx);       /* Allocate a trace for one-set */
        tr_init_trace(ctx, t1[g], 0.0);  /* Initialize trace to all zeros */
        n1[g] = 0;                /* Initialize trace count in one-set to zero */
    }                           /* End for all guesses */
    n = tr_number(ctx);          /* Number of traces in context */
    for (i = 0; i < n; i++) {     /* For all experiments */
        t = tr_trace(ctx, i);    /* Get power trace */
        ct = tr_ciphertext(ctx, i);      /* Get ciphertext */
        decision(ct, d);         /* Compute the 64 decisions */
        /* For all guesses (64) */
        for (g = 0; g < 64; g++) {
            if (d[g] == 0) {      /* If decision on target bit is zero */
                tr_acc(ctx, t0[g], t);   /* Accumulate power trace in zero-set */
                n0[g] += 1;       /* Increment traces count for zero-set */
            }
            else {                /* If decision on target bit is one */
                tr_acc(ctx, t1[g], t);   /* Accumulate power trace in one-set */
                n1[g] += 1;       /* Increment traces count for one-set */
            }
        }                       /* End for guesses */
    }                           /* End for experiments */
    best_guess = 0;               /* Initialize best guess */
    best_max = 0.0;               /* Initialize best maximum sample */
    best_idx = 0;                 /* Initialize best argmax (index of maximum sample) */
    for (g = 0; g < 64; g++) {    /* For all guesses for 6-bits subkey */
        tr_scalar_div(ctx, t0[g], t0[g], (float) (n0[g]));       /* Normalize zero-set */
        tr_scalar_div(ctx, t1[g], t1[g], (float) (n1[g]));       /* Normalize zero-set */
        tr_sub(ctx, dpa[g], t1[g], t0[g]);       /* Compute one-set minus zero-set */
        max = tr_max(ctx, dpa[g], &idx); /* Get max and argmax of DPA trace */
        if (max > best_max || g == 0) {   /* If better than current best max (or if first guess) */
            best_max = max;       /* Overwrite best max with new one */
            best_idx = idx;       /* Overwrite best argmax with new one */
            best_guess = g;       /* Overwrite best guess with new one */
        }
    }                           /* End for all guesses */
    /* Free allocated traces */
    for (g = 0; g < 64; g++) {    /* For all guesses for 6-bits subkey */
        tr_free_trace(ctx, t0[g]);
        tr_free_trace(ctx, t1[g]);
    }
}
