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

# versions of fonts to download
DEJAVU_VERSION=2.37
FONT_AWESOME_VERSION=6.7.2
FONTCONFIG_SHA=5523f3c5a2f1224d831ec4cd7981d8101390a5f9
GOOGLE_FONT_SHA=48d15b3193a0d26077155ab1a174c148c9ba6f06


FONT_DST=build/stage/usr/share/fonts
FONTCONFIG_STAGE=build/stage
FONTCONFIG_STAGE_ETC_FONTS=build/stage/etc/fontconfig
FONTCONFIG_EFFC_DST=$(FONTCONFIG_STAGE_ETC_FONTS)/conf.d
FONTCONFIG_STAGE_USR_SHARE_FONTCONFIG=build/stage/usr/share/fontconfig
FONTCONFIG_SHFC_DST=$(FONTCONFIG_STAGE_USR_SHARE_FONTCONFIG)/conf.avail
# Move conf.d entries you wish to enable ie. link to counterparts in conf.avail
# into the list and place others commented out after the list.
# Certain entries represent alternative settings so entries currently enabled
# may need to be commented out and moved out if alternative settings are enabled.
# Note: future fontconfig updates may require adding to this list.
FONTCONFIG_CONFD_ENABLE=\
09-autohint-if-no-hinting.conf \
10-autohint.conf \
10-scale-bitmap-fonts.conf \
10-sub-pixel-rgb.conf \
10-yes-antialias.conf \
11-lcdfilter-default.conf \
30-metric-aliases.conf \
35-lang-normalize.conf \
40-nonlatin.conf \
45-generic.conf \
45-latin.conf \
48-spacing.conf \
49-sansserif.conf \
50-user.conf \
51-local.conf \
57-dejavu-sans.conf \
57-dejavu-sans-mono.conf \
57-dejavu-serif.conf \
58-dejavu-lgc-sans.conf \
58-dejavu-lgc-sans-mono.conf \
58-dejavu-lgc-serif.conf \
60-generic.conf \
60-latin.conf \
65-fonts-persian.conf \
65-khmer.conf \
65-nonlatin.conf \
69-unifont.conf \
70-yes-bitmaps.conf \
80-delicious.conf \
90-synthetic.conf

#05-reset-dirs-sample.conf # including this will cause fc-cache errors \
#10-hinting-full.conf \
#10-hinting-medium.conf \
#10-hinting-none.conf \
#10-hinting-slight.conf \
#10-no-antialias.conf \
#10-sub-pixel-bgr.conf \
#10-sub-pixel-none.conf \
#10-sub-pixel-vbgr.conf \
#10-sub-pixel-vrgb.conf \
#10-unhinted.conf \
#11-lcdfilter-legacy.conf \
#11-lcdfilter-light.conf \
#11-lcdfilter-none.conf \
#20-unhint-small-dejavu-lgc-sans.conf \
#20-unhint-small-dejavu-lgc-sans-mono.conf \
#20-unhint-small-dejavu-lgc-serif.conf \
#20-unhint-small-dejavu-sans.conf \
#20-unhint-small-dejavu-sans-mono.conf \
#20-unhint-small-dejavu-serif.conf \
#20-unhint-small-vera.conf \
#25-unhint-nonlatin.conf \
#70-no-bitmaps-and-emoji.conf \
#70-no-bitmaps.conf \
#70-no-bitmaps-except-emoji.conf \

FONTS=local \
      dejavu-fonts-ttf-$(DEJAVU_VERSION) \
      dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION) \
      google_fonts_$(GOOGLE_FONT_SHA) \
      fontawesome-free-$(FONT_AWESOME_VERSION)-desktop

.PHONY: all clean

all: build/confd_setup

build:
	mkdir -p build

build/fontconfig:| build
	cd build && \
        git clone https://github.com/qnx-ports/fontconfig.git && \
	cd fontconfig && \
	git checkout $(FONTCONFIG_SHA)

$(FONT_DST):
	mkdir -p $(FONT_DST)
$(FONTCONFIG_SHFC_DST): build/fontconfig
	mkdir -p $(FONTCONFIG_EFFC_DST)
	mkdir -p $(FONTCONFIG_SHFC_DST)
	$(foreach file,$(FONTCONFIG_CONFD_ENABLE),cp -r build/fontconfig/conf.d/$(file) $(FONTCONFIG_SHFC_DST);)
	sed -i '/<description/d; /its\:/d' $(FONTCONFIG_SHFC_DST)/*.conf
	cp local.conf $(FONTCONFIG_SHFC_DST)

build/local: $(FONT_DST)
	cp local/Onest-VariableFont_wght.ttf $(FONT_DST)
	touch $@

build/dejavu-fonts-ttf-$(DEJAVU_VERSION):| build $(FONT_DST) $(FONTCONFIG_SHFC_DST)
	wget -P build http://sourceforge.net/projects/dejavu/files/dejavu/$(DEJAVU_VERSION)/dejavu-fonts-ttf-$(DEJAVU_VERSION).zip
	cd build && unzip -DD -o dejavu-fonts-ttf-$(DEJAVU_VERSION).zip
	cp build/dejavu-fonts-ttf-$(DEJAVU_VERSION)/fontconfig/* $(FONTCONFIG_SHFC_DST)
	cp build/dejavu-fonts-ttf-$(DEJAVU_VERSION)/ttf/* $(FONT_DST)

build/dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION):| build $(FONT_DST) $(FONTCONFIG_SHFC_DST)
	wget -P build http://sourceforge.net/projects/dejavu/files/dejavu/$(DEJAVU_VERSION)/dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION).zip
	cd build && unzip -DD -o dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION).zip
	cp build/dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION)/fontconfig/* $(FONTCONFIG_SHFC_DST)
	cp build/dejavu-lgc-fonts-ttf-$(DEJAVU_VERSION)/ttf/* $(FONT_DST)

build/google_fonts_$(GOOGLE_FONT_SHA).zip:| build
	wget -O $@ https://github.com/google/fonts/archive/$(GOOGLE_FONT_SHA).zip
build/google_fonts_$(GOOGLE_FONT_SHA): build/google_fonts_$(GOOGLE_FONT_SHA).zip | build $(FONT_DST) $(FONTCONFIG_SHFC_DST)
	rm -rf $@
	cd build && unzip -DD $(notdir $<)
	mv build/fonts-$(GOOGLE_FONT_SHA) $@
	cp $@/ofl/robotomono/RobotoMono-Italic[wght].ttf $(FONT_DST)
	cp $@/ofl/robotomono/RobotoMono[wght].ttf $(FONT_DST)
	cp $@/apache/robotoslab/RobotoSlab[wght].ttf $(FONT_DST)
	cp $@/ofl/robotoserif/RobotoSerif-Italic[GRAD,opsz,wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/robotoserif/RobotoSerif[GRAD,opsz,wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/roboto/Roboto-Italic[wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/roboto/Roboto[wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/robotoflex/RobotoFlex[GRAD,XOPQ,XTRA,YOPQ,YTAS,YTDE,YTFI,YTLC,YTUC,opsz,slnt,wdth,wght].ttf $(FONT_DST)
	cp $@/ofl/robotocondensed/RobotoCondensed-Italic[wght].ttf $(FONT_DST)
	cp $@/ofl/robotocondensed/RobotoCondensed[wght].ttf $(FONT_DST)
	cp $@/ofl/notosansjp/NotoSansJP[wght].ttf $(FONT_DST)
	cp $@/ofl/notosanskr/NotoSansKR[wght].ttf $(FONT_DST)
	cp $@/ofl/notosanstc/NotoSansTC[wght].ttf $(FONT_DST)


build/fontawesome-free-$(FONT_AWESOME_VERSION)-desktop:| build $(FONT_DST) $(FONTCONFIG_SHFC_DST)
	wget -P build https://use.fontawesome.com/releases/v$(FONT_AWESOME_VERSION)/fontawesome-free-$(FONT_AWESOME_VERSION)-desktop.zip
	cd build && unzip -DD fontawesome-free-$(FONT_AWESOME_VERSION)-desktop.zip
	cp build/fontawesome-free-$(FONT_AWESOME_VERSION)-desktop/otfs/* $(FONT_DST)

build/confd_setup: $(addprefix build/,$(FONTS)) | $(FONTCONFIG_SHFC_DST)
#	$(foreach file,$(notdir $(wildcard $(FONTCONFIG_SHFC_DST)/*)),ln -sf /usr/share/fontconfig/conf.avail/$(file) $(FONTCONFIG_EFFC_DST)/$(file);)
	$(foreach file,$(FONTCONFIG_CONFD_ENABLE),ln -sf /usr/share/fontconfig/conf.avail/$(file) $(FONTCONFIG_EFFC_DST)/$(file);)
	touch $@

clean:
	rm -rf build

