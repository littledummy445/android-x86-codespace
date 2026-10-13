#!/bin/bash

RAM="3G"
CORES="2"

echo "=================================================================="
echo "🚀 Booting KVM-Accelerated Android OS Workspace..."
echo "🌐 Interface URL: http://localhost:6080/vnc.html"
echo "=================================================================="

# Spin up the background web conversion proxy
websockify --web /usr/share/novnc/ 6080 localhost:5901 &

# Bypass Android initial setup loop metrics seamlessly via adb daemon links
(
  sleep 15
  adb connect localhost:5555
  adb shell settings put global device_provisioned 1
  adb shell settings put secure user_setup_complete 1
) &

# Load the core system purely from the persistent drive mapping
qemu-system-x86_64 \
  -enable-kvm \
  -m $RAM \
  -smp $CORES \
  -cpu host \
  -machine q35 \
  -device qemu-xhci,id=xhci \
  -device usb-kbd,bus=xhci.0 -device usb-tablet,bus=xhci.0 \
  -device ide-hd,bus=ide.2,drive=AndroidHDD \
  -drive id=AndroidHDD,if=none,file="./android_hdd.img",format=qcow2 \
  -vnc localhost:1 \
  -vga vmware \
  -netdev user,id=net0,hostfwd=tcp::5555-:5555 \
  -device e1000,netdev=net0
