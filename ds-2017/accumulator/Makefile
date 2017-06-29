# Directory where this Makefile resides
ROOTDIR		:= $(dir $(lastword $(MAKEFILE_LIST)))
rootdir		:= $(realpath $(ROOTDIR))

# Build directories
O		:= /tmp/build-$(USER)
OSIM		:= $(O)/simulation
OSYN		:= $(O)/synthesis

# Accumulators
ACCUMULATORS	:= $(patsubst %.vhd,%,$(wildcard *accumulator.vhd))

.PHONY: help all-sim clean

define HELP_message
Type:
	make help		Print this message
	make <foo>		Compile accumulator <foo>.vhd
	make all		Compile all accumulators
	make <foo>-sim		Simulate accumulator which model is in <foo>.vhd, no GUI
	make <foo>-sim-gui	Simulate accumulator which model is in <foo>.vhd, with GUI
	make all-sim		Simulate all accumulators, no GUI
	make <foo>-syn		Logic synthesis of accumulator which model is in <foo>.vhd
	make clean		Deletes all temporary files and directories

Note: everything is built in $(O), the source directory is not modified

endef
export HELP_message

help:
	@echo "$$HELP_message" && \
	echo "Available accumulators:" && \
	echo $(ACCUMULATORS) | sed -r 's/(\S*)/\t\1\n/g'

# Simulation with Mentor Graphics Modelsim

LIBDIR		:= .work.lib
VCONFIG		:= modelsim.ini
VLIB		:= vlib
VMAP		:= vmap
VCOM		:= vcom
VCOMFLAGS	:= -ignoredefaultbinding -nologo -quiet -2008
VSIM		:= vsim
VCLISIMFLAGS	:= -voptargs='+acc' -c -do 'run -all; quit'
VGUISIMFLAGS	:= -novopt -do 'add wave /*; run -all'
CLISIMULATIONS	:= $(patsubst %,%-sim,$(ACCUMULATORS))
GUISIMULATIONS	:= $(patsubst %,%-sim-gui,$(ACCUMULATORS))
COMPILETAGS	:= $(patsubst %,$(O)/.%.com,$(ACCUMULATORS))
CLISIMULATETAGS	:= $(patsubst %,$(O)/.%.sim,$(ACCUMULATORS))
TESTBENCH	:= mac_tb
NCYCLES		:= 1000000

.PHONY: $(ACCUMULATORS) $(CLISIMULATIONS) $(GUISIMULATIONS)

all: $(ACCUMULATORS)
all-sim: $(CLISIMULATIONS)

$(ACCUMULATORS): %: $(OSIM)/.%.com

$(OSIM)/.%.com: %.vhd | $(OSIM) $(OSIM)/$(LIBDIR) $(OSIM)/$(VCONFIG)
	@cd $(OSIM) && \
	echo "$(VCOM) $(VCOMFLAGS) $< $(TESTBENCH).vhd" && \
	$(VCOM) $(VCOMFLAGS) $(rootdir)/$< $(rootdir)/$(TESTBENCH).vhd && \
	touch $@

$(CLISIMULATIONS): %-sim: $(OSIM)/.%.sim

$(OSIM)/.%.sim: $(OSIM)/.%.com $(OSIM)/.$(TESTBENCH).com | $(OSIM) $(OSIM)/$(LIBDIR) $(OSIM)/$(VCONFIG)
	@cd $(OSIM) && \
	echo "$(VSIM) $(VCLISIMFLAGS) -Gncycles=$(NCYCLES) $(TESTBENCH)" && \
	$(VSIM) $(VCLISIMFLAGS) -Gncycles=$(NCYCLES) $(TESTBENCH) && \
	touch $@

$(GUISIMULATIONS): %-sim-gui: $(OSIM)/.%.com $(OSIM)/.$(TESTBENCH).com | $(OSIM) $(OSIM)/$(LIBDIR) $(OSIM)/$(VCONFIG)
	@cd $(OSIM) && \
	echo "$(VSIM) $(VGUISIMFLAGS) -Gncycles=$(NCYCLES) $(TESTBENCH)" && \
	$(VSIM) $(VGUISIMFLAGS) -Gncycles=$(NCYCLES) $(TESTBENCH)

$(OSIM):
	@mkdir -p $@

$(OSIM)/$(LIBDIR): | $(OSIM)
	@cd $(OSIM) && \
	echo "$(VLIB) $(LIBDIR)" && \
	$(VLIB) $(LIBDIR)

$(OSIM)/$(VCONFIG): | $(OSIM)
	@cd $(OSIM) && \
	echo "$(VMAP) work $(LIBDIR)" && \
	$(VMAP) work $(LIBDIR)

# Logic synthesis with Synopsys DC

SYN		:= dc_shell
CLISYNFLAGS	:= -x 'source $(rootdir)/syn.tcl'
CLISYNTHESES	:= $(patsubst %,%-syn,$(ACCUMULATORS))

.PHONY: $(CLISYNTHESES)

$(CLISYNTHESES): %-syn: $(OSYN)/.%.syn

$(OSYN)/.%.syn: %.vhd
	@if [ -d $(OSYN) ]; then \
		stamp=`date +'%s'` && \
		echo "$(OSYN) already exists. Renaming as $(OSYN).$$stamp." && \
		mv $(OSYN) $(OSYN).$$stamp; \
	fi && \
	mkdir -p $(OSYN) && \
	cd $(OSYN) && \
	DC_SOURCE_FILES=$(rootdir)/$< $(SYN) $(CLISYNFLAGS) && \
	echo "********************************************************************************" && \
	echo "***** Synthesis results stored in $(OSYN)" && \
	echo "********************************************************************************" && \
	touch $@

clean:
	rm -rf $(O)
