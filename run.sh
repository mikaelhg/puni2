#!/bin/bash

# Main entrypoint which installs, downloads, builds and tests in the
# repository directory, using the GraalVM from mise.toml

set -euo pipefail

cd "$(dirname "$0")"

export PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2026.9'}
export JLATEXMATH_VERSION=${JLATEXMATH_VERSION:-'1.0.7'}

./install.sh
mise exec -- ./download.sh
mise exec -- ./build.sh
mise exec -- ./test.sh
