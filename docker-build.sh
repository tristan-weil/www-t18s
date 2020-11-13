#!/bin/bash

set -o errexit
set -o pipefail

echo "Building static pages..."
hugo --minify

echo "Building Docker..."
docker build --pull -t latest .

echo "Starting Docker..."
docker run -it --rm --name www-t18s -p 8080:8080 latest
