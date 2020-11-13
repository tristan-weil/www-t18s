#!/bin/bash

set -o errexit
set -o pipefail

echo "Building static pages..."
hugo --minify serve
