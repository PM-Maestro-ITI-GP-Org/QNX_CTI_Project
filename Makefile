#
# Copyright (c) 2025, BlackBerry Limited. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PROJECT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: all install clean boot apk assets src force_sdp_update

# Include config file if it exists. Set a default location
# if one hasn't been explicitly given.
CTI_CONFIG_FILE ?= qnx/config.mk
-include $(CTI_CONFIG_FILE)

# Set defaults for configurable variables if they haven't been specified
# on the command line or via a config file.
CTI_QSC_URL ?= https://www.qnx.com/swcenter
CTI_TIME_SERVERS ?= 0.pool.ntp.org:1.pool.ntp.org

# Make sure QSC_CLT_PATH has been given an value and exists
ifeq ("${QSC_CLT_PATH}","")
  $(error QSC_CLT_PATH is not defined. Please set it to the qnxsoftwarecenter_clt binary))
else ifeq ($(wildcard $(QSC_CLT_PATH)),)
  $(error QSC_CLT_PATH '$(QSC_CLT_PATH)' is invalid. Please set it to the qnxsoftwarecenter_clt binary))
endif

# Figure out what targets are available, and make sure one of
# them has been specified. While I'm doing that generate the
# full path to the target's configuration directory.
AVAILABLE_TARGETS := $(filter-out %/README.md,$(wildcard targets/*))
AVAILABLE_TARGETS += $(filter-out %/README.md,$(wildcard qnx/targets/*))
TARGET_DIR := $(PROJECT_DIR)/$(filter %/$(TARGET),$(AVAILABLE_TARGETS))
AVAILABLE_TARGETS := $(notdir $(AVAILABLE_TARGETS))
ifeq ($(filter $(AVAILABLE_TARGETS),$(TARGET)),)
  $(error TARGET is not set or invalid. Available targets are: $(AVAILABLE_TARGETS))
endif

# Expands to a single newline character
define NEWLINE


endef

BUILD_NAME := $(TARGET)
BUILD := $(PROJECT_DIR)/build/$(BUILD_NAME)

BOOT=$(PROJECT_DIR)/boot/build/$(TARGET)
SYSTEM=$(PROJECT_DIR)/system
ASSETS=$(PROJECT_DIR)/assets
SRC=$(PROJECT_DIR)/src
APK=$(PROJECT_DIR)/apk/stage
BUILD_VERSION_FILE=$(BUILD)/cti_build_version.txt
STAGE_QNX_SDP=$(PROJECT_DIR)/qnx800

PACKAGES_LIST = ${PROJECT_DIR}/qsc_install_packages.list
TARGET_PACKAGES_LIST = $(wildcard $(TARGET_DIR)/qsc_install_packages.list)

# Include target specific variables.
include $(TARGET_DIR)/variables.mk

all: $(ALL_TARGET)

# Install just tars up required files
install:
	mkdir -p $(PROJECT_DIR)/install
	-rm -f $(PROJECT_DIR)/install/$(BUILD_NAME).tar.gz*
	@echo Archiving targets install files
	tar -czv -C $(PROJECT_DIR)/build $(addprefix $(BUILD_NAME)/,$(TARGET_INSTALL_FILES)) | \
		split --numeric-suffixes=0 -b 1000m - $(PROJECT_DIR)/install/$(BUILD_NAME).tar.gz.

$(BUILD)/qsc_install_packages.list : $(PACKAGES_LIST) $(TARGET_PACKAGES_LIST) | $(BUILD)
	cat $(PACKAGES_LIST) $(TARGET_PACKAGES_LIST) > $@

# Since the SDP install is shared between targets, and each target has its own
# customized set of packages, I need to make sure the current set of packages
# installed in the SDP is correct for the current target.
ifneq ($(wildcard $(STAGE_QNX_SDP)/cti_package_set),)
ifeq ($(filter $(TARGET),$(file < $(STAGE_QNX_SDP)/cti_package_set)),)
$(info Forcing SDP update due to TARGET change)
FORCE_SDP_UPDATE := force_sdp_update
endif
endif

# Figure out the profileId for this SDP installtion.
# ProfileId's should be unique per installation. If it changes, which usually
# means that the project directory has moved, a clean build is required to
# wipe out the existing SDP install. A new build can then be done to
SDP_PROFILE_ID := com.qnx.cti-$(shell stat -c '%d_%i' $(PROJECT_DIR))
# If there isn't an explicit profileId file in the SDP install, force it to update
# so one can be generated.
ifeq ($(wildcard $(STAGE_QNX_SDP)/cti_profile_id),)
FORCE_SDP_UPDATE := force_sdp_update
endif

$(STAGE_QNX_SDP): $(BUILD)/qsc_install_packages.list options_file $(FORCE_SDP_UPDATE)
	@if [ -d $(STAGE_QNX_SDP) ]; then \
	    if [ ! -f $(STAGE_QNX_SDP)/cti_profile_id ]; then \
	        echo "SDP profileId is missing. Removing existing SDP install..."; \
	        $(QSC_CLT_PATH) -profile com.qnx.cti -uninstallBaseline $(STAGE_QNX_SDP); \
	    elif [ "$$(cat $(STAGE_QNX_SDP)/cti_profile_id)" != "$(SDP_PROFILE_ID)" ]; then \
	        echo "SDP profileId has changed. Removing existing SDP install..."; \
	        $(QSC_CLT_PATH) -profile $$(cat $(STAGE_QNX_SDP)/cti_profile_id) -uninstallBaseline $(STAGE_QNX_SDP); \
	    fi; \
	fi
	$(QSC_CLT_PATH) -url $(CTI_QSC_URL) -mirrorBaseline qnx800 @options_file
	$(QSC_CLT_PATH) -url $(CTI_QSC_URL) -cleanInstall -setExperimentalEnabled=true \
		        -setPolicy=conservative \
		        -destination $(STAGE_QNX_SDP) \
			-importAndInstall $(BUILD)/qsc_install_packages.list \
			-profile $(SDP_PROFILE_ID) \
			$(CTI_QSC_EXTRA_OPTIONS) \
			@options_file
	echo -n $(TARGET) > $(STAGE_QNX_SDP)/cti_package_set
	echo -n $(SDP_PROFILE_ID) > $(STAGE_QNX_SDP)/cti_profile_id

$(BUILD):
	mkdir -p $(BUILD)

clean_qnx800:
	$(QSC_CLT_PATH) -uninstallBaseline $(STAGE_QNX_SDP)

subdirs:=$(subst /Makefile,,$(wildcard */[Mm]akefile))
clean:
	$(foreach dir,$(subdirs), $(MAKE) -C$(dir) clean $(NEWLINE) TARGET=$(TARGET))
	-$(MAKE) clean_qnx800
	-rm -rf $(BUILD)
	-rm -f $(PROJECT_DIR)/install/$(BUILD_NAME).tar.gz

boot:
	$(MAKE) -Cboot TARGET=$(TARGET)

assets:
	$(MAKE) -Cassets

apk:
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -Capk TARGET=$(TARGET)"

src:
	/bin/bash -c "set -a && source $(STAGE_QNX_SDP)/qnxsdp-env.sh && make -Csrc TARGET=$(TARGET)"

system/etc/ssl/certs/cacert.pem:
	mkdir -p system/etc/ssl/certs
	curl --show-error --fail --etag-save "$(PROJECT_DIR)/system/etc/ssl/certs/etag.txt" -o $@ "https://curl.se/ca/cacert.pem"
	echo "Roots certificate download succeeded."

# Deliberately done so that every build re-generates this file
build_version:
	mkdir -p $(dir $(BUILD_VERSION_FILE))
	rm -rf $(BUILD_VERSION_FILE)
	echo -n "`date -I`:" > $(BUILD_VERSION_FILE)
	git log -1 --pretty=format:"%h" >> $(BUILD_VERSION_FILE)
	if [ `git status --porcelain=1 --untracked-files=no | wc -l` -ne 0 ]; then echo -n '*' >> $(BUILD_VERSION_FILE); fi



# Figure out the locations where snippet files should
# be copied from to make the final set of snippets for
# a target. Locations are processed in order.
SNIPPET_LOCATIONS := $(PROJECT_DIR)/snippets
SNIPPET_LOCATIONS += $(PROJECT_DIR)/apk/stage/snippets
ifneq ($(wildcard $(TARGET_DIR)/snippets/.),)
SNIPPET_LOCATIONS += $(TARGET_DIR)/snippets
endif

# A macro that does a bunch of prep before running mkqnximage
# Mostly sets up the target's specific snippets in the right place
# Snippets are copied from several locations into a single destination.
# This means that snippets with the same name copied from later locations
# will override snippets from earlier locations.
define mkqnximage_prep =
mkdir -p $(BUILD)
mkdir -p $(BUILD)/local
mkdir -p $(BUILD)/local/snippets
rm -rf $(BUILD)/output
$(foreach l,$(SNIPPET_LOCATIONS),find $(l) -maxdepth 1 -type f -exec cp {} $(BUILD)/local/snippets \;;)
touch $(BUILD)/root_authorized_keys
endef

# The default dependencies valid for any target
TARGET_BASE_DEPS = build_version \
		   $(PROJECT_DIR)/qnx800 \
                   system/etc/ssl/certs/cacert.pem \
		   apk \
		   src \
		   assets

# Include target specific rules
include $(TARGET_DIR)/rules.mk
