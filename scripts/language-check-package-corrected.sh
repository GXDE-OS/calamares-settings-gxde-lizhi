#!/bin/bash
# Calamares package manager script for GXDE installation
# This script runs inside the target system during Calamares installation
# It checks current system locale and manages packages based on language

set -e

echo "Starting language-based package management..."

# Get locale from target system
cd /target

# Read locale configuration
CURRENT_LOCALE=""

# Try to read current locale from various sources
if [ -f "etc/default/locale" ]; then
    CURRENT_LOCALE=$(grep ^LANG= etc/default/locale 2>/dev/null | cut -d= -f2 | cut -d_ -f1)
    echo "Found locale in etc/default/locale: $CURRENT_LOCALE"
elif [ -f "etc/locale.conf" ]; then
    CURRENT_LOCALE=$(grep ^LANG= etc/locale.conf 2>/dev/null | cut -d= -f2 | cut -d_ -f1)
    echo "Found locale in etc/locale.conf: $CURRENT_LOCALE"
elif [ -f "usr/lib/locale/locale-archive" ]; then
    # Check if zh_CN or other Chinese locales exist
    if localedef --list-archive usr/lib/locale/locale-archive | grep -q "^zh"; then
        CURRENT_LOCALE="zh"
        echo "Found Chinese locale in archive"
    fi
fi

# Default fallback
if [ -z "$CURRENT_LOCALE" ]; then
    # Look for locale generation file
    if [ -f "etc/locale.gen" ]; then
        # Find uncommented lines (active locales)
        ACTIVE_LOCALE=$(grep -v '^#' etc/locale.gen | grep '^[a-z]' | head -1 | cut -d_ -f1)
        if [ -n "$ACTIVE_LOCALE" ]; then
            CURRENT_LOCALE="$ACTIVE_LOCALE"
            echo "Found active locale in etc/locale.gen: $CURRENT_LOCALE"
        fi
    fi
fi

# Check if language is Chinese
if [[ "$CURRENT_LOCALE" == "zh" ]] || [[ "$CURRENT_LOCALE" =~ ^zh_ ]]; then
    echo "Chinese language detected: $CURRENT_LOCALE"
    echo "Performing package operations for Chinese locale..."
    
    # Try to remove dde-store for Chinese systems
    echo "Attempting to remove dde-store package..."
    cat > tmp-apt-script.sh << 'EOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get remove -y dde-store || echo "dde-store was already removed or not found"
apt-get autoremove -y 2>/dev/null || true
EOF
    
    chmod +x tmp-apt-script.sh
    chroot . /bin/bash < tmp-apt-script.sh
    rm -f tmp-apt-script.sh
    
else
    echo "Non-Chinese language detected: ${CURRENT_LOCALE:-unknown}"
    echo "Performing package operations for non-Chinese locale..."
    
    # Try to install aptss for non-Chinese systems
    echo "Attempting to install aptss package..."
    cat > tmp-apt-script.sh << 'EOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
echo "Installing aptss package for non-Chinese language system..."
apt-get install -y aptss || echo "Couldn't install aptss package"
EOF
    
    chmod +x tmp-apt-script.sh
    chroot . /bin/bash < tmp-apt-script.sh
    rm -f tmp-apt-script.sh
fi

echo "Language-based package configuration completed for ${CURRENT_LOCALE:-unknown system}"