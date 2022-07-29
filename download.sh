#!/bin/bash

# Download dependencies

JLATEXMATH_VERSION=${JLATEXMATH_VERSION:-'1.0.7'}
PLANTUML_VERSION=${PLANTUML_VERSION:-'1.2022.6'}

curl -sS -L -o plantuml-${PLANTUML_VERSION}.jar \
  https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar

curl -sS -L -o jlatexmath-${JLATEXMATH_VERSION}.jar \
  https://repo1.maven.org/maven2/org/scilab/forge/jlatexmath/${JLATEXMATH_VERSION}/jlatexmath-${JLATEXMATH_VERSION}.jar

curl -sS -L -o - https://github.com/coni2k/PlantUML/archive/refs/heads/master.tar.gz \
  | tar -zxf - 
