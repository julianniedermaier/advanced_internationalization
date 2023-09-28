import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_settings_api/local_storage_settings_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:settings_api/settings_api.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('LocalStorageSettingsApi', () {
    late SharedPreferences plugin;
    late LocalStorageSettingsApi subject;

    const testKey = 'TestKey';
    const testStringValue = 'Test String';
    const testBoolValue = true;

    setUp(() {
      plugin = MockSharedPreferences();
      subject = LocalStorageSettingsApi(plugin: plugin);
    });

    tearDown(() {
      reset(plugin);
    });

    /// Helper function configuring the behavior of the `MockSharedPreferences`.
    void _setupMockSharedPreferences(
      bool hasEntry, {
      String? savedStringValue,
      bool? savedBoolValue,
    }) {
      when(() => plugin.containsKey(any())).thenReturn(hasEntry);
      when(() => plugin.getString(any())).thenReturn(savedStringValue);
      when(() => plugin.getBool(any())).thenReturn(savedBoolValue);
    }

    /// This group of tests validates the entry retrieval functionality of the
    /// `LocalStorageSettingsApi`.
    group('get shared preference entry', () {

      /// Validates that containsKey returns true if a given key exists.
      test('containsKey returns true when entry exists', () {
        _setupMockSharedPreferences(true);
        expect(subject.containsKey(key: testKey), true);
        verify(() => plugin.containsKey(any())).called(1);
      });

      /// Validates that containsKey returns false if a given key does not
      /// exist.
      test('containsKey returns false when entry does not exist', () {
        _setupMockSharedPreferences(false);
        expect(subject.containsKey(key: testKey), false);
        verify(() => plugin.containsKey(any())).called(1);
      });

      /// Validates that a requested string is returned if it exists.
      test('getString retrieves correct string when entry exists', () {
        _setupMockSharedPreferences(true, savedStringValue: testStringValue);
        expect(subject.getString(key: testKey), testStringValue);
        verify(() => plugin.getString(any())).called(1);
      });

      /// Validates that an exception is thrown if a requested string does not
      /// exist.
      test('getString throws exception when entry does not exist', () {
        _setupMockSharedPreferences(false);
        expect(() => subject.getString(key: testKey), throwsException);
        verify(() => plugin.getString(any())).called(1);
      });

      /// Validates that a requested bool is returned if it exists.
      test('getBool retrieves correct bool when entry exists', () {
        _setupMockSharedPreferences(true, savedBoolValue: testBoolValue);
        expect(subject.getBool(key: testKey), testBoolValue);
        verify(() => plugin.getBool(any())).called(1);
      });

      /// Validates that an exception is thrown if a requested bool does not
      /// exist.
      test('getBool throws exception when entry does not exist', () {
        _setupMockSharedPreferences(false);
        expect(() => subject.getBool(key: testKey), throwsException);
        verify(() => plugin.getBool(any())).called(1);
      });
    });

    /// This group of tests validates the saving functionality of the
    /// `LocalStorageSettingsApi`.
    group('set shared preferences entry', () {
      group('create new entry', () {
        setUp(() {
          when(() => plugin.setString(any(), any()))
              .thenAnswer((_) async => true);
          when(() => plugin.setBool(any(), any()))
              .thenAnswer((_) async => true);
        });

        /// Validates that a string can be successfully saved to
        /// sharedPreferences.
        test('setString successfully saves string', () async {
          await subject.saveString(key: testKey, value: testStringValue);
          verify(() => plugin.setString(any(), any())).called(1);
        });

        /// Validates that a bool can be successfully saved to
        /// sharedPreferences.
        test('setBool successfully saves bool', () async {
          await subject.saveBool(key: testKey, value: testBoolValue);
          verify(() => plugin.setBool(any(), any())).called(1);
        });
      });
    });

    /// This group of tests validates the delete functionality of the
    /// `LocalStorageSettingsApi`.
    group('delete shared preferences entry', () {

      /// Validates that a shared preference entry can be successfully deleted.
      test('remove successfully deletes when entry exists', () async {
        when(() => plugin.remove(any())).thenAnswer((_) async => true);
        await subject.deleteEntry(key: testKey);
        verify(() => plugin.remove(any())).called(1);
      });

      /// Validates behavior when attempting to delete a non-existent shared
      /// preference entry.
      test('remove throws exception when entry does not exist', () async {
        when(() => plugin.remove(any()))
            .thenThrow(KeyNotFoundOnDatabaseException());
        expect(() async => subject.deleteEntry(key: testKey), throwsException);
        verify(() => plugin.remove(any())).called(1);
      });
    });
  });
}
