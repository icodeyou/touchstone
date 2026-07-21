#!/bin/sh
set -e

echo "⏳ Copying folders .ai/ and .blueprint/ and file api_keys.json"
main_repo="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
cp -r "$main_repo/.ai" .
cp -r "$main_repo/.blueprint" .
cp "$main_repo/api_keys.json" .
echo "✅ Folders .ai/ and .blueprint/ and file api_keys.json have been copied from root workspace"
echo ""

echo "⏳ Flutter commands"
flutter pub get
dart run slang
if grep -q '^ *build_runner:' pubspec.yaml; then
  dart run build_runner build --delete-conflicting-outputs
fi
echo "✅ Flutter commands"
echo ""
