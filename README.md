# 📦 Linux Container Engine from Scratch

**Architect:** Kushal Raj B | Cloud & DevSecOps Engineer

## 📌 Project Overview
While modern deployments rely heavily on high-level container runtimes like Docker or containerd, understanding the underlying operating system mechanics is critical for advanced DevSecOps, troubleshooting, and security hardening. 

This project bypasses traditional container engines to build a custom container isolation runtime using pure Linux kernel primitives. It demonstrates deep, under-the-hood mastery of process isolation, filesystem jailing, and hardware resource restrictions.

## ⚙️ Core Architecture & Mechanics
This engine achieves containerization by orchestrating three native Linux features:

1. **Filesystem Jailing (`chroot`):**
   * Downloads a minimal Alpine Linux tarball (`rootfs`) and traps the process inside this directory. The process is completely blinded to the host machine's actual filesystem.
2. **Process & Network Isolation (Namespaces via `unshare`):**
   * **PID Namespace:** Creates an isolated process tree where the container operates as `PID 1`.
   * **Mount Namespace:** Ensures filesystem mounts inside the container do not leak or affect the host OS.
   * **UTS Namespace:** Grants the container its own distinct hostname (`kushal-container-01`).
3. **Resource Restriction (`cgroups v2`):**
   * Creates a dedicated control group limiting the container's RAM allocation to a strict `50MB` with swap disabled. If a process attempts to exceed this threshold, the kernel's Out-Of-Memory (OOM) killer dynamically terminates it.

---

## 📂 Repository Structure
* `container.sh`: The core bash engine that provisions the filesystem, applies cgroup limits, and spins up the isolated namespace runtime.
* `stress-test.sh`: An intentional memory leak script designed to validate the cgroup boundaries.

---

## 🚀 How to Run the Container
**Prerequisites:** You must run this on a native Linux environment (e.g., an AWS EC2 Ubuntu instance) with `sudo` privileges. macOS and Windows do not have the required Linux kernel features.

### Step 1: Clone and Prepare
Clone the repository and make the core scripts executable:
```bash
git clone [https://github.com/YourUsername/linux-container-engine.git](https://github.com/YourUsername/linux-container-engine.git)
cd linux-container-engine
chmod +x container.sh stress-test.sh
