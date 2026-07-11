#!/usr/bin/env bash
# 與 CI 完全同構的本機檢查(spec §6.2)。本機過了,CI 就會過。
set -euo pipefail
cd "$(dirname "$0")/.."

echo "── 0/4 pub get ──"
fvm flutter pub get

echo "── 1/4 format ──"
fvm dart format --set-exit-if-changed .

echo "── 2/4 ignore 稽核(// ignore: 必須附 ' -- 原因')──"
violations=$(grep -rn "// ignore" --include="*.dart" --exclude-dir=generated packages app features tool 2>/dev/null | grep -v -- " -- " || true)
if [ -n "$violations" ]; then
  echo "✗ 未附原因的 ignore:"
  echo "$violations"
  exit 1
fi

echo "── 3/4 analyze ──"
fvm flutter analyze

echo "── 4/4 tests(逐 package)──"
for dir in packages/* features/* app; do
  [ -d "$dir/test" ] || continue
  echo "→ $dir"
  if grep -q "sdk: flutter" "$dir/pubspec.yaml"; then
    (cd "$dir" && fvm flutter test)
  else
    (cd "$dir" && fvm dart test)
  fi
done

echo "✓ all checks passed"
