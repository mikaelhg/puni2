#!/bin/bash

gu install native-image

microdnf install freetype freetype-devel graphviz unzip && microdnf clean all
