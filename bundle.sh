#!/bin/bash

# Pack a native-image output directory (executable, JDK .so files and the
# empty lib/ that AWT font setup needs) into a single self-extracting
# executable.
#
# Usage: ./bundle.sh <dir> <executable-name> <output-file>
#
# On first run the bundle unpacks itself into
# ${PUNI2_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/puni2}/<hash>/
# and from then on just execs the cached binary.

set -euo pipefail

SRC_DIR=${1:?source directory}
EXE_NAME=${2:?executable name}
OUTPUT=${3:?output file}

[ -x "${SRC_DIR}/${EXE_NAME}" ] || { echo "no executable ${SRC_DIR}/${EXE_NAME}" >&2; exit 1; }

PAYLOAD=$(mktemp)
trap 'rm -f "${PAYLOAD}"' EXIT

# Deterministic tarball so the cache key only changes when the contents do
tar -C "${SRC_DIR}" --sort=name --owner=0 --group=0 --numeric-owner --mtime=@0 \
  -cf - . | gzip -9n > "${PAYLOAD}"

HASH=$(sha256sum "${PAYLOAD}" | cut -c1-16)

cat > "${OUTPUT}" <<EOF
#!/bin/sh
set -eu
base="\${PUNI2_CACHE_DIR:-\${XDG_CACHE_HOME:-\${HOME:-/tmp}/.cache}/puni2}"
dir="\${base}/${HASH}"
if [ ! -x "\${dir}/${EXE_NAME}" ]; then
  mkdir -p "\${base}"
  tmp=\$(mktemp -d "\${base}/.extract.XXXXXX")
  skip=\$(awk '/^__PAYLOAD_BELOW__\$/ { print NR + 1; exit }' "\$0")
  tail -n +"\${skip}" "\$0" | gzip -dc | tar -xf - -C "\${tmp}"
  # Another process may have won the race; keep whichever landed first
  if [ -e "\${dir}" ]; then rm -rf "\${tmp}"; else mv "\${tmp}" "\${dir}"; fi
  [ -d "\${dir}/\${tmp##*/}" ] && rm -rf "\${dir}/\${tmp##*/}"
fi
exec "\${dir}/${EXE_NAME}" "\$@"
__PAYLOAD_BELOW__
EOF

cat "${PAYLOAD}" >> "${OUTPUT}"
chmod +x "${OUTPUT}"

echo "${OUTPUT}: $(du -h "${OUTPUT}" | cut -f1), cache key ${HASH}"
