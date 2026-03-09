# system

## Overview

The system folder can be used for files that are directly added to the system
partition, separately from binaries and configuration files that are part of
QNX Software Center packages, or open source projects that are downloaded and
built.  

Aside from a couple of exceptions, the relative path in the folder is usually
consistent with the relative file intended for the file to be placed in the
system partition, but this mapping is controlled by the snippet that includes
each file.

## Content

Generally speaking there are two types of files in this folder:

- customized system configuration files
- License files for include OSS

Note, root certificates for SSL downloads are downloaded during the build and
stored in this folder at: `system/etc/ssl/certs/`.

### Customized System Configuration Files

CTI images have a unique configuration that is closer to what Raspberry PI
users are accustomed to, rather than a configuration that would be more locked
down on a production device running QNX.

The following table points out where certain configuration files are located
in the folder:

| Configuration File Category                 | Relative Path                |
| ------------------------------------------  | ---------------------------- |
| SPI configuration                           | etc/config/spi               |
| camera / touchscreen configuration          | etc/system/config            |
| RPI4 camera / touchscreen configuration     | etc/system/config/rpi4       |
| RPI5 camera / touchscreen configuration     | etc/system/config/rpi5       |
| QEMU camera / touchscreen configuration     | etc/system/config/qemu       |
| USB launcher configuration                  | etc/usblauncher              |
| network configuration                       | etc                          |
| GPIO sample Python code                     | etc/gpio                     |
| Miscellaneous support scripts for desktop   | usr/bin                      |
| Desktop modifications for user .config      | desktop.config               |
| Desktop modifications for user .local       | desktop.local                |

Some of the customizations will be explored in more detail in the
[snippets](../snippets) README. However, users of this project can further
tailor the configuration to their preferences.

#### License Files

The folder, [usr/share/licenses](usr/share/licenses), contains license files
for each of the OSS projects that are built in the [src](../src) tree.

See the [src](../src) README for more details on how OSS projects get
integrated into the CTI.
