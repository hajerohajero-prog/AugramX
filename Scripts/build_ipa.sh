#!/bin/bash
set -e

echo "=== AugramX IPA Build Pipeline ==="

# 1. Check TDLib XCFramework presence
if [ -n "$TDLIB_XCFRAMEWORK_PATH" ]; then
    echo "Copying TDLibFramework from $TDLIB_XCFRAMEWORK_PATH..."
    mkdir -p Frameworks
    cp -R "$TDLIB_XCFRAMEWORK_PATH" Frameworks/TDLibFramework.xcframework
fi

if [ ! -d "Frameworks/TDLibFramework.xcframework" ]; then
    echo "FATAL ERROR: Frameworks/TDLibFramework.xcframework is missing."
    echo "Set TDLIB_XCFRAMEWORK_PATH environment variable or place TDLibFramework.xcframework inside Frameworks/."
    exit 1
fi

# 2. Check Secrets for Release build
if [ -z "$API_ID" ] || [ -z "$API_HASH" ]; then
    echo "FATAL ERROR: API_ID and API_HASH environment variables must be provided for Release build."
    exit 1
fi

# 3. Check ExportOptions
if [ ! -f "ExportOptions.plist" ]; then
    if [ -f "ExportOptions.plist.example" ]; then
        echo "ExportOptions.plist missing. Copying from ExportOptions.plist.example..."
        cp ExportOptions.plist.example ExportOptions.plist
    else
        echo "FATAL ERROR: ExportOptions.plist.example not found."
        exit 1
    fi
fi

# 4. Generate Xcode Project
echo "Generating Xcode project using XcodeGen..."
xcodegen generate

# 5. Build Archive (Allows headless CI archive without requiring Apple Developer Team ID)
echo "Building archive..."
xcodebuild clean archive \
    -project AugramX.xcodeproj \
    -scheme AugramX \
    -configuration Release \
    -archivePath build/AugramX.xcarchive \
    -sdk iphoneos \
    API_ID="$API_ID" \
    API_HASH="$API_HASH" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY=""

# 6. Export IPA
echo "Exporting IPA..."
mkdir -p build/ipa
if xcodebuild -exportArchive \
    -archivePath build/AugramX.xcarchive \
    -exportOptionsPlist ExportOptions.plist \
    -exportPath build/ipa; then
    echo "=== BUILD SUCCESSFUL: Signed IPA available at build/ipa/AugramX.ipa ==="
else
    echo "=== Code signing credentials missing on CI. Packaging unsigned IPA payload ==="
    mkdir -p build/ipa/Payload
    cp -R build/AugramX.xcarchive/Products/Applications/AugramX.app build/ipa/Payload/
    cd build/ipa
    zip -r AugramX.ipa Payload
    cd ../..
    echo "=== BUILD SUCCESSFUL: Unsigned IPA artifact created at build/ipa/AugramX.ipa ==="
fi
