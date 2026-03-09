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
MYDIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# Expands to a single newline character
define NEWLINE


endef

AVAILABLE_TARGETS := $(notdir $(wildcard ../targets/*))
ifeq ($(filter $(AVAILABLE_TARGETS),$(TARGET)),)
  $(error TARGET is not set or invalid. Available targets are: $(AVAILABLE_TARGETS))
endif
include ../targets/$(TARGET)/variables.mk

# Linux tools
APK_TOOLS_REPO_TAG=v3.0.0_rc5
ABUILD_REPO_VERSION=qnx_3.15.0
QSC_APK_VERSION=main
QSC_APK_SHA=f8f29159dc7e5a430dd138b399441d083113476e
MESON_VERSION=1.8.1

# internal repos for apk artifacts
BUILD_APK_REPOS_LIST := repo.oss.qnx.com

RUNTIME_APK_REPOS_LIST := repo.oss.qnx.com

APK_REPO_BASE_FOLDER=8.0.3

APK_CORE_FOLDER=core
APK_EXTRA_FOLDER=extra
APK_CORE_ARCH_FOLDER=${APK_CORE_FOLDER}/$(QNX_ARCH)
APK_EXTRA_ARCH_FOLDER=${APK_EXTRA_FOLDER}/$(QNX_ARCH)
APK_QNX_CORE_FOLDER=qnx-core
APK_QNX_EXTRA_FOLDER=qnx-extra
APK_QNX_CORE_ARCH_FOLDER=${APK_QNX_CORE_FOLDER}/$(QNX_ARCH)
APK_QNX_EXTRA_ARCH_FOLDER=${APK_QNX_EXTRA_FOLDER}/$(QNX_ARCH)

# apk package / index key name
KEY_NAME=qnxosd.rsa.pub

STAGE_BASE=$(MYDIR)stage
STAGE_LINUX=$(STAGE_BASE)/linux
STAGE_ROOT=$(STAGE_BASE)/nto
STAGE_SNIPPETS=$(STAGE_BASE)/snippets
STAGE_TARGET=$(STAGE_ROOT)/$(QNX_ARCHDIR)
STAGE_APK_ROOT=$(STAGE_BASE)/apk_root

APK_LOCAL_REPO_IMAGE_BASE=/data/share/packages
APK_LOCAL_REPO_BASE_FOLDER=$(STAGE_APK_ROOT)/var$(APK_LOCAL_REPO_IMAGE_BASE)/$(APK_REPO_BASE_FOLDER)
APK_LOCAL_REPO_FOLDER_IMAGE_PATH=$(APK_LOCAL_REPO_IMAGE_BASE)/$(APK_REPO_BASE_FOLDER)

# preinstall apk package lists
PREINSTALL_APK_PACKAGE_LIST_FILE := $(STAGE_BASE)/apk_install_packages.list
CTI_PREINSTALL_APK_PACKAGE_SET_FILE := $(STAGE_BASE)/cti_apk_install_package_set

# qsc QNX apk package lists
QNX_QSC_APK_PACKAGE_LIST_FILE := $(STAGE_BASE)/qsc_apk_install_packages.list
CTI_QNX_QSC_APK_PACKAGE_LIST_FILE := $(STAGE_BASE)/cti_qsc_apk_install_packages_set

FAKEROOT_SAVE=$(STAGE_BASE)/fakeroot.save
FAKEROOT = fakeroot -i $(FAKEROOT_SAVE) -s $(FAKEROOT_SAVE)
FAKEROOT_START = fakeroot -s $(FAKEROOT_SAVE)

.PHONY: all clean

# $1 = apk key name
define DOWNLOAD_APK_KEY_RULE
$(STAGE_APK_ROOT)/etc/apk/keys/$(1): $(STAGE_APK_ROOT)
	mkdir -p $(STAGE_APK_ROOT)/etc/apk/keys
	$(foreach repo,$(RUNTIME_APK_REPOS_LIST),
	-@if [ ! -e "$(STAGE_APK_ROOT)/etc/apk/keys/$(1)" ]; then \
		wget -P $(STAGE_APK_ROOT)/etc/apk/keys https://$(repo)/keys/$(1); \
	fi
	)
	@if [ ! -e "$(STAGE_APK_ROOT)/etc/apk/keys/$(1)" ]; then \
		echo "download failed!"; \
		exit 1; \
	fi

all :| $(STAGE_APK_ROOT)/etc/apk/keys/$(1)
endef

define create_apk_root
$(FAKEROOT_START) mkdir -p $(STAGE_APK_ROOT);$(NEWLINE)
$(FAKEROOT) ln -s $(STAGE_APK_ROOT) $(STAGE_APK_ROOT)/$(QNX_ARCH);$(NEWLINE)
$(FAKEROOT) ln -s $(STAGE_APK_ROOT)/var/data $(STAGE_APK_ROOT)/data;$(NEWLINE)
$(FAKEROOT) mkdir -p $(STAGE_APK_ROOT)/tmp;$(NEWLINE)
$(FAKEROOT) mkdir -p -m 755 $(STAGE_APK_ROOT)/usr/lib;$(NEWLINE)
$(FAKEROOT) mkdir -p -m 755 $(STAGE_APK_ROOT)/usr/bin;$(NEWLINE)
$(FAKEROOT) mkdir -p -m 755 $(STAGE_APK_ROOT)/etc;$(NEWLINE)
cd $(STAGE_APK_ROOT) && $(FAKEROOT) ln -s usr/lib lib;$(NEWLINE)
cd $(STAGE_APK_ROOT) && $(FAKEROOT) ln -s usr/bin bin;$(NEWLINE)
endef

define set_apk_arch
	$(FAKEROOT) mkdir -p $(STAGE_APK_ROOT)/etc/apk;$(NEWLINE)
	$(FAKEROOT) echo "$(QNX_ARCH)" > $(STAGE_APK_ROOT)/etc/apk/arch;$(NEWLINE)
endef

define set_apks_repositories
	mkdir -p $(STAGE_APK_ROOT)/etc/apk;$(NEWLINE)
	$(FAKEROOT) echo -n "" > $(STAGE_APK_ROOT)/etc/apk/repositories;$(NEWLINE)
	$(foreach repo,$(RUNTIME_APK_REPOS_LIST), \
	echo "https://$(repo)/$(APK_REPO_BASE_FOLDER)/$(APK_CORE_FOLDER)\nhttps://$(repo)/$(APK_REPO_BASE_FOLDER)/$(APK_EXTRA_FOLDER)" >> $(STAGE_APK_ROOT)/etc/apk/repositories;\
	echo "https://$(repo)/$(APK_REPO_BASE_FOLDER)/$(APK_QNX_EXTRA_FOLDER)" >> $(STAGE_APK_ROOT)/etc/apk/repositories;\
	echo "file://$(APK_LOCAL_REPO_BASE_FOLDER)/$(APK_QNX_CORE_FOLDER)\nfile://$(APK_LOCAL_REPO_BASE_FOLDER)/$(APK_QNX_EXTRA_FOLDER)" >> $(STAGE_APK_ROOT)/etc/apk/repositories;$(NEWLINE))
endef

define install_local_abuild_signing_key
	$(FAKEROOT) cp $(shell cat $(STAGE_BASE)/.abuild/abuild.conf | grep PACKAGER_PRIVKEY | \
	  sed -e 's/PACKAGER_PRIVKEY=//g' | sed -e 's/"//g').pub \
	  $(STAGE_APK_ROOT)/etc/apk/keys;$(NEWLINE)
endef

# add rules for build and install package list
all :| $(STAGE_BASE) reset_lists

# build Linux apk utilities
all :| $(STAGE_LINUX)/usr/bin/apk $(STAGE_LINUX)/usr/bin/abuild

# check for build content changes
all :| $(STAGE_BASE)/check_preinstall_changes
all :| $(STAGE_BASE)/check_qsc_qnx_package_changes

# generate / preinstall apks
all :| $(STAGE_BASE)/generate_qnx_qsc_apks

$(eval $(call DOWNLOAD_APK_KEY_RULE,$(KEY_NAME)))
all :| $(STAGE_BASE)/preinstall_apks
all :| $(STAGE_BASE)/generate_preinstall_snippets

# add rules for apk patches
all :| $(STAGE_APK_ROOT)/etc/sudoers.apk-new $(STAGE_APK_ROOT)/etc/ssh/sshd_config.apk-new

$(STAGE_BASE):
	mkdir -p $(STAGE_BASE)

$(STAGE_SNIPPETS):
	mkdir -p $(STAGE_SNIPPETS)

$(STAGE_TARGET):
	mkdir -p $(STAGE_TARGET)

$(STAGE_BASE)/apk-tools-ready:
	cd $(STAGE_BASE) && git clone https://github.com/alpinelinux/apk-tools.git
	cd $(STAGE_BASE)/apk-tools && git checkout $(APK_TOOLS_REPO_TAG)
	rm -rf $(STAGE_BASE)/meson
	cd $(STAGE_BASE) && git clone https://github.com/mesonbuild/meson.git
	cd $(STAGE_BASE)/meson && git checkout $(MESON_VERSION)
	touch $@

$(STAGE_LINUX)/usr/bin/apk: $(STAGE_BASE)/apk-tools-ready
	cd $(STAGE_BASE)/apk-tools && python3 $(STAGE_BASE)/meson/meson.py setup -Dprefix=$(STAGE_LINUX)/usr build
	cd $(STAGE_BASE)/apk-tools && ninja -C build
	cd $(STAGE_BASE)/apk-tools && python3 $(STAGE_BASE)/meson/meson.py install -C build

$(STAGE_BASE)/abuild-ready: $(STAGE_LINUX)/usr/bin/apk
	cd $(STAGE_BASE) && git clone https://github.com/qnx-ports/abuild
	cd $(STAGE_BASE)/abuild && git checkout $(ABUILD_REPO_VERSION)
	touch $@

$(STAGE_LINUX)/usr/bin/abuild: $(STAGE_BASE)/abuild-ready
	cd $(STAGE_BASE)/abuild && \
	  abuild_keygen_install_root=$(STAGE_LINUX) \
	  prefix=$(STAGE_LINUX)/usr \
	  sysconfdir=$(STAGE_LINUX)/etc \
	  make install
	mkdir -p $(STAGE_BASE)/.abuild
	cp $(MYDIR)/abuild.conf $(STAGE_BASE)/.abuild
	sed -i -e 's/%user.email%/$(shell git config user.email)/g' $(STAGE_BASE)/.abuild/abuild.conf
	. $(STAGE_BASE)/.abuild/abuild.conf && \
	  abuild_keygen_install_root=$(STAGE_LINUX) \
	  SUDO="" \
	  ABUILD_USERDIR=$(STAGE_BASE)/.abuild \
	  CBUILD=$(QNX_ARCH) \
	  $(STAGE_LINUX)/usr/bin/abuild-keygen -nai

reset_lists:
	rm -rf $(STAGE_BASE)/*.list

PREINSTALL_FILES = $(MYDIR)/world.preinstall_$(QNX_ARCH) $(wildcard $(MYDIR)/../targets/$(TARGET)/world.preinstall_$(QNX_ARCH))
$(STAGE_BASE)/world.preinstall_$(QNX_ARCH): $(PREINSTALL_FILES)
	cat $^ > $@

$(STAGE_BASE)/check_preinstall_changes: $(STAGE_BASE)/world.preinstall_$(QNX_ARCH)
	if [ ! -z "$(shell diff -b -B -w $(STAGE_BASE)/world.preinstall_$(QNX_ARCH) $(STAGE_BASE)/world.cti_preinstall 2>&1)" ]; then \
	    echo Forcing apk update due to preinstall apk package changes; \
	    rm -rf $(STAGE_SNIPPETS) $(STAGE_BASE)/preinstall_apks $(FAKEROOT_SAVE) $(STAGE_BASE)generate_preinstall_snippets; \
	    rm -rf $(STAGE_APK_ROOT); \
	fi

$(QNX_QSC_APK_PACKAGE_LIST_FILE): $(STAGE_BASE)/check_preinstall_changes
	echo Checking which QSC packages need to be converted into local QNX apks ...
	rm -rf $(STAGE_BASE)/qsc-apk
	cd $(STAGE_BASE) && git clone https://github.com/qnx-ports/qsc-apk -b $(QSC_APK_VERSION)
	cd $(STAGE_BASE)/qsc-apk && git checkout $(QSC_APK_SHA)
	cat $(STAGE_BASE)/qsc-apk/$(APK_QNX_CORE_FOLDER)/qsc_install_packages.list \
	  $(STAGE_BASE)/qsc-apk/$(APK_QNX_EXTRA_FOLDER)/qsc_install_packages.list \
	  > $(QNX_QSC_APK_PACKAGE_LIST_FILE)

$(STAGE_BASE)/check_qsc_qnx_package_changes: $(QNX_QSC_APK_PACKAGE_LIST_FILE)
	if [ ! -z "$(shell diff -b -B -w $(QNX_QSC_APK_PACKAGE_LIST_FILE) $(CTI_QNX_QSC_APK_PACKAGE_LIST_FILE) 2>&1)" ]; then \
	    echo Forcing apk update due to qsc package apk package changes; \
	    rm -rf $(STAGE_BASE)/generate_qnx_qsc_apks $(STAGE_APK_ROOT); \
	fi
	touch $@

$(STAGE_BASE)/generate_qnx_qsc_apks:
	$(create_apk_root)
	echo Processing QSC packages into local QNX apks ...
	mkdir -p $(APK_LOCAL_REPO_BASE_FOLDER)/$(APK_QNX_CORE_FOLDER)
	mkdir -p $(APK_LOCAL_REPO_BASE_FOLDER)/$(APK_QNX_EXTRA_FOLDER)
	cd $(MYDIR) && \
	  ABUILD_USERDIR=$(STAGE_BASE)/.abuild \
	  ABUILD_CONF=$(STAGE_BASE)/.abuild/abuild.conf \
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$(STAGE_LINUX)/usr/lib:$(STAGE_LINUX)/usr/lib/$(shell uname -m)-linux-gnu \
	  PATH=${PATH}:$(STAGE_LINUX)/usr/bin \
	  QNX_TARGET=$(MYDIR)/../qnx800 \
	  APK_PATH=$(STAGE_LINUX)/usr/bin/apk \
	  ABUILD_PATH=$(STAGE_LINUX)/usr/bin/abuild \
	  ./build-qnx-apks \
	  $(STAGE_BASE)/qsc-apk/$(APK_QNX_CORE_FOLDER) \
	  --swc-cli-path $(QSC_CLT_PATH) \
	  --swc-cli-options $(MYDIR)/../options_file \
	  --arch $(QNX_ARCH) \
	  -o $(APK_LOCAL_REPO_BASE_FOLDER)/$(APK_QNX_CORE_FOLDER)
	cd $(MYDIR) && \
	  ABUILD_USERDIR=$(STAGE_BASE)/.abuild \
	  ABUILD_CONF=$(STAGE_BASE)/.abuild/abuild.conf \
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$(STAGE_LINUX)/usr/lib:$(STAGE_LINUX)/usr/lib/$(shell uname -m)-linux-gnu \
	  PATH=${PATH}:$(STAGE_LINUX)/usr/bin \
	  QNX_TARGET=$(MYDIR)/../qnx800 \
	  APK_PATH=$(STAGE_LINUX)/usr/bin/apk \
	  ABUILD_PATH=$(STAGE_LINUX)/usr/bin/abuild \
	  ./build-qnx-apks \
	  $(STAGE_BASE)/qsc-apk/$(APK_QNX_EXTRA_FOLDER) \
	  --swc-cli-path $(QSC_CLT_PATH) \
	  --swc-cli-options $(MYDIR)/../options_file \
	  --arch $(QNX_ARCH) \
	  -o $(APK_LOCAL_REPO_BASE_FOLDER)/$(APK_QNX_EXTRA_FOLDER)
	cp $(QNX_QSC_APK_PACKAGE_LIST_FILE) $(CTI_QNX_QSC_APK_PACKAGE_LIST_FILE)
	touch $@

$(STAGE_BASE)/preinstall_apks:
	$(set_apk_arch)
	$(set_apks_repositories)
	$(install_local_abuild_signing_key)
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$(STAGE_LINUX)/usr/lib:$(STAGE_LINUX)/usr/lib/$(shell uname -m)-linux-gnu \
	  PATH=${PATH}:$(STAGE_LINUX)/usr/bin \
	  $(FAKEROOT) $(STAGE_LINUX)/usr/bin/apk  --no-cache --root $(STAGE_APK_ROOT) add --initdb
	cat $(STAGE_BASE)/world.preinstall_$(QNX_ARCH) > $(STAGE_APK_ROOT)/etc/apk/world
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$(STAGE_LINUX)/usr/lib:$(STAGE_LINUX)/usr/lib/$(shell uname -m)-linux-gnu \
	  PATH=${PATH}:$(STAGE_LINUX)/usr/bin \
	  $(FAKEROOT) $(STAGE_LINUX)/usr/bin/apk --arch $(QNX_ARCH)  --no-cache --root $(STAGE_APK_ROOT) update
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$(STAGE_LINUX)/usr/lib:$(STAGE_LINUX)/usr/lib/$(shell uname -m)-linux-gnu \
	  PATH=${PATH}:$(STAGE_LINUX)/usr/bin \
	  $(FAKEROOT) $(STAGE_LINUX)/usr/bin/apk --arch $(QNX_ARCH)  --no-cache --root $(STAGE_APK_ROOT) add --no-scripts filesystem
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$(STAGE_LINUX)/usr/lib:$(STAGE_LINUX)/usr/lib/$(shell uname -m)-linux-gnu \
	  PATH=${PATH}:$(STAGE_LINUX)/usr/bin \
	  $(FAKEROOT) $(STAGE_LINUX)/usr/bin/apk --arch $(QNX_ARCH)  --no-cache --root $(STAGE_APK_ROOT) list -I --manifest | sed 's: :=:g' > $(STAGE_BASE)/apk_preinstalled_packages.list
	sed -i -e 's|$(APK_LOCAL_REPO_BASE_FOLDER)|$(APK_LOCAL_REPO_FOLDER_IMAGE_PATH)|g' $(STAGE_APK_ROOT)/etc/apk/repositories
	cat $(STAGE_BASE)/world.preinstall_$(QNX_ARCH) | cut -d'=' -f1 | cut -d '<' -f1 | cut -d '>' -f1 > $(STAGE_APK_ROOT)/etc/apk/world
	cat $(STAGE_BASE)/world.preinstall_$(QNX_ARCH) > $(STAGE_BASE)/world.cti_preinstall
	touch $@

$(STAGE_BASE)/generate_preinstall_snippets: $(STAGE_APK_ROOT)/etc/ssh/sshd_config.apk-new $(STAGE_SNIPPETS)
	$(FAKEROOT) \
	  ./generate-apk-root-snippets $(STAGE_SNIPPETS)/system_files.custom.apk_root_usr_dir $(STAGE_APK_ROOT) apk_root "usr" ""
	$(FAKEROOT) \
	  ./generate-apk-root-snippets $(STAGE_SNIPPETS)/data_files.custom.apk_root_etc_dir $(STAGE_APK_ROOT) apk_root "etc" "var/etc"
	$(FAKEROOT) \
	  ./generate-apk-root-snippets $(STAGE_SNIPPETS)/data_files.custom.apk_root_var_dir $(STAGE_APK_ROOT) apk_root "var" "var"
	touch $@

# apply CTI-specific changes to unpacked apk files
$(STAGE_APK_ROOT)/etc/sudoers.apk-new: $(STAGE_BASE)/preinstall_apks
	chmod u+w $(STAGE_APK_ROOT)/etc/sudoers
	rm -rf $(STAGE_APK_ROOT)/etc/sudoers.apk-new
	cp $(STAGE_APK_ROOT)/etc/sudoers $(STAGE_APK_ROOT)/etc/sudoers.apk-new
	sed -i -e 's/# %sudo ALL=(ALL:ALL) ALL/%sudo ALL=(ALL:ALL) ALL\n%abuild ALL=(ALL:ALL) NOPASSWD: ALL/g' $(STAGE_APK_ROOT)/etc/sudoers
	sed -i -e 's/secure_path="\/usr\/bin"/secure_path="\/usr\/bin:\/proc\/boot\"/g' $(STAGE_APK_ROOT)/etc/sudoers
	chmod u-w $(STAGE_APK_ROOT)/etc/sudoers $(STAGE_APK_ROOT)/etc/sudoers.apk-new

$(STAGE_APK_ROOT)/etc/ssh/sshd_config.apk-new: $(STAGE_BASE)/preinstall_apks
	rm -rf $(STAGE_APK_ROOT)/etc/ssh/sshd_config.apk-new
	cp $(STAGE_APK_ROOT)/etc/ssh/sshd_config $(STAGE_APK_ROOT)/etc/ssh/sshd_config.apk-new
	sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' $(STAGE_APK_ROOT)/etc/ssh/sshd_config
	sed -i -e 's/#UsePAM no/UsePAM yes/g' $(STAGE_APK_ROOT)/etc/ssh/sshd_config
	sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' $(STAGE_APK_ROOT)/etc/ssh/sshd_config
	sed -i -e 's/#PermitUserEnvironment no/PermitUserEnvironment yes/g' $(STAGE_APK_ROOT)/etc/ssh/sshd_config
	echo '\nProtocol 2' >> $(STAGE_APK_ROOT)/etc/ssh/sshd_config
	echo 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr' >> $(STAGE_APK_ROOT)/etc/ssh/sshd_config
	echo 'MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com' >> $(STAGE_APK_ROOT)/etc/ssh/sshd_config
	echo 'KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256' >> $(STAGE_APK_ROOT)/etc/ssh/sshd_config
	echo '\nSshdSessionPath /usr/libexec/sshd-session' >> $(STAGE_APK_ROOT)/etc/ssh/sshd_config

clean:
	rm -rf $(STAGE_BASE)

