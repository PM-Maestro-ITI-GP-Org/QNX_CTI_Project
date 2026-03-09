# Target specific rules to set

# Extract and patch the BSP
$(BUILD)/bsp: $(STAGE_QNX_SDP) | $(BUILD)
	rm -rf $@
	unzip -d $(BUILD)/bsp $$(ls $(STAGE_QNX_SDP)/bsp/BSP_raspberrypi-bcm2711-rpi4_* | tail -n 1)
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp clean"

# Build the bsp
$(BUILD)/built_bsp: $(BUILD)/bsp
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp prebuilt"
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp/src hinstall install"
	rm -f $(BUILD)/bsp/prebuilt/aarch64le/sbin/i2c-bcm2711
	cp $(BUILD)/bsp/install/aarch64le/sbin/i2c-bcm2711 $(BUILD)/bsp/prebuilt/aarch64le/sbin/i2c-bcm2711
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp all install"
	touch $@

# io-snd RPI4 drivers and config are in a zip package. Need to extract that package and copy
# the files to a location where mkqnximage will find them. I'm going to install them into the BSP's
# tree as a handy location.
IO_SND_RPI4_DRIVER_FILES = source_package_rpi4_snd/hardware/sndrv/mixer/wm8960/nto/aarch64/dll.le/sndrv-mixer-wm8960.so \
                           source_package_rpi4_snd/hardware/sndrv/ctrl/bcm2711_pcm/nto/aarch64/dll.le/sndrv-ctrl-bcm2711_pcm.so \
                           source_package_rpi4_snd/hardware/sndrv/ctrl/bcm2711_pwm/nto/aarch64/dll.le/sndrv-ctrl-bcm2711_pwm.so

$(BUILD)/source_package_rpi4_snd: $(STAGE_QNX_SDP)/sources/rpi4_snd-0.0.247.zip
	rm -rf $@
	cd $(BUILD) && unzip -DD $<

$(BUILD)/source_package_rpi4_snd/io_snd_rpi4.conf: $(BUILD)/source_package_rpi4_snd
$(BUILD)/bsp/install/etc/system/config/sound/io_snd_rpi4.conf: $(BUILD)/source_package_rpi4_snd/io_snd_rpi4.conf $(STAGE_QNX_SDP)/target/qnx/etc/system/config/sound/io_snd_usb.conf | $(BUILD)/built_bsp
	mkdir -p $(dir $(@))
	cp $< $@
	# Append the USB configuration. However I only want the [ctrl] section
	# (in other words, skip the [global] section)
	echo >> $@
	echo '####################' >> $@
	echo '# USB Audio device #' >> $@
	echo '####################' >> $@
	sed -n '/\[ctrl\]/{:a;p;n;/^[^[]/ba}' $(STAGE_QNX_SDP)/target/qnx/etc/system/config/sound/io_snd_usb.conf >> $@

$(BUILD)/rpi4.img: $(BUILD)/bsp/install/etc/system/config/sound/io_snd_rpi4.conf

# $1 = name of file to install to lib/dll
define INSTALL_RPI4_IO_SND_DRIVER
$(BUILD)/$(1): $(BUILD)/source_package_rpi4_snd
$(BUILD)/bsp/install/aarch64le/lib/dll/$(notdir $(1)): $(BUILD)/$(1) | $(BUILD)/built_bsp
	cp $$< $$@
$(BUILD)/rpi4.img: $(BUILD)/bsp/install/aarch64le/lib/dll/$(notdir $(1))
endef
$(foreach f,$(IO_SND_RPI4_DRIVER_FILES),$(eval $(call INSTALL_RPI4_IO_SND_DRIVER,$(f))))

# Build the image
$(BUILD)/rpi4.img: $(TARGET_BASE_DEPS) $(BUILD)/built_bsp boot
	echo "Building rpi4.img ..."
	rm -rf $(BUILD)/rpi4.img
	$(mkqnximage_prep)
	cd $(BUILD) && \
	BUILD=$(BUILD) BOOT=$(BOOT) SYSTEM=$(SYSTEM) BSP=$(BUILD)/bsp ASSETS=$(ASSETS) SRC=$(SRC) APK=$(APK) \
	QNX_TARGET=$(QNX_TARGET) QNX_ARCHDIR=$(QNX_ARCHDIR) TIME_SERVERS=$(CTI_TIME_SERVERS) \
	MKQNXIMAGE_EXTRAS=$(PROJECT_DIR)/mkqnximage \
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && \
	$(PROJECT_DIR)/make_image.sh --config=$(TARGET_DIR)/mkqnximage.config --copy=all"

