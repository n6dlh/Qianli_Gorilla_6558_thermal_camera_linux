#!/bin/bash
for dev in /dev/video*; do
    if v4l2-ctl -d "$dev" --list-formats-ext 2>/dev/null | grep -q "256x384"; then
        devnum=$(echo "$dev" | grep -o '[0-9]*$')
        echo "Found thermal camera at $dev"
        python3 /home/dave/microscope/tc001v4.2.py --device "$devnum"
        exit 0
    fi
done

echo "Thermal camera not found — is it plugged in?"
exit 1
