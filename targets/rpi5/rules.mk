# Target specific rules to set

# Extract the BSP
$(BUILD)/bsp: $(STAGE_QNX_SDP) | $(BUILD)
	rm -rf $@
	unzip -d $(BUILD)/bsp $$(ls $(STAGE_QNX_SDP)/bsp/BSP_raspberrypi-bcm2712-rpi5_* | tail -n 1)
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp/src clean"
	cd $(BUILD)/bsp && patch -p1 < $(PROJECT_DIR)/targets/rpi5/msix-rp1-rework.patch

# Build the bsp
$(BUILD)/built_bsp: $(BUILD)/bsp
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp prebuilt"
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp/src hinstall install"
	rm -f $(BUILD)/bsp/prebuilt/aarch64le/sbin/devb-sdmmc-bcm2712
	cp $(BUILD)/bsp/install/aarch64le/sbin/devb-sdmmc-bcm2712 $(BUILD)/bsp/prebuilt/aarch64le/sbin/devb-sdmmc-bcm2712
	rm -f $(BUILD)/bsp/prebuilt/aarch64le/bin/msix-rp1
	cp $(BUILD)/bsp/src/hardware/support/bcm2712/msix-rp1/aarch64/le/msix-rp1 $(BUILD)/bsp/prebuilt/aarch64le/bin/msix-rp1
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -C$(BUILD)/bsp all install"
	touch $@

# Build the image
$(BUILD)/rpi5.img: $(TARGET_BASE_DEPS) $(BUILD)/built_bsp boot
	echo "Building rpi5.img ..."
	rm -rf $(BUILD)/rpi5.img
	$(mkqnximage_prep)
	cd $(BUILD) && \
	BUILD=$(BUILD) BOOT=$(BOOT) SYSTEM=$(SYSTEM) BSP=$(BUILD)/bsp ASSETS=$(ASSETS) SRC=$(SRC) APK=$(APK) \
	QNX_TARGET=$(QNX_TARGET) QNX_ARCHDIR=$(QNX_ARCHDIR) TIME_SERVERS=$(CTI_TIME_SERVERS) \
	MKQNXIMAGE_EXTRAS=$(PROJECT_DIR)/mkqnximage \
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && \
	$(PROJECT_DIR)/make_image.sh --config=$(TARGET_DIR)/mkqnximage.config --copy=all"
