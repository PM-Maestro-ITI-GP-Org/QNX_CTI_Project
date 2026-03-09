# Target specific make variables to set
ALL_TARGET := $(BUILD)/qemu
QNX_ARCH := x86_64
QNX_ARCHDIR := x86_64

# These are meant to be user configurable at build time.
# Default values should match what mkqnximage uses as defaults.
CTI_QEMU_CPU ?= 2
CTI_QEMU_RAM ?= 1G

# What to put into the 'installation' archive
# These are all relative to the build's output directory
TARGET_INSTALL_FILES := local output
