#!/bin/bash

# shellcheck source=config.sh
. config.sh

prepareVersion() {
  version="$1"
  targetDir="versions/$1"
  echo -e "\e[1mInstalling React Native project for version $version in folder $targetDir\e[22m"
  ./react-native-version.sh "$1" "$targetDir"
}

installRNRH() {
  version="$1"
  targetDir="versions/$1"
  currentVersion=''
  deps=("${dependencies[@]}")
  pushd "$targetDir" >/dev/null || exit 2
  if [ -d node_modules/react-native-render-html ]; then
    currentVersion=$(node -p "require('react-native-render-html/package.json').version")
  fi
  if [ -z "$currentVersion" ] || [ "$currentVersion" != "$reactNativeRenderHTMLVersion" ]; then
    deps+=("react-native-render-html@$reactNativeRenderHTMLVersion" react-native-webview)
  fi
  if [ "${#deps[@]}" -gt 0 ]; then
    echo -e "\e[1mInstalling dependencies for version $version\e[22m"
    npm install --save-exact "${deps[@]}"
  fi
  if [ "${#devDependencies[@]}" -gt 0 ]; then
    echo -e "\e[1mInstalling devDependencies for version $version\e[22m"
    npm install --save-exact -D "${devDependencies[@]}"
  fi
  popd >/dev/null || exit 2
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
    echo -e "\e[1mInstalling template for version $version\e[22m"
    installTemplate "$version"
  fi
}

testVersion() {
  version="$1"
  versionDir="versions/$version"
  pushd "$versionDir" >/dev/null || exit 2
  echo -e "\e[1mStarting test for RN V$version from directory $versionDir\e[22m"
  runTestForEachProjectRoot "$version"
  popd >/dev/null || exit 2
  if [ $ret = 0 ]; then
    echo -e "\e[1m\e[32m✓ Test passed for RN V$version\e[39m\e[1m"
    return 0
  else
    echo -e "\e[1m\e[31m❌ Test failed for RN V$version\e[39\e[1m"
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
