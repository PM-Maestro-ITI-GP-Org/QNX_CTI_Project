# targets

## Overview

The CTI build supports being built for multiple targets. Each supported target
has a subdirectory here, under the `targets` folder. The name of the
subdirectory is the name of the target specified to make.

The target specific subdirectories contain information required to build the
specific target, above and beyond the common steps that are done for all
targets.

## Supported targets
To discover what targets are currently supported, just get a list of all the
subdirectories under `targets`.

```bash
$ ls -1 targets
qemu
README.md
rpi4
rpi5
```

Ignoring this README.md file, the supported targets are:
- qemu
- rpi4
- rpi5

To build a target run `make` while specifying the name of the target's
subdirectory to a TARGET variable. For example, to build the rpi4 target:
```bash
make TARGET=rpi4
```

## Customization

To add a new target create a new subdirectory with a unique name and populate
the required files. There are four required files:
- qsc_install_packages.list
- variables.mk
- rules.mk
- mkqnximage.config

The purpose, and some information about these files is below.

### qsc_install_packages.list

A given target may required additional, or different, packages to be installed
into the local/separate installation of the SDP. The qsc_install_packages.list
file is responsible for this.

Any packages in this file are combined with the common set of pacakges
specified in the root [qsc_install_packages.list](../qsc_install_packages.list).
This combination is then used to drive the local SDP install.

If multiple versions of the same package is specified then QSC will install
the newest version specified. This way, specifying a newer package in a target's
`qsc_install_packages.list` file will cause QSC to install the newer version,
instead of the older version specified in the root `qsc_install_packages.list`.

### variables.mk

The build process requires a number of variables to be set by each target.
This helps configure the build process for the target being built. These
variables are specified in the `variables.mk` file.

The following variables MUST be set:
- ALL_TARGET
- QNX_ARCH
- QNX_ARCHDIR

In addition, the file is free to set any other variables that need to exist
at the top level of the build process. These new variables will not be
automatically exported to sub-makes. If this is required, then they should
be exported here, in the variables.mk file.

#### ALL_TARGET
The name of the 'final' make target that gets generated. This is usually the
final image that is produced by the build process. The contents of this variable
get added to the `all` makefile target automatically.

Eg:
```bash
all: $(ALL_TARGET)
```

#### QNX_ARCH
The architecture of the target. Usually one of either:
- aarch64
- x86_64

#### QNX_ARCHDIR
The name of the directory that holds architecture specific files in the SDP,
and the [src](../src) tree's stage.

The value is sometimes the same as `QNX_ARCH` but not always. For example, the
`aarch64` architecture has a directory named `aarch64le`.

### rules.mk

This file defines whatever makefile targets and rules are required to build
the 'final' makefile target. This file MUST contain rules for at least the
makefile target defined by the `ALL_TARGET` variable in the `variables.mk` file
for the target.

It can also define any additional makefile targets and rules that are necessary
to produce the `final` makefile target. 

The 'final' makefile target MUST depend on at least the `TARGET_BASE_DEPS`
variable. This will ensure that all the common parts of the CTI build process
execute before the `final` makefile target is built.

### mkqnximage.config

The configuration file passed to mkqnximage. See the **Configuration files**
section of the
[mkqnximage](https://www.qnx.com/developers/docs/8.0/com.qnx.doc.neutrino.utilities/topic/m/mkqnximage.html)
documentation for details.
