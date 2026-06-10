#!/bin/bash
set -euo pipefail

# ─── Resound DMG Builder ─────────────────────────────────────────────
# Packages compiled Resound.app into a professional disk image with
# custom background, volume icon, and styled Finder window.

# ─── Configuration ───────────────────────────────────────────────────
APP_NAME="Resound"
VOLUME_NAME="$APP_NAME"
DMG_NAME="${APP_NAME}.dmg"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

APP_PATH="${PROJECT_DIR}/${APP_NAME}.app"
ICON_PATH="${PROJECT_DIR}/Sources/${APP_NAME}/Resources/${APP_NAME}.icns"
BACKGROUND_SRC="${SCRIPT_DIR}/dmg-background.png"

STAGING_DIR="/tmp/${APP_NAME}-dmg-staging"
RW_IMAGE="/tmp/${APP_NAME}-rw.dmg"
FINAL_DMG="${PROJECT_DIR}/${DMG_NAME}"

# ─── Prerequisite checks ────────────────────────────────────────────
if [ ! -d "$APP_PATH" ]; then
    echo "Error: ${APP_PATH} not found. Run 'make release' first."
    exit 1
fi

if [ ! -f "$BACKGROUND_SRC" ]; then
    echo "Error: Background image not found at ${BACKGROUND_SRC}"
    exit 1
fi

# Ensure no leftover mounts
MOUNT_POINT=$(mount | grep "^/dev.*/Volumes/$VOLUME_NAME" | head -1 | awk '{print $3}' || true)
if [ -n "$MOUNT_POINT" ]; then
    hdiutil detach -force "$MOUNT_POINT" 2>/dev/null || true
fi

# ─── Clean previous artifacts ───────────────────────────────────────
rm -rf "$STAGING_DIR" "$RW_IMAGE" "$FINAL_DMG"

# ─── Stage DMG contents ─────────────────────────────────────────────
echo "Staging DMG contents..."
mkdir -p "$STAGING_DIR/.background"
cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"
cp "$BACKGROUND_SRC" "$STAGING_DIR/.background/"

if [ -f "$ICON_PATH" ]; then
    cp "$ICON_PATH" "$STAGING_DIR/.VolumeIcon.icns"
fi

# ─── Create writable DMG ────────────────────────────────────────────
echo "Creating writable DMG..."
hdiutil create \
    -fs HFS+ \
    -srcfolder "$STAGING_DIR" \
    -format UDRW \
    -volname "$VOLUME_NAME" \
    -quiet \
    "$RW_IMAGE"

rm -rf "$STAGING_DIR"

# ─── Mount, style, and configure ────────────────────────────────────
echo "Configuring DMG layout..."
MOUNT_POINT=$(hdiutil attach -nobrowse "$RW_IMAGE" | tail -1 | awk '{print $3}')
sleep 0.5

# Set custom icon attribute
if [ -f "${MOUNT_POINT}/.VolumeIcon.icns" ] && command -v SetFile &>/dev/null; then
    SetFile -a C "$MOUNT_POINT" 2>/dev/null || true
fi

# Style window with AppleScript (best-effort, GUI-only)
if osascript -e 'tell app "Finder" to exists' &>/dev/null; then
    osascript <<-EOS 2>&1 | grep -v "execution error" | cat >/dev/null || true
tell application "Finder"
    if not (exists window "$VOLUME_NAME") then
        open "$MOUNT_POINT"
        repeat 10 times
            if exists window "$VOLUME_NAME" then exit repeat
            delay 0.3
        end repeat
    end if
    if not (exists window "$VOLUME_NAME") then return
    
    tell window "$VOLUME_NAME"
        set current view to icon view
        set toolbar visible to false
        set statusbar visible to false
        set bounds to {100, 120, 700, 520}
        tell its icon view options
            set icon size to 96
            set text size to 11
            set arrangement to not arranged
        end tell
    end tell
    
    try
        set position of item "${APP_NAME}.app" to {160, 200}
    end try
    try
        set position of item "Applications" to {440, 200}
    end try
    
    close window "$VOLUME_NAME"
end tell
EOS
fi

# ─── Detach and convert ─────────────────────────────────────────────
sleep 0.5
if [ -n "$MOUNT_POINT" ]; then
    hdiutil detach -force "$MOUNT_POINT" 2>/dev/null || hdiutil detach "$MOUNT_POINT" 2>/dev/null || true
fi
sleep 0.5

echo "Compressing DMG..."
hdiutil convert \
    "$RW_IMAGE" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -quiet \
    -o "$FINAL_DMG"

rm -f "$RW_IMAGE"

echo "✓ Created $(basename "$FINAL_DMG") ($(du -h "$FINAL_DMG" | awk '{print $1}'))"
