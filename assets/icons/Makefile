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

MATERIAL_DESIGN_ICONS_VERSION=4.0.0
GNOME_ICON_THEME_PATH_VERSION=3.12
GNOME_ICON_THEME_VERSION=3.12.0


all: gnome-icon-theme-$(GNOME_ICON_THEME_VERSION) icons/qnx

# $1 == source icon to convert
# $2 == Desired output size of icon
# $3 == Output basename of icon. Suffix and extension will automatically be added
# $4 == List of icon types to make. Allowed types are 'black', 'white', 'black_translucent', and 'white_translucent'
define CONVERT_ICON

ifneq ($(filter resize_only,$(4)),)
$(3).png: $(1)
	convert $(1) -resize $(2)x$(2) -type TrueColorAlpha PNG32:$$@
all: $(3).png
endif

ifneq ($(filter black,$(4)),)
$(3)_black.png: $(1)
	convert $(1) -resize $(2)x$(2) -type TrueColorAlpha PNG32:$$@
all: $(3)_black.png
endif

ifneq ($(filter white,$(4)),)
$(3)_white.png: $(1)
	convert $(1) -resize $(2)x$(2) -type TrueColorAlpha +level-colors "#ffffff", PNG32:$$@
all: $(3)_white.png
endif

ifneq ($(filter coral,$(4)),)
$(3)_coral.png: $(1)
	convert $(1) -resize $(2)x$(2) -type TrueColorAlpha +level-colors "#ff443a", PNG32:$$@
all: $(3)_coral.png
endif

ifneq ($(filter black_translucent,$(4)),)
$(3)_black_translucent.png: $(1)
	convert $(1) \
		-resize $(2)x$(2) -type TrueColorAlpha \
	        -alpha set -background none -channel A -evaluate multiply 0.25 +channel \
		PNG32:$$@
all: $(3)_black_translucent.png
endif

ifneq ($(filter white_translucent,$(4)),)
$(3)_white_translucent.png: $(1)
	convert $(1) \
		-resize $(2)x$(2) -type TrueColorAlpha +level-colors "#ffffff", \
	        -alpha set -background none -channel A -evaluate multiply 0.25 +channel \
		PNG32:$$@
all: $(3)_white_translucent.png
endif

endef

# $1 == Icon to generate within material-design folder
# $2 == Desired width size of icon
# $3 == Desired height size of icon
# $4 == Desired width of grey -- needs to be smaller than $2 to allow for the white border.
# $5 == Desired height of grey -- needs to be smaller than $3 to allow for the white border.
define CONVERT_GREY_ICON

$(1).png:
	convert \
		-size $(2)x$(3)  xc:none -fill grey20 -stroke white -strokewidth 1 -depth 8 \
            -draw "roundrectangle 0,0,$(4),$(5),15,15" $$@
all: $(1).png

endef

# $1 == Icon to convert within material-design folder
# $2 == Desired output size of icon
# $3 == Output basename of icon. Suffix and extension will automatically be added
# $4 == List of icon types to make. Allowed types are 'black', 'white', 'black_translucent', and 'white_translucent'
define CONVERT_MD_ICON
material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1) : material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)

$(eval $(call CONVERT_ICON,material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)/$(1),128,icons/google/$(3),black white))

endef

# Download and extract latest Material Icon's release zip file
$(MATERIAL_DESIGN_ICONS_VERSION).zip:
	wget https://github.com/google/material-design-icons/archive/refs/tags/$(MATERIAL_DESIGN_ICONS_VERSION).zip

material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION): $(MATERIAL_DESIGN_ICONS_VERSION).zip
	mkdir -p icons/google
	unzip -DD $(MATERIAL_DESIGN_ICONS_VERSION).zip

# QNX brand icons
icons/qnx:
	mkdir -p icons/qnx

# QNX brand icons (in brand (Coral), white and black colours)
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Terminal.png,128,icons/qnx/terminal_large,coral))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Terminal.png,128,icons/terminal_large,black))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Terminal.png,128,icons/terminal_large,white))

$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Computer.png,128,icons/qnx/computer_large,coral))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Computer.png,128,icons/computer_large,black))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Computer.png,128,icons/computer_large,white))

$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Contact.png,128,icons/qnx/contact_large,coral))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Contact.png,128,icons/contact_large,black))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_Contact.png,128,icons/contact_large,white))

$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_GEAR.png,128,icons/qnx/gears_large,coral))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_GEAR.png,128,icons/gears_large,black))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_GEAR.png,128,icons/gears_large,white))

$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_MAZE.png,128,icons/qnx/maze_large,coral))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_MAZE.png,128,icons/maze_large,black))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_MAZE.png,128,icons/maze_large,white))

$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_CUBE.png,128,icons/qnx/cube_large,coral))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_CUBE.png,128,icons/cube_large,black))
$(eval $(call CONVERT_ICON,local/QNX-Icon-Digital-BLACK_CUBE.png,128,icons/cube_large,white))

$(eval $(call CONVERT_GREY_ICON,icons/grey_large,128,128,126,126))
$(eval $(call CONVERT_GREY_ICON,icons/grey_rectangle_large,256,128,254,126))

# Google Material Design icons
$(eval $(call CONVERT_MD_ICON,android/action/power_settings_new/materialiconsround/black/res/drawable-xxxhdpi/round_power_settings_new_black_36.png,128,round_power_button,black white))

$(eval $(call CONVERT_MD_ICON,android/content/add_circle_outline/materialiconsround/black/res/drawable-xxxhdpi/round_add_circle_outline_black_36.png,128,round_add_circle_button,black white black_translucent white_translucent))

$(eval $(call CONVERT_MD_ICON,android/action/settings/materialicons/black/res/drawable-xxxhdpi/baseline_settings_black_36.png,128,gears_icon_large,black white))

$(eval $(call CONVERT_MD_ICON,android/image/crop_square/materialicons/black/res/drawable-xxxhdpi/baseline_crop_square_black_36.png,128,cube_icon_large,black white))

$(eval $(call CONVERT_MD_ICON,android/navigation/subdirectory_arrow_left/materialiconssharp/black/res/drawable-xxxhdpi/sharp_subdirectory_arrow_left_black_36.png,128,maze_icon_large,black white))

$(eval $(call CONVERT_MD_ICON,android/av/videocam/materialicons/black/res/drawable-xxxhdpi/baseline_videocam_black_36.png,128,video_icon_large,black white))

# Download and extract latest GNOME Icon theme tarball
gnome-icon-theme-$(GNOME_ICON_THEME_VERSION).tar.xz:
	wget https://download.gnome.org/sources/gnome-icon-theme/$(GNOME_ICON_THEME_PATH_VERSION)/gnome-icon-theme-$(GNOME_ICON_THEME_VERSION).tar.xz

gnome-icon-theme-$(GNOME_ICON_THEME_VERSION): gnome-icon-theme-$(GNOME_ICON_THEME_VERSION).tar.xz
	mkdir -p icons
	tar xvf gnome-icon-theme-$(GNOME_ICON_THEME_VERSION).tar.xz gnome-icon-theme-$(GNOME_ICON_THEME_VERSION)/gnome
	mv gnome-icon-theme-$(GNOME_ICON_THEME_VERSION)/gnome icons

clean:
	rm -rf icons
	rm -rf gnome-icon-theme-$(GNOME_ICON_THEME_VERSION)
	rm -rf material-design-icons-$(MATERIAL_DESIGN_ICONS_VERSION)
	rm -rf gnome-icon-theme-$(GNOME_ICON_THEME_VERSION).tar.xz
	rm -rf $(MATERIAL_DESIGN_ICONS_VERSION).zip

-include $(BUILD_TEMPLATE)/template.mk
