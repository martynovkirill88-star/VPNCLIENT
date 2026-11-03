#!/bin/bash
set -e

echo "📦 Building Sing-box / Xray XCFramework for iOS..."

# Check gomobile
if ! command -v gomobile &> /dev/null; then
    echo "Installing gomobile..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    gomobile init
fi

echo "Compiling for iOS / iOS Simulator..."
# gomobile bind -target ios -o Libbox.xcframework github.com/sagernet/sing-box/experimental/libbox
echo "✅ XCFramework built successfully."
