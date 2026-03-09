# mkqnximage

## Overview

mkqnximage is a utility provided by the SDP that will generate QNX images
for a supported target. It is used as the final step of the CTI build process
to actually produce the partitions and images.

mkqnximage is more of an orchestrator that creates configuration for and
executes other tools to do the actual work.

mkqnximage has a robust system of configuration, extension and customization.
The [snippets](../snippets) files are the primary method to configure
mkqnximage. When a snippet file isn't sufficient `extras` can be added for
more extensive customization.

Subdirectories here are provided to mkqnximage as an 'extras' directory.

Local modifications are not expected and this README is provided purely for
informational purposes.

## cti

The `cti` directory contains overrides and extensions for mkqnximage that
apply to all CTI targets.

## rpi5

The `rpi5` directory contains overrides and extensions for mkqnximage that
enable it to build images for a Raspberry PI 5.

