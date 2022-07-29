#!/bin/bash

# Main entrypoint which does everything inside a Docker container

GRAALVM_VERSION=${GRAALVM_VERSION:-'22.2.0'}
PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2022.6'}
JLATEXMATH_VERSION=${JLATEXMATH_VERSION:-'1.0.7'}

docker run -it --rm -w /build -v $PWD/out:/build/out -v $PWD:/build/scripts:ro \
  -e PLANTUML_VERSION=${PLANTUML_VERSION} \
  -e JLATEXMATH_VERSION=${JLATEXMATH_VERSION} \
 --entrypoint=/bin/bash \
  ghcr.io/graalvm/graalvm-ce:${GRAALVM_VERSION} \
  -c "scripts/install.sh && scripts/download.sh && scripts/build.sh && scripts/test.sh"
