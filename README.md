# Custom Target Image Builds - QNX 8.0

## Add ur work

run these in the repo already on ur pc

```bash
git remote rename origin upstream
git remote add origin git@github.com:PM-Maestro-ITI-GP-Org/QNX_CTI_Project.git
```

then commit your work:

```bash
git add .
git commit -m "added project files"
```

get the latest changes from the main branch of the original repo:

```bash
git fetch origin
git pull origin release/QNX_Developer_Desktop_Release2  
```

create a new branch for your work:

```bash
git checkout -b main
git push -u origin main
```

### Correct way to clone (submodules)

Always clone with submodules:

```
git clone --recurse-submodules git@github.com:PM-Maestro-ITI-GP-Org/QNX_CTI_Project.git
```

------

### If you already cloned the repo

Run this inside the repo:

```
git submodule update --init --recursive
```

This will fetch:

- `src` (mid repo)
- `ota-update` (nested submodule inside src)

## Overview

This project allows QNX developers to build their own custom target images for
RaspBerry Pi 4, RaspBerry Pi 5, and QEMU (x86_64).  The default configuration
generates the corresponding Quick Start Image that is released on QNX Software
Center at the same time as this release.  However, this project is different
from the existing Quick Start Images, in that it can be customized to generate
a target image that suits your needs.

Note: the custom target images generated with this project now include
the QNX Developer Desktop by default.

As an accepted SOAFEE Blueprint, this project helps to standardize how software can 
be developed, deployed, and managed on hardware targets. 

## Contents

- [Hardware Requirements](#hardware-requirements)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Using the Image](#using-the-image)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## <a name="hardware-requirements"></a> Hardware requirements

For either the PI4 or PI5 targets you'll need:

- Raspberry Pi 4 - 2GB model or higher OR a Raspberry Pi 5
- Micro SD card - 8GB or more
- (Optional) USB keyboard
- (Optional) USB mouse
- (Optional) HDMI display and micro HDMI to HDMI cable (or touchscreen and
             micro HDMI to HDMI and USB dual cable)
- (Optional) USB-TTL converter
- (Optional) Camera

## <a name="prerequisites"></a> Prerequisites

### Linux Utilities

This project can only be built on Linux hosts at the present time, and it
requires some utilities to build correctly.

Please run the command below to install required utilities for building
successfully (the command below works with Ubuntu Linux hosts):

Install QEMU

Ubuntu 22.04

```bash
sudo apt install qemu qemu-system-x86 qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```

Ubuntu 24.04

```bash
sudo apt install qemu-system qemu-utils qemu-user qemu-user-binfmt libvirt-daemon-system libvirt-clients bridge-utils
```

and install other dependencies for other open source project builds:

```bash
sudo apt install automake bridge-utils cmake curl g++ git imagemagick libglib2.0-bin libglib2.0-dev libssl-dev libtool libwayland-bin libzstd-dev lua-zlib lua-zlib-dev make ncat ninja-build pax-utils pkg-config python3-pip sassc scdoc texinfo unzip wget
pip3 install gi-docgen markdown packaging pygments strenum toml tomli typogrify
```

### QNX Software

A QNX Software Development Platform (version 8.0) license and an installation
of the QNX Software Center (QSC) is required to build this project. If you do
not already have these, follow the steps below before proceeding with the
steps in the next section:

1. Get a free, non-commercial QNX Software Development Platform 8.0 license at
   [https://www.qnx.com/getqnx]( https://www.qnx.com/getqnx).
2. Accept and deploy your license.
3. Install the QNX Software Center (QSC). The QSC allows users to install the
   QNX SDP and pre-built packages.

**NOTE** It is ok to have your own local SDP installed, and even sourced into
         the same terminal as the one you will use to build the CTI. It will
         not be used or impact the CTI build process.

## <a name="getting-started"></a> Getting Started

1. Clone this repo and navigate into the project folder.

2. Export path to the qnxsoftwarecenter_clt executable (modify accordingly to
   your installation location)

    ```bash
    export QSC_CLT_PATH=$HOME/qnx/qnxsoftwarecenter/qnxsoftwarecenter_clt
    ```

3. Create a file called "options_file" and populate it with:

    ```bash
    -myqnx.user
    <username>
    -myqnx.password
    <password>
    ```

   (Replace the placeholders with your qnx.com credentials)

   This file is used to provide your credentials to QNX Software Center (QSC)
   to install required packages locally for the image build. Take care not to
   share this file with others or commit it to a fork of this project.

Once the above steps are performed, execute make while specifying your desired
target.

### Building RPi4

```bash
make TARGET=rpi4
```

If the build is successful, it will produce the image file
**build/rpi4/rpi4.img**.

### Building RPi5

```bash
make TARGET=rpi5
```

If the build is successful, it will produce the image file
**build/rpi5/rpi5.img**.

### Building QEMU

```bash
make TARGET=qemu
```

If the build is successful, it will produce the image file
**build/qemu/output/disk-qemu**. However this image file alone is not enough
to allow mkqnximage to start QEMU emulation. Please see the "Moving QEMU"
section below if you want to move or copy the generated emulator image.

#### QEMU Build Options

Several options can be specified to make to control how the QEMU image is
generated. These can be specified either as environment or makefile variables.

Once set the option persists until the image is rebuilt.

##### CTI_QEMU_CPU

This options controls the number of (virtual) CPUs QEMU creates.

The default value for CTI_QEMU_CPU when it is not specified is 2.

To create an image with a different number of CPUs set a specific value at
build time. For example to create an image with four CPUs:

```bash
make TARGET=qemu CTI_QEMU_CPU=4
```

##### CTI_QEMU_RAM

This option controls the amount of RAM provides to the guest. It is a numeric
value followed by a single letter suffix. Valid suffixes are:

- M == Megabytes
- G == Gigabytes

The default value for CTI_QEMU_RAM is 1G.

To create an image with a different amount of RAM set a value at build time.
For example to create an image with 3096MB of RAM:

```bash
make TARGET=qemu CTI_QEMU_RAM=3096M
```

### Build Notes

The first time you build, it will take some time, roughly 30 minutes or longer
depending on your Internet connection speed.

Some noteworthy items to be aware of:

- A separate installation of the QNX Software Development Platform (SDP) is
  installed within the project folder. This separate SDP installation is also
  used to build the open source projects integrated into the build.
- Due to the size of asset packages and projects that are downloaded from the
  Internet, you will likely need approximately 10 GB of free disk space.
- During the build, you will see output from the different integration download
  and build steps in each of the project subfolders, as the build proceeds.
  This is normal and expected.  Some of the steps seen in the initial build are
  skipped in later builds, because the required artifacts have been downloaded
  and unpacked in previous builds.

If the build is successful, an image file appropriate for the target is
produced in the target's build directory.

- For RPi4: **build/rpi4/rpi4.img** is produced
- For RPi5: **build/rpi5/rpi5.img** is produced
- For QEMU: **build/qemu/output/disk-qemu** is produced, but see the
  "Moving QEMU" section below.

If the image generation is not successful, refer to the Troubleshooting
section below for more details on how to resolve.

## <a name="using-the-image"></a> Using the Image

How the image produced by the build process is used depends on the target.

### Flashing the image to an RPi4 or RPi5

The image file produced by the build process can be flashed using rpi-imager.

Instructions for doing so are available in the [Flashing the image to a micro SD card](https://www.qnx.com/developers/docs/qnxeverywhere/com.qnx.doc.target_images/topic/qsti/install.html#flashing)
section of the Quick start target image guide.

### Starting QEMU

The easiest way to use the resulting QEMU image is to use mkqnximage to start,
and control, qemu. You will need to source the QNX dev environment into your
path to access mkqnximage. An appropriate SDP environment would have been
installed into the **qnx800** folder.

```bash
source qnx800/qnxsdp-env.sh
cd build/qemu
mkqnximage --run
```

**NOTE** Generally any 8.0.x SDP will provider the required mkqnximage support.
         Thus if you have a personal 8.0.x SDP installed you can use it instead
         of the one installed into qnx800 for the CTI build.

The terminal used to start qemu will become a serial console.
To get the IP address you can either:

- Use the serial console to run `ifconfig`
- Read the IP address off the display once it updates
- Use `mkqnximage --getip` from a different terminal from within the same
  build/qemu directory.

To exit from QEMU you can either enter "ctrl-a x" into the serial console,
or execute `mkqnximage --stop` in a different terminal from the same
build/qemu directory.

### Moving QEMU

Unlike other builds, the QEMU target does not produce a single image file that
can be moved or copied to different locations. Most of the directory structure
under **build/qemu** must be moved/copied in order for mkqnximage to start
QEMU properly.

Due to this, be sure to move/copy the following directories from build/qemu
in their entirety. The two directories should always be co-located.

- build/qemu/local
- build/qemu/output

So for example if you wanted to create an archive to pass around:

```bash
tar czvf /tmp/cti_qemu.tar.gz -C build/qemu local output
```

## <a name="customization"></a> Customization

This project has been designed so that the content integrated into the image
can be modified to suit your needs.

This section will serve as a guide pointing to additional READMEs in the
project folders that document the customizations possible:

### Resizing Partitions

> As you customize this project with additional assets and open source
> software, you may need to increase the size of the **system** partition.
> The **data** partition may also need to be resized if assets are integrated
> into the data partition for users.

The maximum partition sizes are defined in the target's config file.

### RPi4 and RPi5

The configuration file for RPi4 is [targets/rpi4/mkqnximage.config](targets/rpi4/mkqnximage.config).
The configuration file for RPi5 is [targets/rpi5/mkqnximage.config](targets/rpi5/mkqnximage.config).

In either case, this line controls the partition sizes:

```bash
OPT_PART_SIZES='800:10240:32000'
```

The first number controls the boot partition size, the second number controls
the system partition size and the third number controls the data partition size.
The third size is optional, as the default behavior is to create a data
partition that fills the available space.

The numbers represent multiples of 2048 sectors, that are 512 bytes in size,
or equivalent to the number of megabytes.

The above sizing is meant to fit on a 32 GB SD card (the data size partition
is slightly too large, but the boot mechanism that creates the file system
partitions ensures that the actual partition size does not exceed what is
available on the SD Card).

If you find that the default partitions are too small to hold the extra
software you are trying to pre-install or install after the image is
produced, you can modify the partiton sizes and run the build again to
get a larger image but you need to ensure you have a large enough SD card
to write it successfully.   Note that software packages install files in both
/usr and /data partitions but the main binaries are being installed in /usr
so that partition should be resized first to add extra room for pre-installed
or dynamically installed software after imaging.

Note that increasing either the system partition size or data partition size
will not generate a larger overall image size. However, integrating extra
content will increase the size of the generated image file proportionally to
the size of the extra content integrated.  The exception to that is for the
/usr and boot partitions, which will cause image size increase proportional
to the partition sizes, and not their content.

### QEMU

The configuration file for QEMU is [targets/qemu/mkqnximage.config](targets/qemu/mkqnximage.config).

The system parition size is controlled by the line:

```bash
OPT_SYS_SIZE=10240
```

The data parition size is controlled by the line:

```bash
OPT_DATA_SIZE=32000
```

If you find that the default partitions are too small to hold the extra
software you are trying to pre-install or install after the image is
produced, you can modify the partiton sizes and run the build again to
get a larger image.

Note that the virtual disk created for QEMU is equal in size to the sum of all
the partitions. This is regardless of how much space is actually used by the
data in the partition.

### Adding / Changing QNX Software Center (QSC) Packages

The QNX SOftware Center (QSC) Command Line Tool is used to install a local
SDP into **qnx800** that will be used to build the desired target image. The
tool is provided an explicit list of packages, and their associated versions,
to install. Since this list depends on the target being built, switching
between targets may cause the local SDP to be re-installed.

You can customize the list of packages that are installed from QSC by modifying
the appropriate qsc_install_packages.list files.

> It is highly recommended that no attempt is made to remove QSC packages until
> you are more familiar with the project, and understand the purpose of the
> packages included by default and know how to rollback a change to get back
> to a stable state.

Just installing new packages from QSC is usually not sufficient for the
contents of those packages to be added to the resulting CTI image. Any new
files will need to be explicitly added to the image by modifying an appropriate
snippet file. Please see the [snippets](snippets) and [system](system) READMEs
for more details on which snippets will need to be modified, and how t
modify them.

> If you clean your project and rebuild after removing packages without
> updating snippets, you will likely encounter warnings/errors of missing files
> preventing the image from being created.  The only way to get past this is to
> find the entries in the snippets for those files and removing them.

To learn more about how the QNX Software Center (QSC) Command Line Tool can be
used, see the online [documentation](https://www.qnx.com/developers/docs/qsc/com.qnx.doc.qsc.user_guide/topic/commandline_qsc.html)
to learn more about the tool.

#### qsc_install_packages.list

This file contains the base list of packages that are required to build all
targets. If you want to add things to all targets this is the file you
would want to modify.

#### targets/<< target >>/qsc_install_packages.list

This file contains the list of packages that are relevant to the specific
target. It is processed after the qsc_install_pacakges.txt file in the root
of the repo. If you want to add something to a specific target, say something
to support HW specific to the target, this is the file you would want to modify.

## Sub-folders

### apk

The apk folder contains the portion of the build that integrates software
packages from oss.qnx.com.  This is a new method of integrating QNX
and open source software prepackaged as binaries, similar to other package
managers in use in various Linux distributions.  In fact, apk is a port of
Alpine Linux's package manager to QNX.

See the [apk](apk) folder README for more details regarding what it does
and some of the customizations possible.

### boot

The boot folder manages files that are added to the boot partition. Some files
are already present in the repo, others are downloaded from the internet and
then cached locally.

This partition gets mounted to **/boot** when the target is running.

See the [boot](boot) folder README for more details regarding what it does
and some of the customizations possible.

> The QEMU target does NOT have a boot partition and thus this folder is not
> used during the QEMU target's build.

### assets

The assets folder Makefile integrates additional fixed assets, such as fonts
and icons, into the image. Some files are already present in the repo, others
are downloaded from the internet and then cached locally.

See the [assets](assets) folder README for more details regarding what it does
and some of the customizations possible.

### src

The src folder Makefile controls what open source projects are downloaded,
built and readied for integration into the image.

See the [src](src) folder README for more details regarding what it does and
some of the customizations possible.

### snippets

The snippets folder contains snippets of build files that are combined with
some boilerplate build segments to generate final build files for the three
partitions:

- boot
- data
- system

These three partitions are then combined to create the final image.

See the [snippets](snippets) folder README for details regarding some of the
customizations possible.

### system

The system folder contains files that are placed into the resulting
system partition. These are usually configuration files of one kind or another.

See the [system](system) folder README for details regarding some of the
customizations possible.

## <a name="troubleshooting"></a> Troubleshooting

### Authentication Errors from QNX Software Center

If you see a build failure during QNX Software Center package installationu
that looks like this:

```bash
/home/devuser/qnx/qnxsoftwarecenter/qnxsoftwarecenter_clt -mirrorBaseline qnx800 @options_file
Info: Mirroring repositories: remote server https://www.qnx.com/swcenter
Info: Generating metadata for dropins-repo.
Info: Generation completed with success [0 seconds].
Info: Generating metadata for seeds-q2-repo-devuser_-www_qnx_com_80_swcenter.
Error: publishing result: Server synchronization failed: Authentication failed, check credentials and try again;
Error: Failed to synchronize repositories: Failed to retrieve package metadata from seeds-q2-repo-devuser_org-www_qnx_com_80_swcenter
make: *** [qsc_packages.mk:46: /home/devuser/work/raspberry-pi-4-qnx-8.0/qnx800] Error 1
```

it means that an error with the options_file during step 3 of the
[Getting Started](#getting-started) section.  Re-read the instructions,
correct the information and then run:

```bash
make TARGET=<target> clean
```

and then re-run:

```bash
make TARGET=<target>
```

to restart the build.

### Build QNX SDP Installation Error

In the course of installing the local SDP installation at the beginning of the
build, an error in the qsc_install_packages.list file, resulting from
customization, may result in the deletion of the existing SDP 8.0 installation
directory at $HOME/qnx800. If this happens, please utilize the Verify and Repair
functionality of QNX Software Center, as per:

[https://www.qnx.com/developers/docs/qsc/com.qnx.doc.qsc.user_guide/topic/repair_packages.html](https://www.qnx.com/developers/docs/qsc/com.qnx.doc.qsc.user_guide/topic/repair_packages.html)

to repair that SDP installation first.  Before trying the build again, double
check the changes made to the various qsc_install_packages.list files and
correct the error(s) that triggered this deletion to prevent it from recurring
on your next attempt to build the project.

It is recommended that you run:

```bash
make TARGET=<target> clean
```

and then run:

```bash
make TARGET=<target>
```

to rebuild the project.

### Missing Prerequisites

Fatal errors might occur during the assets or open source integrations in your
first attempt to build if you missed one of the prerequisite steps listed above.

Try the following remedy:

1. Repeat the prerequisite installation commands one more time.

2. Note that on Linux hosts running older Ubuntu distributions, this command
   may also need to be executed as well:

    ```bash
    sudo apt install python3-distutils
    ```

3. It is recommended that you run:

    ```bash
    make TARGET=<target> clean
    ```

4. Run:

    ```bash
    make TARGET=<target>
    ```

to try building the image again.

### Customization Missed Steps

Once you start customizing the project, fatal errors can and will likely happen
in the section your are customizing. As you start adding the steps to integrate
new open source projects or assets, especially if you miss a step, or something
unexpected occurs as you are trying to build a project being integrated.

This is normal and expected.

Try the following remedy:

1. Fix the Make target by adding the missing step(s).

2. It is recommended that you run:

    ```bash
    make TARGET=<target> clean
    ```

    to reset back to a clean initial state, but you can also be more precise,
    and clean only certain folders.  For example, to clean only the src folder,
    run:

    ```bash
    make TARGET=<target> -Csrc clean
    ```

3. Run:

    ```bash
    make TARGET=<target?
    ```

### Missing File Warnings

The last step of the build generates the image. If something went wrong earlier
in the build process, or a snippet change for customization is incorrectd,
you will see warnings printed indicating that files that are expected to be
integrated are missing.

These warnings should not happen the first time you build, with no
customizations, so earlier troubleshooting steps may help with first time
build errors.

If you see missing file warnings while in the midst of customizing, this would
indicate that one of your snippets changes is incorrect, likely that the
relative path inside the project folder is incorrect. Recheck your snippets
changes and then try the remedy above to proceed.

> The final .build files that are used to generate the partitions can be found
> in build/<< target >>/output/build. When chasing problems with missing or
> unexpected files in a generated partition, it often helps to check the
> appropriate build file to find the problem, then work backwards to find the
> snippet that contains the error.
