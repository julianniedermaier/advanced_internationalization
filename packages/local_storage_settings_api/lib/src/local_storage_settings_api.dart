import 'dart:async';
import 'package:settings_api/settings_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [LocalStorageSettingsApi] is a Flutter implementation of the [SettingsApi]
/// that uses SharedPreferences as its local storage mechanism.
///
/// This class provides methods to save, retrieve, and delete settings in a
/// key-value pair format.
class LocalStorageSettingsApi extends SettingsApi {
  /// Constructs a new [LocalStorageSettingsApi] instance, which requires
  /// [SharedPreferences] as its local storage plugin.
  LocalStorageSettingsApi({
    required SharedPreferences plugin,
  }) : _plugin = plugin;

  /// An instance of the [SharedPreferences] plugin used for local storage.
  final SharedPreferences _plugin;

  /// Checks if the given key exists in the local storage.
  ///
  /// Returns true if the key exists, otherwise returns false.
  bool _containsKey(String key) => _plugin.containsKey(key);

  /// Retrieves the boolean value associated with the given key.
  ///
  /// Returns null if the key is not found.
  bool? _getBoolValue(String key) {
    try {
      return _plugin.getBool(key);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the string value associated with the given key.
  ///
  /// Returns null if the key is not found.
  String? _getStringValue(String key) {
    try {
      return _plugin.getString(key);
    } catch (_) {
      return null;
    }
  }

  /// Saves a string value with the given key.
  Future<void> _setStringValue(String key, String value) =>
      _plugin.setString(key, value);

  /// Saves a boolean value with the given key.
  Future<void> _setBoolValue(String key, bool value) =>
      _plugin.setBool(key, value);

  /// Deletes an entry with the given key.
  Future<bool> _deleteEntry(String key) => _plugin.remove(key);

  /// Public API to check if a key exists in the local storage.
  @override
  bool containsKey({required String key}) {
    return _containsKey(key);
  }

  /// Public API to get a boolean value.
  ///
  /// Throws [KeyNotFoundOnDatabaseException] if the key is not found.
  @override
  bool getBool({required String key}) {
    final setting = _getBoolValue(key);
    if (setting != null) {
      return setting;
    } else {
      throw KeyNotFoundOnDatabaseException();
    }
  }

  /// Public API to get a string value.
  ///
  /// Throws [KeyNotFoundOnDatabaseException] if the key is not found.
  @override
  String getString({required String key}) {
    final setting = _getStringValue(key);
    if (setting != null) {
      return setting;
    } else {
      throw KeyNotFoundOnDatabaseException();
    }
  }

  /// Public API to save a boolean value.
  @override
  Future<void> saveBool({
    required String key,
    required bool value,
  }) {
    return _setBoolValue(key, value);
  }

  /// Public API to save a string value.
  @override
  Future<void> saveString({
    required String key,
    required String value,
  }) {
    return _setStringValue(key, value);
  }

  /// Public API to delete an entry by key.
  ///
  /// Throws [KeyNotFoundOnDatabaseException] if the key is not found.
  @override
  Future<void> deleteEntry({required String key}) async {
    final deleted = await _deleteEntry(key);
    if (!deleted) {
      throw KeyNotFoundOnDatabaseException();
    }
  }
}
