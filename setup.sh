#!/bin/bash
set -e

# Update
sudo apt-get update
sudo apt-get install -y wget unzip openjdk-11-jdk qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils x11vnc novnc websockify xvfb

# Install Android SDK
mkdir -p $HOME/android-sdk
cd $HOME/android-sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip
unzip cmdline-tools.zip -d cmdline-tools
export ANDROID_HOME=$HOME/android-sdk
export PATH=$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-30" "system-images;android-30;google_apis;x86_64" "emulator"

# Create emulator
echo "no" | avdmanager create avd -n codespace -k "system-images;android-30;google_apis;x86_64"

# Start emulator headless
Xvfb :0 -screen 0 1280x800x16 &
export DISPLAY=:0
$ANDROID_HOME/emulator/emulator -avd codespace -no-window -gpu swiftshader_indirect -noaudio -no-boot-anim &

# Start VNC + noVNC
x11vnc -display :0 -nopw -forever -shared -rfbport 5900 &
websockify --web=/usr/share/novnc/ 8080 localhost:5900 &
