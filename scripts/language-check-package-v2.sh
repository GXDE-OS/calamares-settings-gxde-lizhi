#!/bin/bash
# Language check and package management script for GXDE installation
# This script runs from Calamares to check locale configuration

# Check target system's locale configuration
if [ -f "/etc/locale.conf" ]; then
    LANGUAGE=$(grep -i ^LANG= /etc/locale.conf | cut -d= -f2 | cut -d_ -f1)
elif [ -f "/etc/default/locale" ]; then
    LANGUAGE=$(grep -i ^LANG= /etc/default/locale | cut -d= -f2 | cut -d_ -f1)
elif [ -f "/target/etc/locale.conf" ]; then
    LANGUAGE=$(grep -i ^LANG= /target/etc/locale.conf | cut -d= -f2 | cut -d_ -f1)
elif [ -f "/target/etc/default/locale" ]; then
    LANGUAGE=$(grep -i ^LANG= /target/etc/default/locale | cut -d= -f2 | cut -d_ -f1)
else
    echo "No locale configuration found, skipping language-based package check"
    exit 0
fi

# Check if language is Chinese (zh_CN, zh_TW, etc.)
if [[ "$LANGUAGE" == "zh" ]] || [[ "$LANGUAGE" =~ ^zh_ ]]; then
    echo "Chinese language detected: $LANGUAGE"
    echo "Removing dde-store package from target system..."
    chroot /target apt-get remove --purge -y dde-store || echo "dde-store not found or already removed"
else
    echo "Non-Chinese language detected: $LANGUAGE"
    echo "Installing aptss package on target system..."
    chroot /target apt-get update
    chroot /target apt-get install -y aptss || echo "Failed to install aptss"
fi

echo "Language-based package configuration completed for $LANGUAGE"