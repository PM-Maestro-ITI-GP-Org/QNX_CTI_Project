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

.PHONY: all clean
all:

# Files that are available locally (checked in or downloaded by some other
# part of the build).
# Should be of the form:
#   srcFile[:dest]
# Where
#   srcFile is the absolute/relative path from the directory of this Makefile
#           to the srcFile to copy.
#   dest is an optional name to use for the destination file. If not specified
#        then the destination file will have the same name as the srcFile.
LOCAL_FILES =
# Files that come in a tarball and so needs to be extracted
REMOTE_TARBALLS =
# Files that come from a tarball should be of the form
# tarball:file[:dest]
# Where
#   file is the path to the file in the tarball
#   dest is relative to the target's boot build dir
# If dest isn't specified the file will be copied without
# renaming to the target's boot build dir
TARBALL_FILES =
# Files that come from the linux kernel
# Not currently used but kept around for a bit just in case
REMOTE_LINUX_FW_FILES =

# Add firmware as required by different targets
ifneq ($(filter $(TARGET),rpi4 rpi5),)
    RPI_FW_RELEASE = 1.20250430
    RPI_FW_NON_FREE_RELEASE = pios/1%20240709-2_bpo12+1+rpt4
    REMOTE_TARBALLS += https://github.com/raspberrypi/firmware/archive/refs/tags/$(RPI_FW_RELEASE).tar.gz \
                       https://github.com/RPi-Distro/firmware-nonfree/archive/refs/tags/$(RPI_FW_NON_FREE_RELEASE).tar.gz
    LOCAL_FILES += wpa_supplicant.conf wpa_supplicant.conf.verbose
endif
ifneq ($(filter $(TARGET),rpi4),)
    TARBALL_FILES += $(RPI_FW_NON_FREE_RELEASE).tar.gz:debian/config/brcm80211/brcm/brcmfmac43455-sdio.raspberrypi,4-model-b.clm_blob:cyfmac43455-sdio.clm_blob
    TARBALL_FILES += $(RPI_FW_NON_FREE_RELEASE).tar.gz:debian/config/brcm80211/brcm/brcmfmac43455-sdio.raspberrypi,4-model-b.txt:brcmfmac43455-sdio.raspberrypi,4-model-b.txt
    # For some reason, this version of the FW doesn't work. I have an open question out to the WIFI guys as to why.
    # For now, use the one from the package via LOCAL_FILES
    #TARBALL_FILES += $(RPI_FW_NON_FREE_RELEASE).tar.gz:debian/config/brcm80211/cypress/cyfmac43455-sdio-standard.bin:cyfmac43455-sdio.bin
    LOCAL_FILES += ../qnx800/target/qnx/etc/firmware/bcm43455_firmware_pkg/brcmfmac43455-sdio.bin:cyfmac43455-sdio.bin
endif
ifneq ($(filter $(TARGET),rpi5),)
    TARBALL_FILES += $(RPI_FW_NON_FREE_RELEASE).tar.gz:debian/config/brcm80211/brcm/brcmfmac43455-sdio.raspberrypi,5-model-b.clm_blob
    TARBALL_FILES += $(RPI_FW_NON_FREE_RELEASE).tar.gz:debian/config/brcm80211/brcm/brcmfmac43455-sdio.raspberrypi,5-model-b.txt
    # For some reason, this version of the FW doesn't work. I have an open question out to the WIFI guys as to why.
    # For now, use the one from the package via LOCAL_FILES
    #TARBALL_FILES += $(RPI_FW_NON_FREE_RELEASE).tar.gz:debian/config/brcm80211/cypress/cyfmac43455-sdio-standard.bin:brcmfmac43455-sdio.raspberrypi,5-model-b.bin
    LOCAL_FILES += ../qnx800/target/qnx/etc/firmware/bcm43455_firmware_pkg/brcmfmac43455-sdio.bin:brcmfmac43455-sdio.raspberrypi,5-model-b.bin
endif

# $1 = tarball URL
define REMOTE_TARBALL_RULES
build/$(notdir $(1)):
	mkdir -p build
	wget -O build/$(notdir $(1)) $(subst %,%25,$(1))
.NOTINTERMEDIATE : build/$(notdir $(1))

build/$(TARGET)/.extracted_$(notdir $(1)): build/$(notdir $(1))
	mkdir -p build/$(TARGET)
	tar xvf $$< --touch --strip-components=1 -C build/$(TARGET)
	touch $$@

all: build/$(TARGET)/.extracted_$(notdir $(1))
endef

# $1 = file config (tarball:file:dest)
define TARBALL_FILE_RULES
__tarball := $(notdir $(word 1,$(subst :, ,$(1))))
__src := $(word 2,$(subst :, ,$(1)))
__dst := $$(if $$(word 3,$(subst :, ,$(1))),$$(word 3,$(subst :, ,$(1))),$$(notdir $$(__src)))

build/$(TARGET)/$$(__src) : build/$(TARGET)/.extracted_$$(__tarball)
build/$(TARGET)/$$(__dst): build/$(TARGET)/$$(__src)
	cp $$< $$@

all: build/$(TARGET)/$$(__dst)
endef

# $1 file URL
define REMOTE_LINUX_FW_FILE_RULES
build/$(notdir $(1))@$(LINUX_FW_RELEASE):
	mkdir -p build
	wget -O $$@ $(1)?id=$(LINUX_FW_RELEASE)

build/$(TARGET)/$(notdir $(1)): build/$(notdir $(1))@$(LINUX_FW_RELEASE)
	mkdir -p build/$(TARGET)
	cp $$< $$@

all: build/$(TARGET)/$(notdir $(1))
endef

# $1 = Local file path
define LOCAL_FILE_RULES
__src := $(word 1,$(subst :, ,$(1)))
__dst := $$(if $$(word 2,$(subst :, ,$(1))),$$(word 2,$(subst :, ,$(1))),$$(notdir $$(__src)))
build/$(TARGET)/$$(__dst): $$(__src)
	mkdir -p build/$(TARGET)
	cp $$< $$@

all: build/$(TARGET)/$$(__dst)
endef

# Add the actual rules for all the targets
$(foreach tb,$(REMOTE_TARBALLS),$(eval $(call REMOTE_TARBALL_RULES,$(tb))))
$(foreach tb,$(TARBALL_FILES),$(eval $(call TARBALL_FILE_RULES,$(tb))))
$(foreach tb,$(REMOTE_LINUX_FW_FILES),$(eval $(call REMOTE_LINUX_FW_FILE_RULES,$(tb))))
$(foreach tb,$(LOCAL_FILES),$(eval $(call LOCAL_FILE_RULES,$(tb))))

clean:
	rm -rf build/$(TARGET)
	$(if $(REMOTE_TARBALLS),rm -rf $(addprefix build/,$(notdir $(REMOTE_TARBALLS))))
	$(if $(REMOTE_LINUX_FW_FILES),rm -rf $(addsuffix @$(LINUX_FW_RELEASE),$(addprefix build/,$(notdir $(REMOTE_LINUX_FW_FILES)))))
	if find build -maxdepth 0 -empty | read REPLY; then rmdir build; fi

