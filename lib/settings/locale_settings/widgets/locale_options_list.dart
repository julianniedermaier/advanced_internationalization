import 'package:advanced_internationalization/l10n/l10n.dart';
import 'package:advanced_internationalization/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Constructs a scrollable list of locale options.
///
/// Listens to the [LocaleSettingsBloc] to detect changes in the application's
/// locale state and updates the list accordingly.
///
/// This function relies on a [LocaleSettingsBloc] to manage locale settings.
/// Make sure the bloc is properly set up in your application.
///
/// - [context]: The BuildContext for the widget.
/// - [controller]: A ScrollController to manage the scrolling behavior.
///
/// Example:
/// ```dart
/// localeOptionsList(context: context, controller: scrollController)
/// ```
Widget localeOptionsList({
  required BuildContext context,
  required ScrollController controller,
  required VoidCallback onClose,
}) {
  return BlocConsumer<LocaleSettingsBloc, LocaleSettingsState>(
    listenWhen: (previous, current) =>
        previous.selectedLocale != current.selectedLocale,
    listener: (context, state) => onClose(),
    builder: (context, state) {
      final isDeviceLocale = state.selectedLocale == systemLocaleOption;
      final localeOptionsMap = localeOptions(
        context: context,
        selectedLocaleOption: state.selectedLocale,
        isDeviceLocale: isDeviceLocale,
        deviceLocale: state.deviceLocale,
      );
      final leadingItemCount = isDeviceLocale ? 1 : 2;

      return CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          _buildSliverAppBar(
            context: context,
            onPressed: onClose,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == leadingItemCount) {
                  return const Divider();
                }
                return _buildRadioListTile(
                  context: context,
                  localeOptionsMap: localeOptionsMap,
                  index: index < leadingItemCount ? index : index - 1,
                  // Taking into account the divider in the index count
                  selectedLocaleOption: state.selectedLocale,
                );
              },
              childCount: localeOptionsMap.length + 1,
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildSliverAppBar({
  required BuildContext context,
  required VoidCallback onPressed,
}) {
  return SliverAppBar(
    leading: IconButton(
      key: localeSheetCloseButtonKey,
      onPressed: onPressed,
      icon: const Icon(Icons.close),
    ),
    title: Text(context.l10n.chooseLocale),
    automaticallyImplyLeading: false,
    pinned: true,
  );
}

Widget _buildRadioListTile({
  required BuildContext context,
  required Map<Locale, LocaleDisplayOption> localeOptionsMap,
  required int index,
  required Locale selectedLocaleOption,
}) {
  final locale = localeOptionsMap.keys.elementAt(index);
  final localeDisplayOption = localeOptionsMap[locale]!;

  return LocaleRadioListTile(
    key: ObjectKey(locale),
    locale: locale,
    localeDisplayOption: localeDisplayOption,
    selectedLocaleOption: selectedLocaleOption,
    onLocaleChanged: (newLocale) {
      context.read<LocaleSettingsBloc>().add(
            ChangeLocaleSettings(
              index == 0 ? null : newLocale,
            ),
          );
    },
  );
}
