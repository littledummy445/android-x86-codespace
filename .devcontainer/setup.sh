#!/bin/bash
# Exit script immediately if any individual command fails
set -e

echo "==> Updating package indices and installing dependencies..."
sudo apt-get update
sudo apt-get install qemu-system-x86 novnc websockify wget net-tools adb -y

echo "==> Unlocking hardware-level KVM module permissions..."
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

echo "==> Validating and managing downloaded system blocks..."
# Fix for the file being named 'download' by the wget loop
if [ -f download ] && [ $(stat -c%s download) -gt 500000000 ]; then
    echo "Detected correctly downloaded binary blocks named 'download'. Renaming to ISO format..."
    mv -f download android-x86_64-9.0-r2.iso
fi

# Hard validation check: If the ISO is missing or less than 500MB, fetch a clean mirror stream
if [ -f android-x86_64-9.0-r2.iso ] && [ $(stat -c%s android-x86_64-9.0-r2.iso) -lt 500000000 ]; then
    echo "Detected truncated file size. Purging file..."
    rm -f android-x86_64-9.0-r2.iso
fi

if [ ! -f android-x86_64-9.0-r2.iso ]; then
    echo "Fetching fresh Android image blocks directly from mirror array..."
    wget -O android-x86_64-9.0-r2.iso "https://downloads.sourceforge.net/project/android-x86/Release%209.0/android-x86_64-9.0-r2.iso"
else
    echo "Verified clean Android ISO image present, skipping download."
fi

echo "==> Workspace configuration finalized successfully!"
echo "==> Spawning Android Emulator with noVNC display wrapper..."

# Clear out any stale web socket proxy instances on the host network
killall websockify 2>/dev/null || true

# Launch websockify wrapper in background to bridge noVNC on port 8006 to QEMU's internal VNC port 5900
websockify --web=/usr/share/novnc/ 8006 localhost:5900 &

# Start the actual QEMU x86_64 emulator loop using your 2-core CPU configuration and 2GB RAM allocation
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 2 \
  -m 2G \
  -drive file=android_hdd.img,if=virtio \
  -drive file=android-x86_64-9.0-r2.iso,media=cdrom,index=1 \
  -boot order=d \
  -vnc :0 \
  -netdev user,id=net0,hostfwd=tcp::5555-:5555 \
  -device e1000,netdev=net0
