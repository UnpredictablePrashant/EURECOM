# General purpose
SHELL		:= bash
rootdir		:= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
heredir		:= $(realpath .)
BUILDDIR	?= /tmp/build-$(USER)
#hdlsrcs	:= $(wildcard $(rootdir)/*.vhd)
hdlsrcs		:= dht11_pkg.vhd 8to4mux.vhd checksum.vhd datamux.vhd debouncer.vhd fsm.vhd sipo.vhd syncdata.vhd timer.vhd dht11_ctrl.vhd dht11_sa.vhd dht11_ctrl_sim.vhd fsm_sim.vhd timer_sim.vhd datamux_tb.vhd 8to4mux_tb.vhd
HDLSRCS		:= $(patsubst $(rootdir)/%,%,$(hdlsrcs))
TAGSDIR		:= $(BUILDDIR)/tags
TAGS		:= $(addprefix $(TAGSDIR)/,$(HDLSRCS))

V		:= @
Q		:= --quiet

# Mentor Graphics Modelsim
CONFIGFILE	:= $(BUILDDIR)/modelsim.ini
LIBNAME		:= work
LIBDIR		:= $(BUILDDIR)/$(LIBNAME)
VLIB		:= vlib
VMAP		:= vmap
VCOM		:= vcom
VCOMFLAGS	:= -ignoredefaultbinding -nologo -quiet -2008
VSIM		:= vsim
VSIMFLAGS	:= -c -do 'run -all; quit'
VSIMIFLAGS	:= -voptargs="+acc" -do "add wave -r /*"
VIVADO		:= vivado
VIVADOFLAGS	:= -mode batch -notrace

# Messages
define HELP_message
make targets:
  make help             print this message (default goal)
  make F=foo.vhd com    compile foo.vhd
  make com              compile all VHDL source files
  make U=foo sim        simulate design unit foo (file foo.vhd), command line interface
  make U=foo simi       simulate design unit foo (file foo.vhd), graphical user interface
  make S=foo.tcl syn	synthesis the logic (file dht11_sa_top.syn.tcl)
  make boot		create boot image to burn to Zybo board (boot.bin)
  make all		Compile, Synthesis and Make boot image
  make clean            delete all automatically created files and directories
  --[AXI version]--
  make axi-com		compile all AXI files
  make axi-simi		start simulation GUI for AXI
  make axi-syn		synthesis logic for AXI
  make axi-boot		create boot image for AXI (boot-axi.bin)
  make axi-all		Compile, Synthesis and Make boot image
directories:
  hdl sources          $(rootdir)
  build directory      $(BUILDDIR)

customizable make variables:
  BUILDDIR             ($(BUILDDIR))
endef
export HELP_message

# Help
help:
	$(V)echo "$$HELP_message"

ifeq ($(heredir),$(rootdir))

# Compilation
ifeq ($(F),)

com: $(TAGS)

else

com: $(TAGSDIR)/$(F)

endif

$(TAGS): $(TAGSDIR)/%: % | $(CONFIGFILE) $(TAGSDIR) $(LIBDIR)
	$(V)$(MAKE) $(Q) -C $(TAGSDIR) -f $(rootdir)/Makefile $*

$(BUILDDIR):
	$(V)echo [MKDIR] $@ && \
	mkdir -p $@

$(TAGSDIR): | $(BUILDDIR)
	$(V)echo [MKDIR] $@ && \
	mkdir -p $@

$(LIBDIR): | $(BUILDDIR)
	$(V)echo '[VLIB] $(LIBNAME)' && \
	cd $(BUILDDIR) && \
	$(VLIB) $(LIBNAME)

$(CONFIGFILE): | $(BUILDDIR) $(LIBDIR)
	$(V)echo '[VMAP] $(LIBNAME) $(LIBNAME)' && \
	cd $(BUILDDIR) && \
	$(VMAP) $(LIBNAME) $(LIBNAME)

clean:
	$(V)echo '[RM] $(BUILDDIR)' && \
	rm -rf $(BUILDDIR)

# Simulation
ifeq ($(U),)

sim simi:
	$(V)echo "Please specify the design unit to simulate:" && \
	echo "make U=foo $@"

else

sim simi: | $(CONFIGFILE) $(TAGSDIR) $(LIBDIR)
	$(V)$(MAKE) $(Q) -C $(TAGSDIR) -f $(rootdir)/Makefile U=$(U) $@

endif

else ifeq ($(heredir),$(realpath $(TAGSDIR)))

-include $(rootdir)/dep.mk

$(HDLSRCS): %: $(rootdir)/%
	$(V)echo '[VCOM] $*' && \
	cd $(BUILDDIR) && \
	$(VCOM) $(VCOMFLAGS) $(rootdir)/$* && \
	touch $(TAGSDIR)/$*

sim simi: $(U).vhd

sim:
	$(V)echo "[VSIM] $(U)" && \
	cd $(BUILDDIR) && \
	$(VSIM) $(VSIMFLAGS) $(U)

simi:
	$(V)echo "[VSIM] $(U)" && \
	cd $(BUILDDIR) && \
	$(VSIM) $(VSIMIFLAGS) $(U)

endif

# Logic synthesis
ifeq ($(S),)
syn:
	$(V)echo "No TCL source file specified: default file will be used"
	$(V)echo "[VIVADO] dht11_sa_top.syn.tcl" && \
	cd $(BUILDDIR) && \
	$(VIVADO) $(VIVADOFLAGS) -source "$(heredir)/dht11_sa_top.syn.tcl -tclargs $(heredir)"
else
syn:
	$(V)echo "[VIVADO] $(S)" && \
	cp $(heredir)/*.vhd $(BUILDDIR) && \
	cd $(BUILDDIR) && \
	$(VIVADO) $(VIVADOFLAGS) -source "$(heredir)/$(S)"
endif

# Build boot image
boot:
	$(V)echo "[BOOTGEN] boot.bin" && \
	pushd $(BUILDDIR) > /dev/null && \
	bootgen -w -image $(heredir)/boot.bif -o $(heredir)/boot.bin && \
	popd >> /dev/null

# Make all
all: com syn boot

### AXI version only ###
r=$(heredir)
o=$(BUILDDIR)
p=$(BUILDDIR)/axi/syn

# Compile
axi-com: com
	$(V)echo "[VCOM] Compile AXI" && \
	cd $(o) && \
	vcom -ignoredefaultbinding -nologo -quiet -2008 $(r)/axi_pkg.vhd && \
	vcom -ignoredefaultbinding -nologo -quiet -2008 $(r)/dht11_pkg.vhd && \
	vcom -ignoredefaultbinding -nologo -quiet -2008 $(r)/dht11_ctrl.vhd && \
	vcom -ignoredefaultbinding -nologo -quiet -2008 $(r)/dht11_axi.vhd && \
	vcom -ignoredefaultbinding -nologo -quiet -2008 $(r)/dht11_axi_sim.vhd

axi-simi: axi-com
	$(V)echo "[VSIM] Simulate AXI" && \
	cd $(o) && \
	vsim $(VSIMIFLAGS) dht11_axi_sim

# Synthesis
axi-syn:
	$(V)echo "[VIVADO] Synthesis AXI" && \
	mkdir -p $(p) && \
	cd $(p) && \
	vivado -mode batch -source $(r)/dht11_axi_top.syn.tcl -notrace -tclargs $(r)

# Make boot image
axi-boot:
	$(V)echo "[BOOTGEN] boot.bin" && \
	pushd $(p) > /dev/null && \
	bootgen -w -image $(r)/boot.bif -o $(r)/axi-boot.bin && \
	popd >> /dev/null

axi-all: axi-com axi-syn axi-boot
