import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/connectivity_service.dart';

// ──────────────────────────────────────────────
// States
// ──────────────────────────────────────────────

abstract class ConnectivityState {}

/// Initial state before the first connectivity check completes.
class ConnectivityInitial extends ConnectivityState {}

/// Device has active network connection.
class ConnectivityOnline extends ConnectivityState {}

/// Device has lost network connection.
class ConnectivityOffline extends ConnectivityState {}

// ──────────────────────────────────────────────
// Cubit
// ──────────────────────────────────────────────

/// Monitors network connectivity in real-time and emits
/// [ConnectivityOnline] / [ConnectivityOffline] states.
///
/// Provide this at the top of the widget tree (e.g. in `main.dart`)
/// so the entire app can react to connectivity changes.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit(this._service) : super(ConnectivityInitial()) {
    _init();
  }

  Future<void> _init() async {
    // Emit the current status immediately
    final connected = await _service.isConnected;
    if (isClosed) return;
    emit(connected ? ConnectivityOnline() : ConnectivityOffline());

    // Listen for changes
    _subscription = _service.onConnectivityChanged.listen((connected) {
      if (isClosed) return;
      emit(connected ? ConnectivityOnline() : ConnectivityOffline());
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
