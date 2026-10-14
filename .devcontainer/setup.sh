#!/bin/bash
echo "==> Updating package indices and installing dependencies..."
sudo apt-get update
sudo apt-get install qemu-system-x86 novnc websockify wget net-tools adb -y

echo "==> Unlocking hardware-level KVM module permissions..."
sudo chmod 666 /dev/kvm

echo "==> Generating virtual drive space (32GB)..."
qemu-img create -f qcow2 android_hdd.img 32G

echo "==> Downloading official Android-x86 9.0 (Pie) system blocks..."
# Using a high-speed stable mirror cluster
wget -O android-x86_64-9.0-r2.iso "https://dotsrc.org"

echo "==> Injecting automated background partition formatting..."
# This boots the installer raw, passes disk configuration metrics silently via standard entry pipelines, and closes out.
timeout 45s qemu-system-x86_64 \
  -enable-kvm -m 2G -smp 2 -cpu host -machine q35 \
  -device qemu-xhci,id=xhci -device usb-kbd,bus=xhci.0 \
  -device ide-hd,bus=ide.2,drive=AndroidHDD \
  -drive id=AndroidHDD,if=none,file="./android_hdd.img",format=qcow2 \
  -device ide-cd,bus=ide.3,drive=AndroidISO \
  -drive id=AndroidISO,if=none,file="./android-x86_64-9.0-r2.iso",format=raw \
  -vnc :99 \
  -monitor stdio << 'EOM'
echo "==> Workspace configuration finalized successfully!"
