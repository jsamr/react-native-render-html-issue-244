#!/bin/sh
# Usage
# react-native-version <version> <target-directory>
# version must be in the form major.minor.patch

version=$1
targetDir=$2
targetTempDir=".cache/RN$version"

if [ -z "$version" ]; then
    echo "version required"
    exit 1
fi
if [ -z "$targetDir" ]; then
    echo "target directory required"
fi
if [ -d "$targetTempDir" ]; then
  echo "skipping cloning from rn-diff-purge, directory exists in cache: $targetTempDir"
  ret=0
else
  git clone git@github.com:react-native-community/rn-diff-purge.git --depth 1 -b "release/$version" "$targetTempDir"
  ret=$?
fi

if [ $ret = 0 ]; then
    mkdir -p "$targetDir"
    pwd
    echo "$targetTempDir"
    if rsync -av "$targetTempDir/RnDiffApp/." "$targetDir"; then
      cd "$targetDir" || exit 2
      npm install
    else
      echo "Rsync failed... aborting."
      exit 2
    fi
fi

clean() {
    if [ -d "$targetTempDir" ]; then
        rm -rf "${targetTempDir:?}"/*
    fi
}

trap clean EXIT INT HUP
