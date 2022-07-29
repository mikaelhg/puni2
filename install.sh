#!/bin/bash

# Install build requirements

gu install native-image

microdnf install freetype freetype-devel graphviz && microdnf clean all
