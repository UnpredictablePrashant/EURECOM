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

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <inttypes.h>
#include <utils.h>

/* The P permutation table, as in the standard. The first entry (16) is the
 * position of the first (leftmost) bit of the result in the input 32 bits word.
 * */
int p_table[32] = {
    16,  7, 20, 21,
    29, 12, 28, 17,
     1, 15, 23, 26,
     5, 18, 31, 10,
     2,  8, 24, 14,
    32, 27,  3,  9,
    19, 13, 30,  6,
    22, 11,  4, 25
};

/* Returns the value of a given bit (0 or 1) of a 32 bits word. Positions are
 * numbered as in the DES standard: 1 is the leftmost and 32 is the rightmost.
 * */
int get_bit(int position, uint64_t val);

/* Force a given bit of a 32 bits word to a given value. Positions are numbered
 * as in the DES standard: 1 is the leftmost and 32 is the rightmost. */
uint64_t force_bit(int position, int value, uint64_t val);

/* Applies the P permutation to a 32 bits word and returns the result as another
 * 32 bits word. */
uint64_t des_p_ta(uint64_t val)
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

/* Returns the value of a given bit (0 or 1) of a 32 bits word. Positions are
 * numbered as in the DES standard: 1 is the leftmost and 32 is the rightmost.
 * */
int get_bit(int position, uint64_t val)
{
    if (position < 1 || position > 32)
        ERROR (-1, "invalid bit position (%d)", position);
    val = val >> (32 - position);
    val = val & UINT64_C (1);
    return (int) (val);
}


/* Force a given bit of a 32 bits word to a given value. Positions are numbered
 * as in the DES standard: 1 is the leftmost and 32 is the rightmost. */
uint64_t force_bit(int position, int value, uint64_t val)
{
    if (position < 1 || position > 32)
        ERROR (-1, "invalid bit position (%d)", position);
    if (value != 0 && value != 1)
        ERROR (-1, "invalid bit value (%d)", value);
    uint64_t res, mask, new_value;
    new_value = ((uint64_t) value) << (32 - position);
    mask = UINT64_C (1) << (32 - position);
    res = (val & ~mask) | (new_value & mask); /* set bit to 0 */
    return res;
}
