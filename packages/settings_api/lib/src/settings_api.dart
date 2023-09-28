/// The interface for an API that provides access to the 'settings'.
abstract class SettingsApi {
  /// Creates an instance of the [SettingsApi] abstract class.
  ///
  /// This serves as the contract for all classes that implement settings
  /// storage and retrieval operations. Any class that implements [SettingsApi]
  /// must provide concrete implementations for all its methods.
  const SettingsApi();

  /// Checks if the key exists.
  ///
  /// Returns 'bool'.
  bool containsKey({required String key});

  /// Gets an 'setting' of type 'bool'.
  ///
  /// If no 'setting' with the given key exists, a
  /// [KeyNotFoundOnDatabaseException] error is thrown.
  bool getBool({required String key});

  /// Gets an 'setting' of type 'String'.
  ///
  /// If no 'setting' with the given key exists, a
  /// [KeyNotFoundOnDatabaseException] error is thrown.
  String getString({required String key});

  /// Saves an 'setting' of type 'bool'.
  ///
  /// If an 'setting' with the same key already exists, it will be replaced.
  Future<void> saveBool({
    required String key,
    required bool value,
  });

  /// Saves an 'setting' of type 'String'.
  ///
  /// If an 'setting' with the same key already exists, it will be replaced.
  Future<void> saveString({
    required String key,
    required String value,
  });

  /// Deletes the 'setting' with the given key.
  ///
  /// If no 'setting' with the given key exists, a
  /// [KeyNotFoundOnDatabaseException] error is thrown.
  Future<void> deleteEntry({required String key});
}

/// Error thrown when an 'setting' with a given key is not found.
class KeyNotFoundOnDatabaseException implements Exception {}
