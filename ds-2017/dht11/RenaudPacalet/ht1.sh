#!/usr/bin/env sh

tmp=$(devmem 0x40000000)
h=$((tmp >> 24))
t=$(((tmp >> 8) & 0xff))
printf "H: %d%%\nT: %d°C\n" $h $t
exit 0
