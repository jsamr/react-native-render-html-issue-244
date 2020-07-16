#!/bin/bash

# shellcheck source=config.sh
. config.sh

bundleDir=".build"

prepareVersion() {
  version="$1"
  targetDir="versions/$1"
  ./react-native-version.sh "$1" "$targetDir"
}

installRNRH() {
  version="$1"
  targetDir="versions/$1"
  currentVersion=''
  pushd "$targetDir" || exit 2
  if [ -d node_modules/react-native-render-html ]; then
    currentVersion=$(node -p "require('react-native-render-html/package.json').version")
  fi
  if [ -z "$currentVersion" ] || [ "$currentVersion" != "$reactNativeRenderHTMLVersion" ]; then
    npm install --save-exact "react-native-render-html@$reactNativeRenderHTMLVersion" react-native-webview
  fi
  popd || exit 2
}

installTemplate() {
  version="$1"
  versionDir="versions/$version"
  rsync -a template/. "$versionDir"
}

installOrUpdateVersion() {
  version="$1"
  versionDir="versions/$version"
  if [ ! -d "$versionDir" ]; then
    if ! prepareVersion "$version"; then
      echo "Couldn't prepare version $version, aborting..."
      exit 2
    fi
  fi
  if [ -d "$versionDir" ]; then
    installRNRH "$version"
    installTemplate "$version"
  fi
}

testVersion() {
  version="$1"
  versionDir="versions/$version"
  pushd "$versionDir" || exit 2
  bundle="$bundleDir/rn$version.js"
  [ -d "$bundleDir" ] && rm -rf "$bundleDir"
  mkdir -p "$bundleDir"/android
  npx react-native bundle --platform android --dev false \
    --entry-file index.js \
    --bundle-output "$bundle" \
    --assets-dest "$bundleDir"/android
  ret=$?
  [ -e "$bundle" ] && rm "$bundle"
  popd || exit 2
  if [ $ret = 0 ]; then
    echo -e "\e[32m✓ test passed for RN V$version\e[39m"
    return 0
  else
    echo -e "\e[31m❌ test failed for RN V$version\e[39m"
    return 1
  fi
}

init() {
  for version in "${reactNativeVersions[@]}"; do
    installOrUpdateVersion "$version"
  done
}

runTests() {
  ret=0
  for version in "${reactNativeVersions[@]}"; do
    if ! testVersion "$version"; then
      ret=1
    fi
  done
  return $ret
}

init
runTests
