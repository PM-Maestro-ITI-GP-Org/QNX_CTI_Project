# Target specific rules

$(BUILD)/qemu: $(TARGET_BASE_DEPS)
	echo "Building qemu ..."
	rm -rf $(BUILD)/qemu $(BUILD)/local $(BUILD)/output
	$(mkqnximage_prep)
	cd $(BUILD) && \
	BUILD=$(BUILD) BOOT=$(BOOT) SYSTEM=$(SYSTEM) ASSETS=$(ASSETS) SRC=$(SRC) APK=$(APK) \
	QNX_TARGET=$(QNX_TARGET) QNX_ARCHDIR=$(QNX_ARCHDIR) TIME_SERVERS=$(CTI_TIME_SERVERS) \
	MKQNXIMAGE_EXTRAS=$(PROJECT_DIR)/mkqnximage \
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && \
	$(PROJECT_DIR)/make_image.sh --config=$(TARGET_DIR)/mkqnximage.config --build --cpu=$(CTI_QEMU_CPU) --ram=$(CTI_QEMU_RAM)"
