#!/bin/bash
# shellcheck disable=SC2034

# An array of each React Native version to be tested.
reactNativeVersions=('0.59.2' '0.63.1')

# The version of react-native-render-html to be testted.
reactNativeRenderHTMLVersion="4.2.1"

# Any supplementary dependencies required in the template.
dependencies=()

# Any supplementary development dependencies required to run the test.
# You can also use this array to override any dependency version, use
# npm syntax, e.g. 'react-test-renderer@16.^13'
devDependencies=()

# A function run for each version of react native such as specified in the
# reactNativeVersions array. The function current working directory is the root
# of each react native initialized project contained in the versions/
# directory.  The function must return 0 on success and 1 on failure.
runTestForEachProjectRoot() {
    version="$1"
    bundleDir=".build"
    bundle="$bundleDir/rn$version.js"
    [ -d "$bundleDir" ] && rm -rf "$bundleDir"
    mkdir -p "$bundleDir"/android
    npx react-native bundle --platform android --dev false \
        --entry-file index.js \
        --bundle-output "$bundle" \
        --assets-dest "$bundleDir"/android
    ret=$?
    [ -e "$bundle" ] && rm "$bundle"
    return $ret
}
