#!/bin/bash
# Language check and package management script for GXDE installation
# This script runs inside the target system during Calamares installation

# Get current system language setting
LANGUAGE=$(basename /etc/locale.gen | head -1 | cut -d_ -f1)
if [ -z "$LANGUAGE" ]; then
    LANGUAGE=$(grep ^LANG= /etc/default/locale 2>/dev/null | cut -d= -f2 | cut -d_ -f1)
fi
if [ -z "$LANGUAGE" ]; then
    # Default to system locale if config files not available
    LANGUAGE=$(locale | grep ^LANG= | cut -d= -f2 | cut -d_ -f1)
fi

# Check if language is Chinese (zh_CN, zh_TW, etc.)
if [[ "$LANGUAGE" == "zh" ]] || [[ "$LANGUAGE" =~ ^zh_ ]]; then
    echo "Chinese language detected: $LANGUAGE"
    echo "Removing dde-store package..."
    chroot /target apt-get remove --purge -y dde-store || echo "dde-store not found or already removed"
else
    echo "Non-Chinese language detected: $LANGUAGE"
    echo "Installing aptss package..."
    chroot /target apt-get update
    chroot /target apt-get install -y aptss
fi

echo "Language-based package configuration completed."