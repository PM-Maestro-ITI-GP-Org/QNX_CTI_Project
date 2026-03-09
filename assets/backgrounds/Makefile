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

GNOME_BACKGROUNDS_PATH_VERSION=48
GNOME_BACKGROUNDS_VERSION=48.2.1


all: gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION)

# Download and extract latest GNOME Icon theme tarball
gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION).tar.xz:
	wget https://download.gnome.org/sources/gnome-backgrounds/$(GNOME_BACKGROUNDS_PATH_VERSION)/gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION).tar.xz

gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION): gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION).tar.xz
	mkdir -p backgrounds
	tar xvf gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION).tar.xz gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION)/backgrounds
	mv gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION)/backgrounds/* backgrounds

clean:
	rm -rf backgrounds
	rm -rf gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION)
	rm -rf gnome-backgrounds-$(GNOME_BACKGROUNDS_VERSION).tar.xz

-include $(BUILD_TEMPLATE)/template.mk
