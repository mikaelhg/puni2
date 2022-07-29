#!/bin/bash

docker run -it --rm -w /build -v $PWD:/build/scripts:ro --entrypoint=/bin/bash \
  ghcr.io/graalvm/graalvm-ce:22.2.0 \
  -c "scripts/install.sh && scripts/download.sh && scripts/build.sh"
