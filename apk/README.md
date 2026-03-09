# apk

## Overview

The apk folder contains the portion of the build that integrates software
packages from oss.qnx.com.  This is a new method of integrating QNX
and open source software prepackaged as binaries, similar to other package
managers in use in various Linux distributions.  In fact, apk is a port of
Alpine Linux's package manager to QNX.

## Installing apk packages

Installing apk packages for pre-installation in the image, and for source builds,
is currently managed by updating one or both of the following files:

- world.preinstall_aarch64
- world.preinstall_x86_64

### world.preinstall_x86_64 / world.preinstall_aarch64

These files contain the common apk packages for the two architectures we
currently support for the custom target images that can be built with this project.
Generally speaking, these are lists of high-level apk packages representing the
content to be installed in the image, but does not explicitly include all of the
dependencies pulled in by the highe-level packages.

The target-specific apk packages lists are located in the targets/< TARGET > folder
of the project, and are named based on the architecture of the target.  For example,
rpi5 is an aarch64 platform so its target-specific packages list is named
"world.preinstall_aarch64" as well.

These artifacts are pre-installed in the `apk/stage/apk_root` folder,
and snippets are generated for the content in `apk/stage/snippets` so that they
will be integrated into the image.  The consolidated world.preinstall file is
also integrated in the image, with the package versioning stripped out, and
it will be installed at `/etc/apk/world`,  so that end users have
the freedom to update the packages installed after their build is generated.

### apk repos

Currently there are a limited number of apk repos available that contain
packages to install in the image so this information is baked into the
Makefile.  We plan to generalize how to modify the repository information
in a future release so end users can build and host their own repositories
and point to them.
