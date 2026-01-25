#!/bin/bash
# Script to build iOS app without Interface Builder validation errors
# This sets environment variables to skip IB validation

export IBSC_DISABLE_INTERFACE_BUILDER_VALIDATION=YES
export XCODE_SKIP_INTERFACE_BUILDER_VALIDATION=YES

# Build using Flutter
cd "$(dirname "$0")/.."
flutter build ios --no-codesign --release
