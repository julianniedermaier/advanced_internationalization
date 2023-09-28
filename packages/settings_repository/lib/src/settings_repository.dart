import 'package:settings_api/settings_api.dart';

/// A repository that handles `setting` related requests.
class SettingsRepository {
  /// Constructs a [SettingsRepository] with a given [SettingsApi].
  ///
  /// The [settingsApi] parameter must not be `null`.
  ///
  /// ```
  /// final settingsRepository = SettingsRepository(
  ///   settingsApi: SettingsApiImpl(),
  /// );
  /// ```
  const SettingsRepository({
    required SettingsApi settingsApi,
  }) : _settingsApi = settingsApi;

  final SettingsApi _settingsApi;

  /// Checks if the key exists.
  ///
  /// Returns 'bool'.
  bool containsKey({required String key}) =>
      _settingsApi.containsKey(key: key);

  /// Gets an 'setting' of type 'bool'.
  ///
  /// If no 'setting' with the given key exists, a
  /// [KeyNotFoundOnDatabaseException] error is thrown.
  bool getBool({required String key}) =>
      _settingsApi.getBool(key: key);

  /// Gets an 'setting' of type 'String'.
  ///
  /// If no 'setting' with the given key exists, a
  /// [KeyNotFoundOnDatabaseException] error is thrown.
  String getString({required String key}) =>
      _settingsApi.getString(key: key);

  /// Saves an 'setting' of type 'bool'.
  ///
  /// If an 'setting' with the same key already exists, it will be replaced.
  Future<void> saveBool({
    required String key,
    required bool value,
  }) =>
      _settingsApi.saveBool(
        key: key,
        value: value,
      );

  /// Saves an 'setting' of type 'String'.
  ///
  /// If an 'setting' with the same key already exists, it will be replaced.
  Future<void> saveString({
    required String key,
    required String value,
  }) =>
      _settingsApi.saveString(
        key: key,
        value: value,
      );

  /// Deletes the 'setting' with the given key.
  ///
  /// If no 'setting' with the given key exists, a
  /// [KeyNotFoundOnDatabaseException] error is thrown.
  Future<void> deleteEntry({required String key}) =>
      _settingsApi.deleteEntry(key: key);
}
