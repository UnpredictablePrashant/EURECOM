CC		= gcc
CFLAGS		= -Wall -ansi -c -O3
INCLUDES	= -I./include
LD		= gcc
LDFLAGS		=
LIBS		=

SRCS	= $(wildcard src/*.c)
OBJS	= $(patsubst %.c,%.o,$(SRCS))
EXECS	= dpa

.PHONY: help all clean ultraclean

all: $(EXECS)

help:
	@echo "Type:"
	@echo "<make> or <make help> to get this help message"
	@echo "<make all> to compile the dpa executable"
	@echo "<make clean> to clean up temp files and byproducts"

dpa: dpa.o $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS) -lm

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) $< -o $@

clean:
	rm -f $(OBJS) $(EXECS) dpa.o dpa.cmd dpa.dat average.cmd average.dat

