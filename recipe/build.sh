#!/bin/bash

set -ex

# The binaries are already extracted in the source directory
# We just need to copy them to the correct location

mkdir -p $PREFIX/bin

# List of executables to install
executables=(
  "verible-verilog-diff"
  "verible-verilog-format"
  "verible-verilog-kythe-extractor"
  "verible-verilog-lint"
  "verible-verilog-ls"
  "verible-verilog-obfuscate"
  "verible-verilog-preprocessor"
  "verible-verilog-project"
  "verible-verilog-syntax"
)

# Copy each executable to the $PREFIX/bin directory
for exe in "${executables[@]}"; do
  if [ -f "bin/$exe" ]; then
    cp "bin/$exe" "$PREFIX/bin/"
    chmod a+x "$PREFIX/bin/$exe"
  else
    echo "Warning: Executable $exe not found in bin/, skipping."
  fi
done

# Download LICENSE file from the Verible repository
# The version should match the one in meta.yaml
VERIBLE_VERSION="${PKG_VERSION//_/-}"
LICENSE_URL="https://raw.githubusercontent.com/chipsalliance/verible/v${VERIBLE_VERSION}/LICENSE"

echo "Downloading LICENSE file from: $LICENSE_URL"
# We're already in $SRC_DIR, so just download it here
curl -L -o LICENSE "$LICENSE_URL" || wget -O LICENSE "$LICENSE_URL"

# Verify LICENSE was downloaded
if [ ! -f LICENSE ]; then
  echo "Error: Failed to download LICENSE file"
  exit 1
fi

# Copy LICENSE file to the package documentation directory
mkdir -p "$PREFIX/share/doc/$PKG_NAME"
cp LICENSE "$PREFIX/share/doc/$PKG_NAME/"
