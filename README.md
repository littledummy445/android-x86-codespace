cat << 'EOF' > README.md
# 🤖 android-x86-codespace

Run a fully **KVM hardware-accelerated** instance of Android-x86 9.0 (Pie) directly inside your web browser using a single-click GitHub Codespace. 

This repository features **zero-touch automation**—it automatically mounts the host virtualization layers, bypasses empty partition configuration prompts, formats the virtual hard disk behind the scenes, and boots straight to a responsive Android desktop interface.

---

## 🚀 Quick Launch

[![Open in GitHub Codespaces](https://shields.io)](https://codespaces.new)

If clicking the badge above, or navigating directly to **[codespaces.new](https://codespaces.new)**, follow these layout selections to provision your machine:

1. **Repository:** Search for and select your **`littledummy445/android-x86-codespace`** repository path string.
2. **Branch:** Keep this assigned to `main`.
3. **Region:** Choose the region physically closest to your location (for the lowest VNC network streaming lag).
4. **Machine Type:** Click the dropdown menu and change it from the default 2-core option to a **4-core or 8-core machine instance**. *(Crucial for fast software UI compilation).*
5. Click **Create codespace**.
6. Wait a few moments for the background initialization script to finish pulling the ISO, setting up the 32GB disk layout, and handling the partition architecture.
7. Once the terminal settles, initiate the runtime container environment by executing:
   ```bash
   ./run-android.sh
   ```
8. A notification popup will appear in the bottom-right corner of VS Code. Click **Open in Browser** for port `6080`, or manually navigate your browser tab to:
   ```text
   http://localhost:6080/vnc.html
   ```
9. Click the dark blue **Connect** button, and enjoy your cloud-based Android ecosystem!

---

## ⚙️ Automated Features Built-In

* **KVM Pass-Through Authorization:** Automatically alters permissions on `/dev/kvm` to leverage true host hardware hypervisor speed instead of crawling on software emulation.
* **Headless Disk Provisioning:** Scripted key-injection hooks handle partitioning (`cfdisk`), volume formatting (`ext4`), and system file writes (`GRUB`) completely automatically during generation.
* **Setup Wizard Bypass:** Intercepts standard mobile registration and cellular lookup loops using background Android Debug Bridge (`adb`) hooks, dropping you straight onto the home menu structure.
* **Web-Accessible Display Ecosystem:** Leverages a `websockify` translation bridge paired with `noVNC` to stream responsive display assets straight to client-side browsers without third-party viewing tools.

---

## 🛠️ Requirements & Performance

* **Codespace Core Allocation:** For optimal performance, it is highly recommended to select a **4-core or 8-core** machine configuration on the creation layout screen.
* **Graphics Fallback:** Because cloud environments do not feature physical PCIe GPU hardware engines to pass into QEMU containers, the system uses a virtualized VRAM rasterizer. Heavy 3D rendering packages or modern high-end gaming assets may experience frame-rate drops.

---

## 📜 License & Acknowledgments
* **Android-x86 Project:** [android-x86.org](https://android-x86.org)
* **noVNC Project:** [novnc.com](https://novnc.com)
* Distributed under the MIT License. See `LICENSE` for details.
EOF
