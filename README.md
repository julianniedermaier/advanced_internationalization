# Advanced Internationalization

A basic flutter project presenting a technique for advanced handling of app internationalization.


## Features

- Live device locale listening
- Local storage of selected locale
- Locale list


## Supported Platforms

- Android
- iOS


## Localization files

If you are running this app for the first time, the localized code will not be present in the
project directory. However, after running the application for the first time, a synthetic package
will be generated containing the app's localizations through importing
`package:flutter_gen/gen_l10n/`.

The app comes with a few example locales. Please read the README file in `lib\l10n` to see how
additional locales can be added.


## Dependencies

The app requires some official (pub.dev) and some connected packages to run. Please run
`flutter pub get` before running this app for the first time.


## Tests

The app has its own set of unit, widget, and integration tests.
