#!/bin/sh
set -e

flutter pub get
dart run slang
if grep -q '^ *build_runner:' pubspec.yaml; then
  dart run build_runner build --delete-conflicting-outputs
fi

main_repo="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
cp -r "$main_repo/.ai" .
cp -r "$main_repo/.blueprint" .
