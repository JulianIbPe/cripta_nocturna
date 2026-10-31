#!/usr/bin/env bash
# Compila Cripta Nocturna como APK sin Gradle: aapt2 + javac + d8 + zipalign + apksigner.
# Uso (Git Bash o Linux): bash android/build.sh  ->  deja CriptaNocturna.apk en la raíz del repo.
# VERSION_CODE y VERSION_NAME cambian la versión (Android solo actualiza si VERSION_CODE sube).
set -euo pipefail
cd "$(dirname "$0")"

JAVA_HOME="${JAVA_HOME:-/d/Programas/JDK17}"
SDK="${ANDROID_HOME:-/d/Programas/AndroidSDK}"
BT="$SDK/build-tools/34.0.0"
JAR="$SDK/platforms/android-34/android.jar"
# El keystore no se sube a git: guardalo, sin él no se puede actualizar la app instalada.
KS=cripta.keystore
PASS="${CRIPTA_KS_PASS:-cripta-nocturna}"
export JAVA_HOME PATH="$JAVA_HOME/bin:$PATH"

rm -rf build && mkdir -p build/assets build/classes build/dex
cp ../index.html build/assets/

"$BT/aapt2" compile --dir res -o build/res.zip
"$BT/aapt2" link -o build/base.apk -I "$JAR" --manifest AndroidManifest.xml -A build/assets build/res.zip --java build/gen \
  --replace-version --version-code "${VERSION_CODE:-1}" --version-name "${VERSION_NAME:-1.0}"
javac -source 8 -target 8 -Xlint:-options -encoding UTF-8 -classpath "$JAR" -d build/classes \
  build/gen/com/julian/criptanocturna/R.java src/com/julian/criptanocturna/*.java
java -cp "$BT/lib/d8.jar" com.android.tools.r8.D8 --release --min-api 24 --lib "$JAR" --output build/dex \
  $(find build/classes -name '*.class')
(cd build/dex && jar uf ../base.apk classes.dex)

[ -f "$KS" ] || keytool -genkeypair -keystore "$KS" -alias cripta -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass "$PASS" -keypass "$PASS" -dname "CN=Cripta Nocturna"
"$BT/zipalign" -f 4 build/base.apk build/aligned.apk
java -jar "$BT/lib/apksigner.jar" sign --ks "$KS" --ks-pass "pass:$PASS" --out ../CriptaNocturna.apk build/aligned.apk
echo "Listo: $(cd .. && pwd)/CriptaNocturna.apk"
