## Watchdog Disabler

Some GSIs on Android devices can cause random reboots. This is usually caused by the `watchdog`. This module is designed to fix this issue.
Compatible with Magisk, APatch, KSU.

### What is `watchdog`?
A `watchdog` is a monitoring system built into the kernel. It performs a system reboot based on whether the system has frozen. Its logic is as follows: if no data is written to the watchdog's device (`/dev/watchdog*``) for a certain period of time (such as 10 seconds), the watchdog considers the system frozen and reboots it.

### How does the module work?
What this module does is write data to the `watchdog` devices at 8-second intervals. The letter '`V`' is used to disable it. Other modules generally do this once and then quit, but in some cases, the data written there is invalidated (changed, etc.). When invalidated, the watchdog still runs, causing the random restart issue (if any). This module, therefore, writes data continuously and tries to prevent this as much as possible.

### How to compile?
You need the Android NDK. You can download it from the Android developers page. Extract the downloaded NDK archive to a convenient location. Then, write the extracted directory to the `ANDROID_NDK` variable. For example, if you chose your home directory, it could look like this:

```bash
export ANDROID_NDK=$HOME/android-ndk-r28b

# $HOME variable = /home/<your_username>
```

And you also need to install zip and CMake.
```bash
# On APT based systems (like Ubuntu):
sudo apt install zip cmake

# On RPM based systems (like Fedora):
sudo dnf install zip cmake

# On Pacman based systems (like Arch Linux);
sudo pacman -Sy zip cmake
```

Now you can easily compile for arm64-v8a and armeabi-v7a with the `build.sh` script.
```bash
# Usage: build.sh build|rebuild|clean

# For building:
bash build.sh build

# For re-build:
bash build.sh rebuild

# For cleaning workspace:
bash build.sh clean
```

You should use the `mkmod.sh` script to make it a flashable module.
```bash
# Usage: mkmod.sh 32|64|clean

# For making 32-bit flashable zip;
bash mkmod.sh 32

# For making 64-bit flashable zip:
bash mkmod.sh 64

# For cleaning created module and placed files:
bash mkmod.sh clean
```

#### Please report bugs and your suggestions.
