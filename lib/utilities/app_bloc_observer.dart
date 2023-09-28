import 'dart:developer';

import 'package:bloc/bloc.dart';

/// [AppBlocObserver] observes all [Bloc] and [Cubit] instances throughout the
/// app.
///
/// It logs state changes and errors to the console, making it easier to debug
/// and trace the flow of events and state changes.
///
/// This observer should be initialized in the main function like so:
/// ```dart
/// void main() {
///   Bloc.observer = const AppBlocObserver();
///   ...
/// }
/// ```
class AppBlocObserver extends BlocObserver {
  /// Creates an instance of [AppBlocObserver].
  const AppBlocObserver();

  /// Called anytime a [Change] occurs in any [Bloc] or [Cubit].
  ///
  /// A [Change] occurs when a new state is emitted. This method logs the type
  /// of [Bloc] or [Cubit] along with the [Change] that occurred.
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    log('onChange(${bloc.runtimeType}, $change)');
    super.onChange(bloc, change);
  }

  /// Called anytime an [error] is thrown in any [Bloc] or [Cubit].
  ///
  /// This method logs the type of [Bloc] or [Cubit] where the error occurred,
  /// along with the [error] object and its [StackTrace].
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
