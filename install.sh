#!/bin/bash

# Install build requirements: GraalVM from mise.toml, and the system
# packages the workflow installs (Debian/Ubuntu)

set -euo pipefail

mise install java

MISSING=()
dpkg-query -W -f='${Status}' libfreetype-dev 2>/dev/null | grep -q 'install ok installed' || MISSING+=(libfreetype-dev)
# Checked by command: on Ubuntu "upx" is a virtual package provided by upx-ucl
command -v dot >/dev/null || MISSING+=(graphviz)
command -v curl >/dev/null || MISSING+=(curl)
command -v upx >/dev/null || MISSING+=(upx)

if [ ${#MISSING[@]} -gt 0 ]; then
  sudo apt-get -yqq update
  sudo apt-get -yqq install "${MISSING[@]}"
fi
