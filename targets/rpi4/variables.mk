# Target specific make variables to set
ALL_TARGET := $(BUILD)/rpi4.img
QNX_ARCH := aarch64
QNX_ARCHDIR := aarch64le

# What to put into the 'installation' archive
# These are all relative to the build's output directory
TARGET_INSTALL_FILES := rpi4.img
