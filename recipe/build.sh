#!/bin/bash

set -ex

export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"

# macOS-specific fix for Bazel 7.x absolute path validation issue
# Reference: https://github.com/bazelbuild/bazel/issues/21981
if [[ "$target_platform" == osx-* ]]; then
  export CFLAGS="$CFLAGS -fno-canonical-system-headers -no-canonical-prefixes"
  export CXXFLAGS="$CXXFLAGS -fno-canonical-system-headers -no-canonical-prefixes"
fi

source gen-bazel-toolchain

# Additional Bazel flags to handle macOS absolute path validation issues
if [[ "$target_platform" == osx-* ]]; then
  BAZEL_EXTRA_FLAGS="--incompatible_sandbox_hermetic_tmp=false"
else
  BAZEL_EXTRA_FLAGS=""
fi

bazel build --crosstool_top=//bazel_toolchain:toolchain --cpu ${TARGET_CPU} -c opt --//bazel:use_local_flex_bison --linkopt=-lm $BAZEL_EXTRA_FLAGS //...

mkdir -p $PREFIX/bin
chmod a+w $PREFIX/bin

# List of executables to install
# pulled from https://github.com/chipsalliance/homebrew-verible/blob/main/Formula/verible.rb#L34-L44
executables=(
  "bazel-bin/verilog/tools/diff/verible-verilog-diff"
  "bazel-bin/verilog/tools/formatter/verible-verilog-format"
  "bazel-bin/verilog/tools/kythe/verible-verilog-kythe-extractor"
  "bazel-bin/verilog/tools/lint/verible-verilog-lint"
  "bazel-bin/verilog/tools/ls/verible-verilog-ls"
  "bazel-bin/verilog/tools/obfuscator/verible-verilog-obfuscate"
  "bazel-bin/verilog/tools/preprocessor/verible-verilog-preprocessor"
  "bazel-bin/verilog/tools/project/verible-verilog-project"
  "bazel-bin/verilog/tools/syntax/verible-verilog-syntax"
)

# Copy each executable to the $PREFIX/bin directory
for exe in "${executables[@]}"; do
  if [ -f "$SRC_DIR/$exe" ]; then
    cp "$SRC_DIR/$exe" "$PREFIX/bin/"
    chmod a+wx "$PREFIX/bin/$(basename $exe)"
    if [[ "$target_platform" == linux-* ]]; then
      patchelf --set-rpath "$PREFIX/lib" "$PREFIX/bin/$(basename $exe)"
    fi
  else
    echo "Executable $exe not found, skipping."
  fi
done

echo "Verible installation completed successfully!"
