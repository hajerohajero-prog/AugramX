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

# 3. Generate Xcode Project
echo "Generating Xcode project using XcodeGen..."
xcodegen generate

# 4. Clean and Build App for iOS (Ad-hoc signed for CI)
echo "Building iOS App Binary..."
xcodebuild clean build \
    -project AugramX.xcodeproj \
    -scheme AugramX \
    -configuration Release \
    -sdk iphoneos \
    -derivedDataPath build/DerivedData \
    API_ID="$API_ID" \
    API_HASH="$API_HASH" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=YES \
    AD_HOC_CODE_SIGNING_ALLOWED=YES \
    CODE_SIGN_STYLE="Manual"

# 5. Locate built .app bundle
APP_PATH=$(find build/DerivedData -name "AugramX.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "FATAL ERROR: AugramX.app bundle was not found after build."
    exit 1
fi

echo "Found built app at: $APP_PATH"
chmod +x "$APP_PATH/AugramX" 2>/dev/null || true

# 6. Package into IPA
echo "Packaging .ipa artifact..."
mkdir -p build/ipa/Payload
cp -R "$APP_PATH" build/ipa/Payload/
cd build/ipa
zip -r AugramX.ipa Payload
cd ../..

echo "=== BUILD SUCCESSFUL: IPA artifact created at build/ipa/AugramX.ipa ==="
