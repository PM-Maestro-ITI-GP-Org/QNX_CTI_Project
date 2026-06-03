# Cross-Compiling a Qt6 Quick App for QNX RPi5

This guide documents the complete process of cross-compiling a Qt6 Quick application and deploying it onto a QNX 8.0 image for Raspberry Pi 5, using the QNX Custom Target Image (CTI) build system.

------

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Project Structure](#2-project-structure)
3. [APK Packages — Adding Qt6 Libraries](#3-apk-packages--adding-qt6-libraries)
4. [The Cross-Compile Makefile](#4-the-cross-compile-makefile)
5. [Adding Your App to the Image (Snippet)](#5-adding-your-app-to-the-image-snippet)
6. [Building the Image](#6-building-the-image)
7. [Running the App on the RPi5](#7-running-the-app-on-the-rpi5)
8. [Troubleshooting Reference](#8-troubleshooting-reference)

------

# The result

working qt app on qnx rpi 5:

![image-20260516210356987](assets/image-20260516210356987.png)

## 1. Prerequisites

### On your Linux host machine

You need the following installed before starting:

```bash
# QNX SDP 8.0 must already be installed via QNX Software Center
# The CTI repo must be cloned and a base image must build successfully

# Host Qt6 — same version as the APK Qt6 packages (e.g. 6.10.x)
# Install via Qt online installer or:
sudo apt install qt6-base-dev

# CMake 3.16 or later
cmake --version

# General build tools
sudo apt install ninja-build nproc
```

### Your app's CMakeLists.txt must use `qt_add_qml_module`

This embeds QML files **inside the binary as resources**, which means you do not need to deploy `.qml` files separately to the target. If your app uses `qt_add_qml_module`, the QML is already baked in. Example:

```cmake
qt_add_qml_module(appCalculatorApp
    URI CalculatorApp
    QML_FILES
        Main.qml
        CalcButton.qml
    SOURCES
        Calculator.h
        Calculator.cpp
)
```

> **Why this matters:** If QML files are NOT embedded, the app will show a black screen at runtime because the QML engine cannot find them on the target filesystem.

------

## 2. Project Structure

Inside the CTI repo (`QNX_Snippets_repo/`), the relevant folders are:

```
QNX_Snippets_repo/
├── apk/
│   └── apk_packages.list       ← add Qt6 APK packages here
├── src/
│   ├── Makefile                ← existing, add one include line
│   ├── addcustomapps.mk        ← NEW: your cross-compile rules
│   └── qnx_math_fix.h          ← NEW: fixes QNX/Qt6 math.h conflict
├── snippets/                   ← add your app binary snippet here
└── targets/rpi5/
    └── mkqnximage.config       ← resize partitions if needed
```

Your application source lives **outside** the CTI repo — the makefile references it by absolute path. This is intentional so your app has its own git history separate from the image build system.

```
/home/zee/ITI_Files/QT/QT_Cpp_GUIs/CalculatorApp/   ← app source (outside CTI)
```

------

## 3. APK Packages — Adding Qt6 Libraries

The APK system (Alpine Package Manager ported to QNX) installs pre-built Qt6 libraries into the image automatically. You do **not** need to write snippet entries for Qt libraries manually — the APK system generates them.

### Add these lines to `apk/apk_packages.list`:

```
qt6-base=6.10.0-r1
qt6-declarative=6.10.0-r0
qt6-tools=6.10.0-r0

# these are the ones which worked with me
qt6-base=6.10.0-r1
qt6-base-dev=6.10.0-r1
qt6-declarative=6.10.0-r0
qt6-declarative-dev=6.10.0-r0
qt6-tools=6.10.0-r0
qt6-tools-dev=6.10.0-r0
```

- `qt6-base` — QtCore, QtGui, QtNetwork, platform plugins (`libqqnx.so`)
- `qt6-declarative` — QtQml, QtQuick, QtQuickControls2
- `qt6-tools` — MOC, RCC, UIC (needed at build time on host)

> **Version pinning:** Always pin exact versions (`=6.10.0-r1`) for reproducible builds. The APK system will use these exact packages every time, even if newer versions are published.

After adding these, verify the Qt libraries are installed in the APK stage after your next build:

```bash
find apk/stage/apk_root/usr/lib -name "libQt6*" | head -10
```

You should see `libQt6Core.so`, `libQt6Gui.so`, `libQt6Quick.so`, etc.

------

## 4. The Cross-Compile Makefile

### 4.1 The math.h fix header

Create `src/qnx_math_fix.h`:

```c
#pragma once
// QNX's <math.h> defines isnan, isinf, isfinite as C macros.
// Qt6 headers call them as std::isnan(...) which the C preprocessor
// corrupts into invalid syntax. Undefining them after any math.h
// include restores the correct std:: namespace versions.
// Do NOT include <cmath> here — that must happen in the right order
// inside each source file.
#undef isnan
#undef isinf
#undef isfinite
#undef signbit
#undef isnormal
#undef fpclassify
```

> **Why this exists:** QNX 8.0 defines math classification functions as macros in `<math.h>`. Qt6 headers use them as `std::isnan(x)`. When the C preprocessor expands the macro first, it turns `std::isnan(x)` into `std::__isnan(x)` or similar garbage — producing hundreds of "expected unqualified-id" errors. The `-U` flags passed via `CMAKE_CXX_FLAGS` undefine them at compile time for every translation unit.

### 4.2 The cross-compile makefile

Create `src/addcustomapps.mk`:

```makefile
# =============================================================================
# addcustomapps.mk — Cross-compile custom Qt6 apps for QNX CTI
#
# HOW IT WORKS:
#   Make uses "stamp files" in src/source/ to track build steps.
#   A stamp file is an empty file whose existence means "this step is done".
#   This avoids re-running expensive builds (clone, cmake, compile) every time
#   you run `make TARGET=rpi5`.
#
#   Flow:
#     make TARGET=rpi5
#       └─> src/Makefile
#               └─> include addcustomapps.mk
#                       └─> source/myapp-built-aarch64  (stamp)
#                               ├─> cmake configure
#                               ├─> cmake build (cross-compile)
#                               └─> cmake install -> src/stage/nto/aarch64le/
# =============================================================================

# -----------------------------------------------------------------------------
# Resolve the CPU target string used by QNX's qcc/q++ compilers.
# QNX_ARCH is exported by qnxsdp-env.sh as "aarch64" for RPi5, "x86_64" QEMU.
# CC_TARGET adds the ABI suffix: "aarch64le" or "x86_64"
# -----------------------------------------------------------------------------
ifeq ($(TARGET),qemu)
    CC_TARGET = x86_64
else
    CC_TARGET = $(QNX_ARCH)le
endif

# -----------------------------------------------------------------------------
# Key paths used throughout this file.
#
# STAGE_DIR   — where cmake installs the compiled binary.
#               The snippet references this path as ${SRC}/stage/...
# APK_STAGE   — where Qt6 libs, headers, cmake configs live (installed by APK)
# HOST_MAKE   — the make binary (cmake needs an explicit path on QNX hosts)
# QNX_TARGET_DIR — QNX SDP target headers (libc++, POSIX headers)
# QT_HOST_PATH   — your host Linux Qt6 installation (same version as APK Qt6)
#                  Required by Qt6's cross-build cmake toolchain for host tools
#                  like moc, rcc, qmlcachegen.
# -----------------------------------------------------------------------------
STAGE_DIR      = $(CURDIR)/stage/nto/$(CC_TARGET)/usr
APK_STAGE      = $(CURDIR)/../apk/stage/apk_root/usr
HOST_MAKE     := $(shell which make)
QNX_TARGET_DIR = $(CURDIR)/../qnx800/target/qnx
QT_HOST_PATH  ?= /home/zee/Qt/6.10.2/gcc_64

# -----------------------------------------------------------------------------
# C compiler wrapper generator.
#
# QNX's compiler (qcc) is not called like gcc. CMake expects a standard
# compiler path. This wrapper script translates CMake's calls into the
# correct QNX cross-compile invocation:
#   -Vgcc_nto<target>   selects the QNX/GCC variant for aarch64 or x86_64
#   -D_QNX_SOURCE       enables QNX-specific POSIX extensions
#
# The wrapper is written into the app's source directory and recreated on
# every build to avoid stale paths from previous builds.
# -----------------------------------------------------------------------------
define make_c_wrapper
	@echo '#!/bin/bash' > $(1)/qcc-wrapper.sh
	@echo 'exec qcc -Vgcc_nto$(CC_TARGET) -D_QNX_SOURCE $(2) "$$@"' \
	    >> $(1)/qcc-wrapper.sh
	@chmod +x $(1)/qcc-wrapper.sh
endef

# -----------------------------------------------------------------------------
# C++ compiler wrapper generator.
#
# Additional flags beyond the C wrapper:
#   -Vgcc_nto<target>_cxx       selects the C++ variant
#   -D_HAS_CONDITIONAL_EXPLICIT=0  suppresses a libc++ compatibility warning
#   -std=c++17                  Qt6 requires C++17
#   -isystem <path>             adds QNX libc++ headers at SYSTEM priority
#                               (lower than project headers, correct order)
#
# Using -isystem instead of -I is critical: it puts libc++ headers before
# the C standard library headers in the search order, which prevents the
# <cstddef>/<cmath> "didn't find libc++'s header" errors.
# -----------------------------------------------------------------------------
define make_cxx_wrapper
	@rm -f $(1)/qxx-wrapper.sh
	@echo '#!/bin/bash' > $(1)/qxx-wrapper.sh
	@echo 'exec q++ \
		-Vgcc_nto$(CC_TARGET)_cxx \
		-D_QNX_SOURCE \
		-D_HAS_CONDITIONAL_EXPLICIT=0 \
		-std=c++17 \
		-isystem $(QNX_TARGET_DIR)/usr/include/c++/v1 \
		-isystem $(QNX_TARGET_DIR)/usr/include \
		-isystem $(QNX_TARGET_DIR)/$(CC_TARGET)/usr/include \
		$(2) "$$@"' \
		>> $(1)/qxx-wrapper.sh
	@chmod +x $(1)/qxx-wrapper.sh
endef

# =============================================================================
# App: CalculatorApp
#
# Source lives outside the CTI repo. Change MYAPP_DIR to your actual path.
# After cmake install, the binary lands at:
#   src/stage/nto/aarch64le/usr/bin/appCalculatorApp
# The snippet then pulls it into the image at:
#   /system/usr/bin/appCalculatorApp
# =============================================================================
MYAPP_DIR  = /home/zee/ITI_Files/QT/QT_Cpp_GUIs/CalculatorApp
MYAPP_DEPS =

# -----------------------------------------------------------------------------
# Stamp 1: source/myapp-ready
# Verifies the source directory exists. For a GitHub-hosted app you would
# add a `git clone` here. Since the source is local, we just check it exists.
# Creates: src/source/myapp-ready (empty stamp file)
# -----------------------------------------------------------------------------
source/myapp-ready:
	@mkdir -p source
	@if [ ! -d "$(MYAPP_DIR)" ]; then \
	    echo "ERROR: $(MYAPP_DIR) does not exist."; \
	    exit 1; \
	fi
	@touch $@

# -----------------------------------------------------------------------------
# Stamp 2: source/myapp-built-$(QNX_ARCH)
# The main build step. Depends on myapp-ready and any library stamps.
#
# What each cmake flag does:
#   CMAKE_SYSTEM_NAME=QNX           tells cmake this is a cross-compile
#   CMAKE_C/CXX_COMPILER            our wrapper scripts (not gcc/g++ directly)
#   CMAKE_INSTALL_PREFIX            where "cmake install" puts the binary
#   CMAKE_PREFIX_PATH               where find_package() searches for Qt6
#   Qt6_DIR                         explicit path to Qt6Config.cmake
#   CMAKE_MAKE_PROGRAM              explicit make path (required for QNX host)
#   QT_HOST_PATH                    host Qt6 for moc/rcc/qmlcachegen tools
#   CMAKE_CXX_FLAGS -U...           undefine QNX math macros (see math fix)
#   CMAKE_FIND_ROOT_PATH            sysroot paths for cross-compile search
#   CMAKE_FIND_ROOT_PATH_MODE_*     ONLY=never search host, BOTH=search both
#   HAVE_EGL/GLESv2=TRUE            bypass cmake's EGL/GLES compile probe
#   EGL_*/GLESv2_* paths            explicit EGL/GLES locations in APK stage
#   CMAKE_EXE_LINKER_FLAGS          linker flags including rpath-link for
#                                   transitive Qt6 dependencies (xkbcommon,
#                                   harfbuzz, freetype, etc.) that exist on
#                                   the target but not the host sysroot.
#                                   --allow-shlib-undefined lets the linker
#                                   succeed even if transitive deps are missing
#                                   at link time (they resolve at runtime).
#
# Creates:
#   MYAPP_DIR/build/           cmake build directory
#   MYAPP_DIR/qcc-wrapper.sh   C cross-compiler wrapper
#   MYAPP_DIR/qxx-wrapper.sh   C++ cross-compiler wrapper
#   STAGE_DIR/bin/appCalculatorApp   final installed binary
# -----------------------------------------------------------------------------
source/myapp-built-$(QNX_ARCH): source/myapp-ready $(MYAPP_DEPS)
	@rm -f $(MYAPP_DIR)/qcc-wrapper.sh $(MYAPP_DIR)/qxx-wrapper.sh
	$(call make_c_wrapper,$(MYAPP_DIR),\
	    -L$(STAGE_DIR)/lib \
	    -L$(APK_STAGE)/lib)
	$(call make_cxx_wrapper,$(MYAPP_DIR),\
	    -L$(STAGE_DIR)/lib \
	    -L$(APK_STAGE)/lib)

	rm -rf $(MYAPP_DIR)/build
	cmake -B $(MYAPP_DIR)/build -S $(MYAPP_DIR) \
		-DCMAKE_SYSTEM_NAME=QNX \
		-DCMAKE_C_COMPILER=$(MYAPP_DIR)/qcc-wrapper.sh \
		-DCMAKE_CXX_COMPILER=$(MYAPP_DIR)/qxx-wrapper.sh \
		-DCMAKE_INSTALL_PREFIX=$(STAGE_DIR) \
		-DCMAKE_PREFIX_PATH="$(STAGE_DIR);$(APK_STAGE)" \
		-DQt6_DIR=$(APK_STAGE)/lib/cmake/Qt6 \
		-DCMAKE_MAKE_PROGRAM=$(HOST_MAKE) \
		-DQT_HOST_PATH=$(QT_HOST_PATH) \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_FLAGS="-Uisnan -Uisinf -Uisfinite -Usignbit -Uisnormal -Ufpclassify" \
		-DCMAKE_FIND_ROOT_PATH="$(APK_STAGE);$(STAGE_DIR)" \
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH \
		-DHAVE_EGL=TRUE \
		-DHAVE_GLESv2=TRUE \
		-DEGL_INCLUDE_DIR:PATH=$(APK_STAGE)/include \
		-DEGL_LIBRARY:FILEPATH=$(APK_STAGE)/lib/libEGL.so \
		-DGLESv2_INCLUDE_DIR:PATH=$(APK_STAGE)/include \
		-DGLESv2_LIBRARY:FILEPATH=$(APK_STAGE)/lib/libGLESv2.so \
		-DCMAKE_EXE_LINKER_FLAGS="-L$(APK_STAGE)/lib -L$(STAGE_DIR)/lib -Wl,--allow-shlib-undefined -Wl,-rpath-link,$(APK_STAGE)/lib" \
		-DCMAKE_SHARED_LINKER_FLAGS="-L$(APK_STAGE)/lib -L$(STAGE_DIR)/lib -Wl,--allow-shlib-undefined -Wl,-rpath-link,$(APK_STAGE)/lib"

	cmake --build $(MYAPP_DIR)/build --parallel $(shell nproc)
	cmake --install $(MYAPP_DIR)/build
	@touch $@

# -----------------------------------------------------------------------------
# Aggregate target: mycustomapps
#
# Lists all app stamp files as dependencies. Add new apps here.
# This target is called by src/Makefile via: all: mycustomapps
# -----------------------------------------------------------------------------
source/mycustomapps-ready:
	@mkdir -p source
	@touch $@

source/mycustomapps-built-$(QNX_ARCH): source/mycustomapps-ready source/myapp-built-$(QNX_ARCH)
	@echo "custom apps: all built."
	@touch $@

.PHONY: mycustomapps mycustomapps-clean

mycustomapps: source/mycustomapps-built-$(QNX_ARCH)

# -----------------------------------------------------------------------------
# Clean target
# Removes stamps and build artifacts. Does NOT delete source files.
# Run: make TARGET=rpi5 -Csrc mycustomapps-clean
# Then: make TARGET=rpi5
# -----------------------------------------------------------------------------
mycustomapps-clean:
	rm -f  source/mycustomapps-ready
	rm -f  source/mycustomapps-built-$(QNX_ARCH)
	rm -f  source/myapp-ready
	rm -f  source/myapp-built-$(QNX_ARCH)
	rm -rf $(MYAPP_DIR)/build \
	       $(MYAPP_DIR)/qcc-wrapper.sh \
	       $(MYAPP_DIR)/qxx-wrapper.sh
```

### 4.3 Hook into `src/Makefile`

Add these two lines at the bottom of `src/Makefile`:

```makefile
include addcustomapps.mk

# ai suggested this:    
all: mycustomapps

# but i used this:
# append your package name "mycustomapps" to the PKGS variable
PKGS = thorvg lottie-screen_thorvg simple-terminal boost commonapi_someip commonapi vsomeip mycustomapps
```

The `-include` (with dash) would make it optional. Without the dash it is required — use whichever fits your team's workflow.

------

## 5. Adding Your App to the Image (Snippet)

Snippets are the mechanism that tells `mkqnximage` which files to include in each partition of the final image. Your app binary needs one entry.

Add to `snippets/system-extra.build` (or create it if it doesn't exist):

```
# Calculator app binary
# uid=0 gid=0 perms=0755 sets ownership to root and makes it executable
# Left side  = destination path inside the image (/system/usr/bin/)
# Right side = source path relative to the CTI repo root
[uid=0 gid=0 perms=0755] usr/bin/appCalculatorApp = stage/nto/aarch64le/usr/bin/appCalculatorApp
```

> **How snippets work:** The CTI build system collects all `.build` files from `snippets/`, `apk/stage/snippets/`, and `targets/rpi5/snippets/` and merges them into a final build file for each partition (boot, system, data). Each line in a snippet is a file mapping: destination = source. The `[uid gid perms]` prefix sets filesystem permissions in the image.

> **Qt6 libraries do NOT need snippet entries.** The APK system's auto-generated snippets in `apk/stage/snippets/` already include all Qt6 `.so` files. Adding them manually would cause duplicate file warnings.

------

## 6. Building the Image

```bash
cd /home/zee/ITI_Files/QNX/QNX_Snippets_repo

# Full build including your app
make TARGET=rpi5

# If you only want to rebuild your app (faster iteration):
make TARGET=rpi5 -Csrc mycustomapps-clean
make TARGET=rpi5
```

If successful, the image is at `build/rpi5/rpi5.img`. Flash it with `rpi-imager` to your SD card.

### Verify your binary is in the image before flashing:

```bash
grep "appCalculatorApp" build/rpi5/output/build/*.build
```

You should see the entry from your snippet confirming it was included.

------

## 7. Running the App on the RPi5

### 7.1 Connect via SSH over Ethernet

Connect an ethernet cable directly between your laptop and the RPi5. Then on the RPi5 serial console or HDMI keyboard, assign a static IP:

```bash
# On RPi5 — the ethernet interface on QNX RPi5 is cgem0
ifconfig cgem0 192.168.1.50 netmask 255.255.255.0
```

Test connectivity:

```bash
# On laptop
ping 192.168.1.50
```

### 7.2 Create the launch script on the RPi5

```bash
cat > /tmp/run_app.sh << 'EOF'
#!/bin/bash
# QQNX_PHYSICAL_SCREEN_SIZE — tells the QNX platform plugin your display
# resolution in mm. Without this it defaults to 150x90 (wrong DPI).
# Format is: width_pixels,height_pixels
export QQNX_PHYSICAL_SCREEN_SIZE=1920,1080

# QT_QPA_PLATFORM=qnx — selects the QNX Screen platform plugin (libqqnx.so)
# NOT "screen" — that name does not exist in this Qt6 build.
export QT_QPA_PLATFORM=qnx

# QML2_IMPORT_PATH — where the QML engine looks for QML module plugins
export QML2_IMPORT_PATH=/usr/lib/qt6/qml

export QT_DEBUG_PLUGINS=0
exec /system/usr/bin/appCalculatorApp
EOF
chmod +x /tmp/run_app.sh
```

### 7.3 Stop the QNX Developer Desktop

The QNX Developer Desktop (`fullscreen-winmgr`) manages which apps are visible on screen. Your app must either be registered with it, or the winmgr must be stopped for your app to take the display directly.

```bash
# Stop the window manager and launcher
slay fullscreen-winmgr
slay demolauncher
```

### 7.4 Run the app

```bash
# nohup detaches from the terminal so the shell doesn't suspend the process
# < /dev/null disconnects stdin to prevent job-control STOPPED state
# & runs it in the background so your shell prompt returns
nohup /tmp/run_app.sh < /dev/null > /tmp/log_wm.txt 2>&1 &

sleep 3
cat /tmp/log_wm.txt
```

### 7.5 Copy logs to your laptop for inspection

```bash
# From RPi5
scp /tmp/log_wm.txt zee@192.168.1.3:/home/zee/
```

### 7.6 Stop the app

```bash
slay appCalculatorApp
# or by PID if slay doesn't find it:
pidin arg > /tmp/procs.txt
grep Calculator /tmp/procs.txt
kill -9 <PID>
```

------

## 8. Troubleshooting Reference

| Symptom                                           | Cause                                                        | Fix                                                          |
| ------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `Could not find Qt platform plugin "screen"`      | Platform name is wrong                                       | Use `QT_QPA_PLATFORM=qnx` not `screen`                       |
| `QQNX_PHYSICAL_SCREEN_SIZE not set`               | Missing env var                                              | Set `QQNX_PHYSICAL_SCREEN_SIZE=1920,1080`                    |
| `std::isnan` compile errors                       | QNX math.h macro conflict                                    | Add `-Uisnan -Uisinf -Uisfinite -Usignbit` to `CMAKE_CXX_FLAGS` |
| `<cstddef> didn't find libc++ header`             | Wrong include order                                          | Use `-isystem` not `-I` for QNX headers in the CXX wrapper   |
| `HAVE_EGL - Failed`                               | CMake can't find EGL in APK stage                            | Add `-DHAVE_EGL=TRUE -DEGL_LIBRARY=...` to cmake flags       |
| `libxkbcommon not found` linker warning           | Transitive Qt6 deps missing at link time                     | Add `-Wl,--allow-shlib-undefined -Wl,-rpath-link,$(APK_STAGE)/lib` |
| `screen_flush_context: No such file or directory` | App window rejected by fullscreen-winmgr                     | `slay fullscreen-winmgr` before launching, or register app with winmgr |
| App process in `STOPPED` state                    | Shell job control suspending background process              | Use `nohup ... < /dev/null > log.txt 2>&1 &`                 |
| Black screen, app running                         | Window created but not visible                               | Ensure `Window { visibility: Window.FullScreen }` in QML and winmgr is stopped |
| `patrace missing` build error                     | Snippet references a file from a QSC package that wasn't installed | `grep -r "patrace" snippets/` and remove that line           |