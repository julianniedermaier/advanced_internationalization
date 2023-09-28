import 'package:mocktail/mocktail.dart';
import 'package:settings_api/settings_api.dart';
import 'package:settings_repository/settings_repository.dart';
import 'package:test/test.dart';

class MockSettingsApi extends Mock implements SettingsApi {}

void main() {
  group('SettingsRepository', () {
    late SettingsApi api;
    late SettingsRepository subject;

    const testKey = 'TestKey';
    const testStringValue = 'Test String';
    const testBoolValue = true;

    setUp(() {
      api = MockSettingsApi();
      subject = SettingsRepository(settingsApi: api);
    });

    tearDown(() {
      reset(api);
    });

    /// Helper function configuring the behavior of the `MockSettingsApi`.
    void _setupMockSettingsApi(
      bool hasEntry, {
      String? savedStringValue,
      bool? savedBoolValue,
    }) {
      when(() => api.containsKey(key: any(named: 'key'))).thenReturn(hasEntry);

      if (hasEntry && savedStringValue != null) {
        when(() => api.getString(key: any(named: 'key')))
            .thenReturn(savedStringValue);
      } else {
        when(() => api.getString(key: any(named: 'key')))
            .thenThrow(KeyNotFoundOnDatabaseException());
      }

      if (hasEntry && savedBoolValue != null) {
        when(() => api.getBool(key: any(named: 'key')))
            .thenReturn(savedBoolValue);
      } else {
        when(() => api.getBool(key: any(named: 'key')))
            .thenThrow(KeyNotFoundOnDatabaseException());
      }
    }

    /// This group of tests validates the entry retrieval functionality of the
    /// `SettingsApi`.
    group('get shared preference entry', () {

      /// Validates that containsKey returns true if a given key exists.
      test('containsKey returns true when entry exists', () {
        _setupMockSettingsApi(true);
        expect(subject.containsKey(key: testKey), true);
        verify(() => api.containsKey(key: any(named: 'key'))).called(1);
      });

      /// Validates that containsKey returns false if a given key does not
      /// exist.
      test('containsKey returns false when entry does not exist', () {
        _setupMockSettingsApi(false);
        expect(subject.containsKey(key: testKey), false);
        verify(() => api.containsKey(key: any(named: 'key'))).called(1);
      });

      /// Validates that a requested string is returned if it exists.
      test('getString retrieves correct string when entry exists', () {
        _setupMockSettingsApi(true, savedStringValue: testStringValue);
        expect(subject.getString(key: testKey), testStringValue);
        verify(() => api.getString(key: any(named: 'key'))).called(1);
      });

      /// Validates that an exception is thrown if a requested string does not
      /// exist.
      test('getString throws exception when entry does not exist', () {
        _setupMockSettingsApi(false);
        expect(() => subject.getString(key: testKey), throwsException);
        verify(() => api.getString(key: any(named: 'key'))).called(1);
      });

      /// Validates that a requested bool is returned if it exists.
      test('getBool retrieves correct bool when entry exists', () {
        _setupMockSettingsApi(true, savedBoolValue: testBoolValue);
        expect(subject.getBool(key: testKey), testBoolValue);
        verify(() => api.getBool(key: any(named: 'key'))).called(1);
      });

      /// Validates that an exception is thrown if a requested bool does not
      /// exist.
      test('getBool throws exception when entry does not exist', () {
        _setupMockSettingsApi(false);
        expect(() => subject.getBool(key: testKey), throwsException);
        verify(() => api.getBool(key: any(named: 'key'))).called(1);
      });
    });

    /// This group of tests validates the saving functionality of the
    /// `SettingsApi`.
    group('set shared preferences entry', () {
      group('create new entry', () {
        setUp(() {
          when(
            () => api.saveString(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async => true);
          when(
            () => api.saveBool(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async => true);
        });

        /// Validates that a string can be successfully saved to
        /// sharedPreferences.
        test('saveString successfully saves string', () async {
          await subject.saveString(key: testKey, value: testStringValue);
          verify(
            () => api.saveString(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).called(1);
        });

        /// Validates that a bool can be successfully saved to
        /// sharedPreferences.
        test('saveBool successfully saves bool', () async {
          await subject.saveBool(key: testKey, value: testBoolValue);
          verify(
            () => api.saveBool(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).called(1);
        });
      });
    });

    /// This group of tests validates the delete functionality of the
    /// `LocalStorageSettingsApi`.
    group('delete shared preferences entry', () {

      /// Validates that a shared preference entry can be successfully deleted.
      test('deleteEntry successfully deletes when entry exists', () async {
        when(() => api.deleteEntry(key: any(named: 'key')))
            .thenAnswer((_) async => true);
        await subject.deleteEntry(key: testKey);
        verify(() => api.deleteEntry(key: any(named: 'key'))).called(1);
      });

      /// Validates behavior when attempting to delete a non-existent shared
      /// preference entry.
      test('deleteEntry throws exception when entry does not exist', () async {
        when(() => api.deleteEntry(key: any(named: 'key')))
            .thenThrow(KeyNotFoundOnDatabaseException());
        expect(() async => subject.deleteEntry(key: testKey), throwsException);
        verify(() => api.deleteEntry(key: any(named: 'key'))).called(1);
      });
    });
  });
}
