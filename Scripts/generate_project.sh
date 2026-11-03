#!/bin/bash
set -e

echo "🚀 Generating VPNCLIENT Xcode Project..."

if ! command -v xcodegen &> /dev/null; then
    echo "⚠️ xcodegen not found. Installing via brew..."
    if command -v brew &> /dev/null; then
        brew install xcodegen
    else
        echo "❌ Homebrew is required to install xcodegen. Please install brew or open VPNCLIENT.xcodeproj directly."
        exit 1
    fi
fi

xcodegen generate
echo "✅ Project generated successfully! Open VPNCLIENT.xcodeproj in Xcode."
