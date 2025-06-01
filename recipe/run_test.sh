#!/usr/bin/env bash

set -exo pipefail

# Test that all verible tools are available and working
verible-verilog-lint --version
verible-verilog-diff --version
verible-verilog-format --version
verible-verilog-kythe-extractor --version
verible-verilog-ls --version
verible-verilog-obfuscate --version
verible-verilog-preprocessor --version
verible-verilog-project --version
verible-verilog-syntax --version

# Simple functionality test
echo "module test(); endmodule" > test.sv
verible-verilog-lint test.sv
verible-verilog-syntax test.sv
rm test.sv

echo "All verible tools are working correctly!"
