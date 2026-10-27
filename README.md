# PlantUML native image with GraalVM

PlantUML is a tool for visualizing documentation.

It is sometimes convenient to have a tool available as a simple Linux binary
executable file, rather than a Java application, requiring a separate JDK 
installation. One specific use case for this is continuous integration (CI).

This project uses GraalVM to generate and distribute this binary.

The predecessor project, which had required its developer to shed quite a bit of
blood, sweat and tears, is https://github.com/vektory79/plantuml-native-image.

This project starts from scratch, since over the intervening two years, GraalVM
has advanced significantly, requiring quite a bit less custom work for each
application.

## NOTICE!

This repository will likely not be updated in the future, due to the
official PlantUML repository having gained GraalVM native-image CI/CD 
pipeline scripts, and the maintainer having switched to 
[d2](https://d2lang.com/) and [Mermaid](https://mermaid.js.org/).

Get the binary from [plantuml releases](https://github.com/plantuml/plantuml/releases).

## Usage

Building locally needs [mise](https://mise.jdx.dev/), which provides the
Oracle GraalVM pinned in `mise.toml`, and a Debian or Ubuntu system for
the packages `install.sh` installs. `run.sh` installs, downloads, builds
and tests in the repository directory, the same way the GitHub workflow
does.

```bash
./run.sh
./out/plantuml-1.2026.9-glibc-x86_64 -headless -help

PLANTUML_VERSION=1.2025.9 ./run.sh
./out/plantuml-1.2025.9-glibc-x86_64 -headless -help
```

The executable needs the `.so` files and the empty `lib/` directory next
to it. To pack them into a single self-extracting file:

```bash
./bundle.sh out plantuml-1.2026.9-glibc-x86_64 plantuml
./plantuml -headless -help
```

## Running the binary on Alpine

```bash
apk add gcompat libstdc++ fontconfig ttf-dejavu ttf-liberation graphviz
```
