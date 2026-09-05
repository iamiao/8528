#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="qnap8528-kmod"
VERSION="1.24.0"
ARCH="x86"
OUTPUT="${SCRIPT_DIR}/${APP_NAME}_${VERSION}_${ARCH}.fpk"

echo "Building ${APP_NAME} FPK..."

# Clean old package
rm -f "${OUTPUT}"

# Generate icon if PIL is available
if python3 -c "import PIL" 2>/dev/null; then
    python3 "${SCRIPT_DIR}/gen_icon.py"
else
    echo "PIL not available, skipping icon generation"
fi

# Package
cd "${SCRIPT_DIR}/fnos"
tar czf "${OUTPUT}" manifest config/ cmd/ ui/ wizard/ app/

echo "Build complete: ${OUTPUT}"
ls -lh "${OUTPUT}"
