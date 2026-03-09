# assets

## Overview

Assets are generally media files of one kind or another that are used by
one or more applications running on the target. These assets are either fixed
(ie: checked into the repo) or downloaded from the internet then cached in
the assets folder.

One of the ways you would likely want to customize your image are integrating
your own assets into the resulting image. To do this you would want to have
the assets placed into one of the subfolders here, and then modify the
appropriate snippets file to have the asset placed into the image.

## Content

There are four types of assets we explored for inclusion:

- animations
- backgrounds
- fonts
- icons

Each is managed in its own subfolder.

### animations

The animations folder contains various lottie animation files that can be
included in a target image.

These animations are generally used as on-boot animations for the desktop.

See the README for more details.

[animations](animations)

### backgrounds

The backgrounds folder contains background images that can be included in a
target image.

These images are generally used as backgrounds for the demolauncher or
the developer desktop.

See the README for more details on how this works and how you can adjust which
background images are integrated.

[backgrounds](backgrounds)

### fonts

The fonts folder contains the various fonts that can be included in an image.

Generally, no fonts are checked into the repo. Instead the Makefile in the
fonts folder will download the fonts from the internet.

See the README for more details on how this works and how you can adjust which
fonts are downloaded.

[fonts](fonts)

### icons

The icons folder contains various icons that can be included in an image.

A small selection of custom icons are checked into the repo. These are used by
the default window-management of the image. In addition Google's Material Icons
are downloaded from the internet and made available in a form suitable for
the image.

See the README for more details on how this works and how you can adjust which
icons are available.

[icons](icons)
