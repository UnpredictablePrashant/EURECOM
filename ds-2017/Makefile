.PHONY: all run clean elaborate test

CC=ghdl

TARGET=mac_tb
FILES=$(wildcard *.vhd)
OBJECT=$(patsubst %.vhd, %.tag, $(FILES))

STOP_TIME="500ns"

%.tag: %.vhd
		$(CC) -a $<
		touch $@

elaborate: $(OBJECT)
		@$(foreach f, $^, $(CC) -e $(basename $(f));)

run: elaborate
		@$(CC) -r $(TARGET) --stop-time=$(STOP_TIME)

clean:
		$(CC) --clean
		rm -f *.tag
