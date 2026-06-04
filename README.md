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

## 🚀 Step-by-Step Execution Guide
**Prerequisites:** You must run this on a native Linux environment (e.g., an AWS EC2 Ubuntu instance) with `sudo` privileges. macOS and Windows do not natively support the required Linux kernel features.

### Step 1: Clone the Repository
Pull the code to your Linux machine and enter the directory:
> git clone https://github.com/YourUsername/linux-container-engine.git
> cd linux-container-engine

### Step 2: Make the Scripts Executable
Grant execution permissions to both the engine and the test script:
> chmod +x container.sh stress-test.sh

### Step 3: Inject the Stress Test
Before starting the container, we need to make sure the stress test script is physically located inside the folder that will become our isolated container universe:
> mkdir -p my_isolated_box
> cp stress-test.sh my_isolated_box/

### Step 4: Spin Up the Container Runtime
Execute the core engine. It will download the Alpine root filesystem, configure the strict 50MB memory limit, isolate the namespaces, and drop you into a jailed shell:
> sudo ./container.sh

### Step 5: Verify the Isolation
Once you see the success message and are inside the container shell, verify that the isolation worked:
* Type `hostname` (It should return `kushal-container-01`, proving Network isolation).
* Type `ps aux` (It should only show a few running processes, proving PID isolation).

### Step 6: Trigger the Memory Stress Test
Now, prove that the hardware resource restrictions (`cgroups`) are actively defending the host machine. Run the stress test inside your container:
> ./stress-test.sh

**Expected Result:** The script will attempt to consume massive amounts of RAM. Because the container is hard-capped at 50MB, the Linux kernel will forcefully kill the process, outputting a `Killed` message and passing the test!

### Step 7: Shut Down and Clean Up
To gracefully exit the container and shut down the runtime, simply type:
> exit

The engine will safely unmount the isolated `/proc` filesystem and return you to your host machine.
