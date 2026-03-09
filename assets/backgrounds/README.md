# backgrounds

## Overview

One of the ways you might want to customize your image is by changing or
adding to the background images that are used. By default the images in
this folder are fixed and used as the background of the desktop.

Snippet files control which images are added to the target. Generally speaking,
when background images are added they are placed into `/usr/share/backgrounds` but the backgrounds for demolauncher are also integrated into `/usr/etc/images` folder on the target, although this will change in a future release.

## local

This folder is where new images to be embedded are to be added.

### background_1080p.png

This image is used as the background for demolauncher when the display is
configured to a resolution of 1080p (1920x1080).

> This image is also used as demolauncher's default background image when
> the resolution does not match either 1080p (1920x1080) or 720p (1280x720).

### background_720p.png

This image is used as the background for demolauncher when the display is
configured to a resolution of 720p (1280x720).

There are also several QNX themed background images that are included in the image
at the location `/ur/share/backgrounds/qnx` where they are made available to
use with the developer desktop.

### desktop

This subfolder contains the background images for the QNX Developer Desktop.

## Makefile

The Makefile contains rules to copy the local icons to where they need to be found to include in the image, as well as an example of how to download additional open source icons to include in the image.
