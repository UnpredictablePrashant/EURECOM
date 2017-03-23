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
#include <des.h>
#include <km.h>
#include <pcc.h>

uint64_t pt;      /* Plain text. */
uint64_t *ct;      /* Array of cipher texts. */
double *t;      /* Array of timing measurements. */

/* A function to allocate cipher texts and timings arrays ct and t, read the
 * datafile and store its content in global variables pt, ct and t. */
void read_datafile(char *name, int n);

/* A function to brute-force attack with partial knowledge plus a pair of
 * plain text - cipher text as an oracle. Return 0 on failure, 1 on success. */
int brute_force(des_key_manager km, uint64_t pt, uint64_t ct);

int compareDoubles(const void *a, const void *b);

/* Prints the 48 rightmost bits of 64-bit integer x. */
void print_int64(uint64_t x)
{
  char b[49];
  b[0] = '\0';

  uint64_t z;
  for (z = 1ULL << 47; z > 0; z >>= 1)
  {
    strcat(b, ((x & z) == z) ? "1" : "0");
  }
  printf("%s\n", b);
}

int
main(int argc, char **argv)
{
  int num_experiments;
  uint64_t r16l16;    /* Output of last round, before final permutation. */
  uint64_t l16;      /* Right half of r16l16. */
  uint64_t sbo;      /* Output of SBoxes during last round. */
  int i;      /* Loop index. */
  des_key_manager km;    /* Key manager. */

  /************************************************************************/
  /* Before doing anything else, check the correctness of the DES library */
  /************************************************************************/
  if (!des_check())
  {
    ERROR(-1, "DES functional test failed");
  }

  /*************************************/
  /* Check arguments and read datafile */
  /*************************************/
  /* If invalid number of arguments (including program name), exit with error
   * message. */
  if (argc != 3)
  {
    ERROR(-1, "usage: ta <datafile> <nexp>\n");
  }
  /* Number of experiments to use is argument #2, convert it to integer and
   * store the result in variable n. */
  num_experiments = atoi(argv[2]);
  if (num_experiments < 1)      /* If invalid number of experiments. */
  {
    ERROR(-1,
        "number of experiments to use (<nexp>) shall be greater than 1 (%d)",
        num_experiments);
  }
  /* Data file is argument #1 */
  read_datafile(argv[1], num_experiments);

  /*****************************************************************************
   * Compute the Hamming weight of output of first (leftmost) SBox during last *
   * round, under the assumption that the last round key is all zeros.         *
   *****************************************************************************/
  uint64_t guess = 0ULL;
  uint64_t sbox_input;
  uint64_t r48;
  pcc_context ctx;
  int h_weight;
  int s;
  double pcc;
  double pcc_max;
  uint64_t sbox_guess;
  uint64_t mask_pattern = 0x0000000f;
  uint64_t key = 0ULL;
  double maxHeapTimes[64];
  int k;
  int j;
  for (s = 0; s < 8; s++) {
    pcc_max = 0;
    sbox_guess = 0;
    for (i = 0; i < 64; i++) {
      guess = ((uint64_t) i) << (s*6);
      ctx = pcc_init(1);
      for (j = 0; j < num_experiments; j++) {
        /* Undoes the final permutation on cipher text of j-th experiment. */
        r16l16 = des_ip(ct[j]);
        /* Extract right half (strange naming as in the DES standard). */
        l16 = des_right_half(r16l16);
        r48 = des_e(l16);
        sbox_input = r48 ^ guess;
        sbo = des_sboxes(sbox_input);  /* R15 = L16, K16 = 0 */
        /* Compute Hamming weight of output of first SBox (mask the others). */
        h_weight = hamming_weight(sbo & mask_pattern);
        pcc_insert_x(ctx, t[j]);
        pcc_insert_y(ctx, 0, h_weight);
      }
      pcc_consolidate(ctx);
      pcc = pcc_get_pcc(ctx, 0);
      pcc_free(ctx);
      maxHeapTimes[i] = pcc;

      if (pcc > pcc_max) {
        pcc_max = pcc;
        sbox_guess = guess;
      }
    }
    qsort(maxHeapTimes, 64, sizeof(double), compareDoubles);

    for (k = 0; k < 3; k++) {
      printf("Array index %d: %f\n", k, maxHeapTimes[k]);
    }
    printf("SBox round key: ");
    print_int64(sbox_guess);
    key |= sbox_guess;
    mask_pattern = mask_pattern << 4;
  }

  /*******************************************************************************
   * Try all the 256 secret keys given the final round key, using the known      *
   * plaintext as an oracle.                                                     *
   *******************************************************************************/
  km = des_km_init();    /* Initialize the key manager with no knowledge. */
  /* Tell the key manager that we 'know' the last round key (#16) is all zeros. */
  des_km_set_rk(km,    /* Key manager */
      16,    /* Round key number */
      1,    /* Force (we do not care about conflicts with pre-existing knowledge) */
      UINT64_C(0xffffffffffff),  /* We 'know' all the 48 bits of the round key */
      key
      );
  /* Brute force attack with the knowledge we have and a known
   * plain text - cipher text pair as an oracle. */
  if (!brute_force (km, pt, ct[0]))
  {
    printf("Too bad, wrong guess on round key.\n");
  }
  free(ct);      /* Deallocate cipher texts */
  free(t);      /* Deallocate timings */
  des_km_free(km);    /* Deallocate the key manager */
  return 0;      /* Exits with "everything went fine" status. */
}

int
compareDoubles(const void *a, const void *b)
{
  const double ai = *(const double*) a;
  const double bi = *(const double*) b;
  if (ai > bi) {
    return -1;
  } else if (ai == bi) {
    return 0;
  } else {
    return 1;
  }
}
/*
void min_heap_insert(double[] heap, double value)
{

}*/

void
read_datafile(char *name, int n)
{
  FILE *fp;      /* File descriptor for the data file. */
  int i;      /* Loop index */

  /* Open data file for reading, store file descriptor in variable fp. */
  fp = XFOPEN(name, "r");

  /* Read the first line and stores the value (plain text) in variable pt. If
   * read fails, exit with error message. */
  if (fscanf(fp, "%" PRIx64, &pt) != 1)
  {
    ERROR(-1, "cannot read plain text");
  }

  /* Allocates memory to store the cipher texts and timing measurements. Exit
   * with error message if memory allocation fails. */
  ct = XCALLOC(n, sizeof(uint64_t));
  t = XCALLOC(n, sizeof(double));

  /* Read the n experiments (cipher text and timing measurement). Store them in
   * the ct and t arrays. Exit with error message if read fails. */
  for (i = 0; i < n; i++)
  {
    if (fscanf(fp, "%" PRIx64 " %lf", &(ct[i]), &(t[i])) != 2)
    {
      ERROR(-1, "cannot read cipher text and/or timing measurement");
    }
  }
}

int
brute_force(des_key_manager km, uint64_t pt, uint64_t ct)
{
  uint64_t dummy, key, ks[16];

  des_km_init_for_unknown(km);  /* Initialize the iterator over unknown bits */
  do        /* Iterate over the 256 possible keys */
  {
    key = des_km_get_key(km, &dummy);  /* Get current key, ignore the mask */
    des_ks(ks, key);    /* Compute key schedule with current key */
    if (des_enc(ks, pt) == ct)  /* If we are lucky... cheers. */
    {
      printf("%016" PRIx64 "\n", key);
      return 1;    /* Stop iterating and return success indicator. */
    }
  }
  while (des_km_for_unknown(km));  /* Continue until we tried them all */
  return 0;      /* Return failure indicator. */
}
