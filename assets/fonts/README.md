# fonts

## Overview

One of the ways you would likely want to customize your image are adding assets
like fonts, which could be shared by multiple applications that are integrated
into the project.

All fonts that are placed into the **$(FONT_DST)** folder will be placed into
the image at the location: **/usr/share/fonts**. This location is then linked from two other locations for compatibility reasons:

- /system/share/fonts
- /system/fonts

To ensure the fonts are properly installed, the startup script was updated to
refresh the font cache on boot.

## General Integration Approach

In general, each font integration follows the same steps:

1. Download font archive
2. Extract font archive to unique build folder
3. Copy desired fonts from extracted archive to FONT_DST
4. Copy desired fonts' fontconfig from extracted archive to FONTCONFIG_DST
5. Add unique build folder to FONTS variable

Steps 1-4 are generally all carried out by the same rule in the makefile.

### Download font archive or embed local fonts

An archive of the fonts can downloaded from the internet or a font archive 
or font file can be included in the local folder.

The method used for downloading depends on what the source of the fonts
makes available.  It could be a clone of a GIT repo, or a pre-made
release package, or just a zip file that was placed somewhere.

In any case, it is best to identify a specific version of the archive to
download. That way it won't change behind the scenes on you, and it makes
it easier to download a new version later without conflicts.

A new target should be added to the Makefile. The target should be the unique
build location where the archive is extracted. The target should depend on
**build**, **$(FONT_DST)**, and **$(FONTCONFIG_DST)**. A rule should be added
to the target to download the fonts using whatever method was selected.

> If you are cloning a GIT repo instead of downloading an archive, you should
> clone that repo into the build folder. Once the clone is created, checkout
> a specific tag or SHA.

### Extract font archive to unique build folder

Add additional rules to the target to unpack the archive into the unique build
folder selected for these fonts.

> This step may be skipped if a GIT repo was cloned directly into the build
> tree.

### Copy desired fonts from extracted archive to FONT_DST

Add additional rules to the target to copy the desired font files out of the
unique build folder and into **$(FONT_DST)**. The font files are generally
.ttf (true-type font) files. Any font files copied to **$(FONT_DST)** will
be included in the final image.

### Copy desired fonts' fontconfig from extracted archive to FONTCONFIG_DST

Add additional rules to the target to copy the fontconfig information, if
available, out of the unique build folder and into **$(FONTCONFIG_DST)**.

### Add unique build folder to FONTS variable

Near the top of the Makefile is a FONTS variable. The unique build directory
of each font integrated should be added to this variable. This is what will
drive make to actually do the work of acquiring fonts.

## Font Integrations

### fontconfig

The /etc/fontconfig folder for the target is generated as follows:

1. The fonts engine is installed from QNX Software Center to integrate
   the base fontconfig binaries and configuration
2. The fontconfig files are downloaded from the QNX ports fontconfig repository
   on GitHub: [https://github.com/qnx-ports/fontconfig.git](https://github.com/qnx-ports/fontconfig.git))
3. Any font packages with their own fontconfig files are mixed in with the
   conf.avail folder from the above download. This is where
   **$(FONTCONFIG_DST)** points.
4. A conf.d folder that contains soft links to all files in conf.avail is
   generated and then the local fontconfig folder is imported into the image.

### DejaVu Fonts

The currently available Quickstart image includes some DejaVu fonts, so
integrating these fonts was a natural starting point. However, the repository
where these fonts are located, also included some additional DejaVu fonts for
international characters and math symbols, so these fonts have also been
integrated.

The DejaVu fonts site, where you can go obtain the latest fonts is:
[https://dejavu-fonts.github.io/](https://dejavu-fonts.github.io/)

The Makefile is currently downloading version 2.37 of the font sets.

### Google Fonts

Google has sponsored the creation of many useful free fonts for mobile
platforms and web applications.

The Google Fonts Web site, where you can browse to find fonts of interest,
is: [https://fonts.google.com/](https://fonts.google.com/)

The repo containing the source fonts is found here:
[https://github.com/google/fonts/tree/main](https://github.com/google/fonts/tree/main)

The Makefile is currently downloading the zip distribution of this repo
generated from SHA 48d15b319. Downloading the zip distribution and unpacking it
is faster than cloning the entire git repo.

Note that, unlike the DejaVu fonts, Google fonts in the repo downloaded are
mainly variable True Type fonts.  Depending on the naming scheme, certain
attributes can be adjusted after loading with either the FreeType or SDL_ttf
APIs. Static versions of the fonts are only available to download manually
from the Google Fonts site, or in an automated fashion via
[Google APIs](https://developers.google.com/fonts/docs/developer_api) that
require an API key to access.

We chose not to obtain fonts this way for simplicity, but end users who extend
this project are free to change how their obtain Google fonts for their own
build variant.

### Font Awesome Desktop Fonts (free edition)

Font Awesome is best known for their Web fonts that provide a great collection
of useful icons for Web application user interfaces. Their Web fonts are also
available for the desktop as well. Three of their OpenType fonts are available
for free download from their Web site:
[https://docs.fontawesome.com/desktop/setup/get-started](https://docs.fontawesome.com/desktop/setup/get-started)

Go to this page: [https://fontawesome.com/icons](https://fontawesome.com/icons)
to browse the icons available in the fonts. The font code represents the
unicode character represented by that icon's character in the font that
contains it. You will need that information to assemble the unicode or UTF-8
string to render the icon, once it is installed in the image.

Note that the Pro icons are only available in the Pro fonts that are only
available after you purchase a license.

OpenType fonts contain True Type fonts, so they are supported by the FreeType
library integrated into the Quickstart image.

## Other Sources for Free Fonts

There are a number of sources of open source and free fonts that can be
explored.  Here are a few sources that we did not include:

- OpenFoundry: [https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://open-foundry.com/&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECBsQAQ&usg=AOvVaw1YGvdHClzIREgvzKKFoqe-](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://open-foundry.com/&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECBsQAQ&usg=AOvVaw1YGvdHClzIREgvzKKFoqe-)
- Adobe Open Source Fonts: [https://fonts.adobe.com/foundries/open-source](https://fonts.adobe.com/foundries/open-source)
- The League of Movable Type: [https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.theleagueofmoveabletype.com/&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECDMQAQ&usg=AOvVaw0q9j8an7Vy4JuExqa1Mx5C](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.theleagueofmoveabletype.com/&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECDMQAQ&usg=AOvVaw0q9j8an7Vy4JuExqa1Mx5C)
- FontShare open source fonts: [https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://fontshare.com/licenses/sil-ofl&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECC8QAQ&usg=AOvVaw0vsiJXXBqlDg3XT4wJ35r0](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://fontshare.com/licenses/sil-ofl&ved=2ahUKEwi1mJOF56CMAxWhFjQIHTXDE0UQFnoECC8QAQ&usg=AOvVaw0vsiJXXBqlDg3XT4wJ35r0)

## Checking integrated fonts

The easiest way to check if new fonts have been integrated into the image correctly is to
check for the font files in /usr/share/fonts.

To confirm new fonts are rendering correctly, launch the desktop and check the Appearances settings, specifically the Fonts tab, and check the drops downs for either default font setting to check for the font you added shows up in the drop down, and appears to render correctly in the preview.
