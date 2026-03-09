# animations

## Overview

One of the ways you might want to customize your image is by changing or
adding to the animations that are used.

Snippet files control which animations are added to the target. For the current
animations, as they are used as on-boot animations, they are placed into the
`/system/etc/startup` folder on the target.

## Notes about animations and usage

- the animation files in this directory are svg lottie animations. These are
  used by the binary rpi-lottie before screen starts as on-boot animations. The
  current animation used can be changed in the `post_start~20.graphics` snippet
  file.
- to test an animation file, follow the instructions provided by rpi-lottie to
  run the animation. Please ensure that screen is not running when the
  rpi-lottie binary is run.
- the animation files are included by the snippet file
  `system_files.custom.boot_anim`. To add additional animation files, follow
  the same format as in the aforementioned snippet file.

## Animations

The existing animations and their uses are detailed here.

### gears.json

This animation is used as a sample lottie animation.

### qnx.json

This animation is used as the current on-boot animation.
