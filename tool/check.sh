#!/usr/bin/env bash
# 與 CI 完全同構的本機檢查(spec §6.2)。本機過了,CI 就會過。
set -euo pipefail
cd "$(dirname "$0")/.."

echo "── 0/7 pub get ──"
fvm flutter pub get

echo "── 1/7 format ──"
fvm dart format --set-exit-if-changed .

echo "── 2/7 ignore 稽核(// ignore: 必須附 ' -- 原因')──"
# 豁免範圍與根 analysis_options.yaml 的 analyzer.exclude(**/src/generated/**)完全對齊
violations=$(grep -rn "// ignore" --include="*.dart" packages app features tool 2>/dev/null | grep -v "/src/generated/" | grep -v -- " -- " || true)
if [ -n "$violations" ]; then
  echo "✗ 未附原因的 ignore:"
  echo "$violations"
  exit 1
fi

echo "── 3/7 護欄稽核(稽核稽核者;見 tool/guard.sh)──"
bash tool/guard.sh

echo "── 4/7 pubspec 依賴稽核(features 不得互依,packages 不得依賴 feature/app)──"
# 僅比對 dependencies: 至 dev_dependencies: 之間的區段;依賴名為 '^  <name>:'。
feature_names=$(ls features)
dep_violations=""
for dir in features/*; do
  name=$(basename "$dir")
  forbidden="app"
  for other in $feature_names; do
    [ "$other" = "$name" ] && continue
    forbidden="$forbidden $other"
  done
  deps=$(awk '/^dependencies:/{f=1;next}/^dev_dependencies:/{f=0}f' "$dir/pubspec.yaml")
  for word in $forbidden; do
    hit=$(echo "$deps" | grep -E "^  ${word}:" || true)
    if [ -n "$hit" ]; then
      dep_violations="${dep_violations}${dir}/pubspec.yaml: ${hit}
"
    fi
  done
done
for dir in packages/*; do
  deps=$(awk '/^dependencies:/{f=1;next}/^dev_dependencies:/{f=0}f' "$dir/pubspec.yaml")
  for word in app $feature_names; do
    hit=$(echo "$deps" | grep -E "^  ${word}:" || true)
    if [ -n "$hit" ]; then
      dep_violations="${dep_violations}${dir}/pubspec.yaml: ${hit}
"
    fi
  done
done
if [ -n "$dep_violations" ]; then
  echo "✗ 違反依賴方向(feature 不得互依,package 不得依賴 feature/app):"
  printf '%s' "$dep_violations"
  exit 1
fi

echo "── 5/7 l10n 漂移檢查(ARB 需 regen 為 committed 產物)──"
(cd packages/localization && fvm flutter gen-l10n)
fvm dart format packages/localization/lib/src/generated
if ! git diff --exit-code -- packages/localization/lib/src/generated; then
  echo "✗ ARB 已改但未 regen:請執行 (cd packages/localization && fvm flutter gen-l10n) 並將 lib/src/generated 的變更納入本 commit"
  exit 1
fi

echo "── 6/7 analyze ──"
fvm flutter analyze

echo "── 7/7 tests(逐 package)──"
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
