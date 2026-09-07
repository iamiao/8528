#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="qnap8528-kmod"
VERSION="1.24.2"
ARCH="x86"
OUTPUT="${SCRIPT_DIR}/${APP_NAME}_${VERSION}_${ARCH}.fpk"

echo "Building ${APP_NAME} FPK..."

# Clean old package
rm -f "${OUTPUT}"

# Generate required package icons.
PYTHON_BIN=""
for candidate in python3 python; do
    if command -v "${candidate}" >/dev/null 2>&1 && "${candidate}" -c "import PIL" 2>/dev/null; then
        PYTHON_BIN="${candidate}"
        break
    fi
done
if [ -n "${PYTHON_BIN}" ]; then
    "${PYTHON_BIN}" "${SCRIPT_DIR}/gen_icon.py"
else
    echo "PIL is required to generate FPK icons" >&2
    exit 1
fi

# Build the application payload expected by fnOS.
WORK_DIR="${SCRIPT_DIR}/.build_tmp"
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}/app-root" "${WORK_DIR}/package/cmd"
trap 'rm -rf "${WORK_DIR}"' EXIT
cp -a "${SCRIPT_DIR}/fnos/app" "${WORK_DIR}/app-root/"
cp -a "${SCRIPT_DIR}/fnos/ui" "${WORK_DIR}/app-root/"
(cd "${WORK_DIR}/app-root" && tar czf "${WORK_DIR}/app.tgz" .)
cp "${WORK_DIR}/app.tgz" "${WORK_DIR}/package/"
CHECKSUM="$(md5sum "${WORK_DIR}/app.tgz" | awk '{print $1}')"

# fnOS invokes these lifecycle entry points from the outer package.
cat > "${WORK_DIR}/package/cmd/common" <<'EOF'
#!/bin/bash
COMMON_DIR="$(dirname "$0")"
if [ -r "${COMMON_DIR}/service-setup" ]; then
    . "${COMMON_DIR}/service-setup"
fi
install_init() { :; }
install_callback() { service_postinst; return "$?"; }
uninstall_init() { service_stop; return "$?"; }
uninstall_callback() { service_postuninst; return "$?"; }
upgrade_init() { service_stop; return "$?"; }
upgrade_callback() { service_postinst; return "$?"; }
config_init() { :; }
config_callback() { :; }
start_daemon() { service_start; }
stop_daemon() { service_stop; }
EOF
cat > "${WORK_DIR}/package/cmd/installer" <<'EOF'
#!/bin/bash
set -e
. "$(dirname "$0")/common"
case "$1" in
    install_init|install_callback|uninstall_init|uninstall_callback|upgrade_init|upgrade_callback|config_init|config_callback)
        "$1"
        ;;
    *) exit 1 ;;
esac
EOF
cat > "${WORK_DIR}/package/cmd/main" <<'EOF'
#!/bin/bash
. "$(dirname "$0")/common"
case "$1" in
    start) start_daemon ;;
    stop) stop_daemon ;;
    status) daemon_status ;;
    log) exit 0 ;;
    *) exit 1 ;;
esac
EOF
for hook in install_init install_callback uninstall_init uninstall_callback upgrade_init upgrade_callback config_init config_callback; do
    printf '#!/bin/bash\n. "$(dirname "$0")/common"\n%s\n' "${hook}" > "${WORK_DIR}/package/cmd/${hook}"
done
cp "${SCRIPT_DIR}/fnos/cmd/service-setup" "${WORK_DIR}/package/cmd/"
cp -a "${SCRIPT_DIR}/fnos/config" "${WORK_DIR}/package/"
cp -a "${SCRIPT_DIR}/fnos/wizard" "${WORK_DIR}/package/"
cp -a "${SCRIPT_DIR}/fnos/ui" "${WORK_DIR}/package/"
cp "${SCRIPT_DIR}/fnos/manifest" "${WORK_DIR}/package/"
sed -i "s/^checksum.*/checksum        = ${CHECKSUM}/" "${WORK_DIR}/package/manifest"
cp "${SCRIPT_DIR}/fnos/ICON.PNG" "${WORK_DIR}/package/"
cp "${SCRIPT_DIR}/fnos/ICON_256.PNG" "${WORK_DIR}/package/"
chmod +x "${WORK_DIR}/package/cmd/"*
(cd "${WORK_DIR}/package" && tar czf "${OUTPUT}" *)

echo "Build complete: ${OUTPUT}"
ls -lh "${OUTPUT}"
