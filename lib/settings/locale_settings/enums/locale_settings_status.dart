/// Describes the status of the `LocaleSettingsState`.
enum LocaleSettingsStatus {
  /// Status before any initial modification to the `LocaleSettingsState`.
  initial,

  /// Status of the `LocaleSettingsState` during any operation of the
  /// `LocaleSettingsBloc`.
  loading,

  /// Status of the `LocaleSettingsState` upon successful completion of any
  /// operation of the `LocaleSettingsBloc`.
  success,

  /// Status of the `LocaleSettingsState` when an error occurs during any
  /// operation of the `LocaleSettingsBloc`.
  failure,
}
