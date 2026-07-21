#!/bin/sh
set -e

flutter pub get
dart run slang
dart run build_runner build --delete-conflicting-outputs

main_repo="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
cp -r "$main_repo/.ai" .
cp -r "$main_repo/.blueprint" .
