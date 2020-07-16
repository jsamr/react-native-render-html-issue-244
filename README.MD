# Automated tests for [react-native-render-html#244](https://github.com/archriss/react-native-render-html/issues/244)

## Prerequisites

You need a POSIX compliant system (MacOS, Linux, WSL) and the following utilities installed:

- bash
- npm and nodejs
- rsync

## How to run?

From the command line (shell), run, from the root of this project:

```bash
./react-native-issue-244.sh
```

Each time you change the files in the `template` directory or the `config.sh` file, re-run the command to update the results of the tests.

## How to configure react-native versions?

Change the list of versions in `config.sh` file.

## How does it work?

1. Use `rn-diff-purge` to download the result of `react-native init` for every version of React Native into the `versions` folder. The versions are determined by the `reactNativeVersions` array in the `config.sh`.
2. Run <pre>npm install react-native-render-html react-native-webview</pre> into each version folder. `react-native-render-html` version can be changed with the `reactNativeRenderHTMLVersion` variable in the `config.sh` file.
3. Copy the files from `template` folder into each version folder.
4. Run the following into each version folder: <pre>
npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output /tmp/rn$version.js --assets-dest /tmp/android/
</pre> If the command fails, the test fails for this version. Otherwise, it passes.

