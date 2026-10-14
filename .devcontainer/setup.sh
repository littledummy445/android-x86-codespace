#!/bin/bash
# Exit script immediately if any individual command fails
set -e

echo "==> Updating package indices and installing dependencies..."
sudo apt-get update
sudo apt-get install qemu-system-x86 novnc websockify wget net-tools adb -y

echo "==> Unlocking hardware-level KVM module permissions..."
# Gracefully handle KVM configuration if the device exists
if [ -e /dev/kvm ]; then
    sudo chmod 666 /dev/kvm
else
    echo "WARNING: /dev/kvm not detected. Emulator will fall back to slower software emulation mode."
fi

echo "==> Generating virtual drive space (32GB)..."
if [ ! -f android_hdd.img ]; then
    qemu-img create -f qcow2 android_hdd.img 32G
else
    echo "Virtual hard drive android_hdd.img already exists, skipping creation."
fi

echo "==> Downloading official Android-x86 9.0 (Pie) system blocks..."
# Replaced home page text block with a direct, verified high-speed ISO installation path
if [ ! -f android-x86_64-9.0-r2.iso ]; then
    wget -O android-x86_64-9.0-r2.iso "https://rwthaachen.dl.osdn.jp/android-x86/71931/android-x86_64-9.0-r2.iso"
else
    echo "Android ISO image already present, skipping download."
fi

echo "==> Workspace configuration finalized successfully!"
echo "==> Spawning Android Emulator with noVNC display wrapper..."

# Launch websockify wrapper in background to bridge noVNC on port 8006 to QEMU's internal VNC port 5900
websockify --web=/usr/share/novnc/ 8006 localhost:5900 &

# Start the actual QEMU x86_64 emulator loop
# Allocates a 2-core CPU configuration, 2GB RAM, binds the drive, mounts the boot ISO, and handles network forwarding
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 2 \
  -m 2G \
  -drive file=android_hdd.img,if=virtio \
  -cdrom android-x86_64-9.0-r2.iso \
  -boot d \
  -vnc :0 \
  -netdev user,id=net0,hostfwd=tcp::5555-:5555 \
  -device e1000,netdev=net0
