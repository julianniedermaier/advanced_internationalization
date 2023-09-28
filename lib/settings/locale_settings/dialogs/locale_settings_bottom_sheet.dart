import 'package:advanced_internationalization/settings/locale_settings/locale_settings.dart';
import 'package:flutter/material.dart';

/// Shows a bottom sheet for selecting application locale settings.
///
/// This function displays a bottom sheet, allowing the user to choose the
/// application's locale. The options are presented as a list of radio buttons
/// representing available locales.
///
/// This function relies on a [LocaleSettingsBloc] to manage locale settings.
/// Make sure the bloc is properly set up in your application.
/// This function relies on a [LocaleRadioListTile].
///
/// - [context]: The BuildContext for the current widget.
///
/// Returns a [Future] that completes when the bottom sheet is dismissed.
///
/// Example:
/// ```dart
/// localeSettingsBottomSheet(context: context);
/// ```
void localeSettingsBottomSheet({
  required BuildContext context,
}) {
  var _isBottomSheetOpen = true;

  bool _handleDraggableNotification(
    DraggableScrollableNotification notification,
  ) {
    if (notification.extent <= 0.05 && _isBottomSheetOpen) {
      // Temporary solution awaiting flutter issue #116982 and #36283
      // Relies on showModalBottomSheet running async (await)
      Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    useSafeArea: true,
    builder: (BuildContext context) {
      return NotificationListener<DraggableScrollableNotification>(
        onNotification: _handleDraggableNotification,
        child: DraggableScrollableSheet(
          key: localeSettingsOptionsSheetKey,
          initialChildSize: 0.4,
          minChildSize: 0,
          snap: true,
          snapSizes: const [0.4],
          expand: false,
          builder: (BuildContext context, ScrollController controller) {
            return localeOptionsList(
              context: context,
              controller: controller,
              onClose: () => Navigator.of(context).pop(),
            );
          },
        ),
      );
    },
  ).then((_) {
    _isBottomSheetOpen = false;
  });
}
