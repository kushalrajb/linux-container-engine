#!/bin/sh
# ==============================================================================
# Script: stress-test.sh
# Description: Intentionally forces a memory leak to test container cgroup limits.
# ==============================================================================

echo "🏋️‍♂️ Attempting to hold massive data in RAM (Testing 50MB Limit)..."

# This awk command generates a massive string and holds it in memory.
# Inside our container, the cgroup limit will force the kernel to kill it.
awk 'BEGIN { a = ""; for(i=0; i<10000000; i++) a = a "1234567890" }'

# We check the exit code of the awk command. 
# If it gets killed by the kernel (OOM Killer), it returns a non-zero exit code.
if [ $? -eq 0 ]; then
    echo "❌ Test Failed: The host allowed the memory allocation to finish. (Limit not enforced)"
else
    echo "✅ Test Passed: Process was successfully terminated by the kernel cgroup limit!"
fi
