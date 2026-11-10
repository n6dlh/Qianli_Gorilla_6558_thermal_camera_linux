#!/usr/bin/env bash
# Build ThermalCam AppImage. Usage: ./scripts/build-appimage.sh
# Output: dist/ThermalCam-<version>-x86_64.AppImage
set -euo pipefail

PY_VER="3.12"
PY_FULL="3.12.15"
PY_APPIMAGE="python${PY_FULL}-cp312-cp312-manylinux2014_x86_64.AppImage"
PY_URL="https://github.com/niess/python-appimage/releases/download/python${PY_VER}/${PY_APPIMAGE}"
TOOL_URL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
APPDIR="$BUILD/ThermalCam.AppDir"
VERSION="${VERSION:-$(git -C "$ROOT" describe --tags --always 2>/dev/null || echo dev)}"
OUT="$ROOT/dist/ThermalCam-${VERSION}-x86_64.AppImage"

# Run AppImages without FUSE (needed in CI, harmless locally)
export APPIMAGE_EXTRACT_AND_RUN=1

mkdir -p "$BUILD" "$ROOT/dist"
cd "$BUILD"

# Download tools once (cached in build/)
[ -f "$PY_APPIMAGE" ] || curl -fL -o "$PY_APPIMAGE" "$PY_URL"
[ -f appimagetool ]   || curl -fL -o appimagetool "$TOOL_URL"
chmod +x "$PY_APPIMAGE" appimagetool

# Fresh AppDir from the portable Python
rm -rf "$APPDIR" squashfs-root
./"$PY_APPIMAGE" --appimage-extract > /dev/null
mv squashfs-root "$APPDIR"

# Dependencies into the bundled Python
PY="$APPDIR/opt/python${PY_VER}/bin/python${PY_VER}"
"$PY" -m pip install --no-warn-script-location -r "$ROOT/requirements.txt"

# App code
mkdir -p "$APPDIR/opt/thermal"
cp "$ROOT/src/thermal_camera.py" "$APPDIR/opt/thermal/"

# Replace stock Python launcher/metadata (rm first: stock AppRun is a symlink)
rm -f "$APPDIR/AppRun" "$APPDIR"/*.desktop "$APPDIR"/*.png "$APPDIR/.DirIcon"
install -m 755 "$ROOT/packaging/AppRun"                 "$APPDIR/AppRun"
install -m 644 "$ROOT/packaging/thermal-camera.desktop" "$APPDIR/"
install -m 644 "$ROOT/packaging/thermal-camera.png"     "$APPDIR/"

# Extracted dirs are 0700; AppImage needs world-readable
chmod -R a+rX "$APPDIR"

rm -f "$OUT"
ARCH=x86_64 ./appimagetool "$APPDIR" "$OUT"
echo "Built: $OUT"
