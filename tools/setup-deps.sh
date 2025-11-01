#!/usr/bin/env bash
set -e

# Install HMM globally and set it up
haxelib --always install hmm
haxelib --always run hmm setup

# Install dependencies from hmm.json
hmm install

# Ensure lime is set up
haxelib --always run lime setup

echo "Dependencies installed. Run: lime test <target>"
