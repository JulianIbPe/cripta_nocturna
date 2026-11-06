#!/usr/bin/env bash
# Compila Cripta Nocturna para iOS sin proyecto de Xcode: swiftc + Info.plist + index.html, y lo empaqueta como .ipa.
# Necesita una Mac con Xcode (en GitHub Actions: macos-latest). Uso: VERSION_NAME=1.0.5 VERSION_CODE=6 bash ios/build.sh
# El .ipa sale sin firmar con una cuenta de Apple (solo firma ad-hoc): se instala con AltStore, Sideloadly o similares,
# que lo vuelven a firmar con tu Apple ID.
set -euo pipefail
cd "$(dirname "$0")"
APP=build/Payload/CriptaNocturna.app
rm -rf build && mkdir -p "$APP"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
xcrun -sdk iphoneos swiftc -parse-as-library -O -target arm64-apple-ios14.0 -sdk "$SDK" main.swift -o "$APP/CriptaNocturna"
cp Info.plist "$APP/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION_NAME:-1.0}" -c "Set :CFBundleVersion ${VERSION_CODE:-1}" "$APP/Info.plist"
cp ../index.html "$APP/index.html"
cp icons/*.png "$APP/"
printf 'APPL????' > "$APP/PkgInfo"
codesign --force --sign - --timestamp=none "$APP"
(cd build && zip -qry ../../CriptaNocturna.ipa Payload)
echo "Listo: $(cd .. && pwd)/CriptaNocturna.ipa"
