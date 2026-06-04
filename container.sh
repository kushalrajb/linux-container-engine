#!/bin/bash
# ==============================================================================
# Script: container.sh
# Architect: Kushal Raj B
# Description: A custom container runtime built from scratch using Linux
#              namespaces, chroot, and cgroups v2 resource restriction.
# ==============================================================================

CONTAINER_ROOT="./my_isolated_box"
CGROUP_NAME="kushal_container_limit"

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this script with sudo."
  exit 1
fi

echo "🚀 Starting custom container runtime..."

# Step 1: Provision Filesystem
if [ ! -d "$CONTAINER_ROOT" ]; then
    echo "📦 Downloading Alpine Linux root filesystem..."
    mkdir -p "$CONTAINER_ROOT"
    curl -s -o alpine.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-minirootfs-3.18.4-x86_64.tar.gz
    tar -xzf alpine.tar.gz -C "$CONTAINER_ROOT"
    rm alpine.tar.gz
fi

# Step 2: Set Up Resource Limits (Cgroups v2)
echo "📊 Configuring Cgroups: Capping Memory at 50MB..."
CGROUP_PATH="/sys/fs/cgroup/$CGROUP_NAME"

if [ ! -d "$CGROUP_PATH" ]; then
    mkdir -p "$CGROUP_PATH"
fi

# Apply hard memory limits to this control group
echo "52428800" > "$CGROUP_PATH/memory.max" # 50MB in bytes
echo "0" > "$CGROUP_PATH/memory.swap.max"   # Disable swap to force strict limit

# Attach the current shell to the cgroup BEFORE chrooting.
# All child processes (like the container) will inherit this restriction!
echo $$ > "$CGROUP_PATH/cgroup.procs"

echo "🔒 Creating Namespaces & Spawning Isolated Container..."

# Step 3: Execute inside Namespaces and Chroot
# Note: unshare --mount automatically cleans up the /proc mount when the container exits
unshare --pid --mount --uts --fork chroot "$CONTAINER_ROOT" /bin/sh -c "
    mount -t proc proc /proc
    hostname kushal-container-01
    echo '✅ SUCCESS: Running inside isolated container with a strict 50MB RAM limit.'
    /bin/sh
"

echo "🛑 Container stopped."
