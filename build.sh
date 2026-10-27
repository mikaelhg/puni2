#!/bin/bash

# Build the binary, mirroring the Compile launcher, Generate build
# configuration and Build steps of .github/workflows/manual.yml.
# Expects the jars and PlantUML-master/ (see download.sh) in the current
# directory. --gc=G1 requires Oracle GraalVM (see mise.toml).

set -euo pipefail

JLATEXMATH_VERSION=${JLATEXMATH_VERSION:-'1.0.7'}
PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2026.9'}

SCRIPT_DIR=$(dirname "$0")
CP=jlatexmath-${JLATEXMATH_VERSION}.jar:plantuml-${PLANTUML_VERSION}.jar

javac -d ./classes -cp ${CP} "${SCRIPT_DIR}/launcher/puni2/Main.java"

# Some sample diagrams contain deliberate syntax errors
java -agentlib:native-image-agent=config-output-dir=conf/META-INF/native-image \
  -cp ./classes:${CP} \
  puni2.Main -headless -o /tmp/out \
    ./PlantUML-master/*/*.puml "${SCRIPT_DIR}"/tests/*.puml || true

# puni2.Main points java.home at the executable's directory, which
# must contain lib/ for AWT font setup to work
mkdir -p ./out/lib

# G1 rather than the default Serial GC: about 2x faster for typical
# 1-20 diagram runs, and avoids the Serial GC Math.cbrt crash, see
# docs/graalvm-quirks/serial-gc-cbrt-crash.md
native-image -J-Xms6g -J-Xmx6g --gc=G1 --no-fallback --enable-http --enable-https \
  -H:+UnlockExperimentalVMOptions \
  -H:+StaticExecutableWithDynamicLibC \
  -H:IncludeResources="stdlib/.*" \
  -H:IncludeResources="net/sourceforge/plantuml.*(png|svg|txt)$" \
  -H:ConfigurationFileDirectories=conf/META-INF/native-image \
  -o ./out/plantuml-${PLANTUML_VERSION}-glibc-x86_64 \
  -cp ./classes:${CP} \
  puni2.Main
