# Localization

## Creating New Locales

When adding new locales remember to follow these steps:
- add locale
- run `flutter gen-l10n`
- add locale to `ios\Runner\info.plist` in the `<key>CFBundleLocalizations</key>` array
