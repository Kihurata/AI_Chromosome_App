import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around [Connectivity] that exposes a [Stream<bool>]
/// indicating whether the device currently has network access.
///
/// This service is consumed by [ConnectivityCubit] — presentation
/// widgets should NOT depend on it directly.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream that emits `true` when connected, `false` when offline.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      // connectivity_plus returns a List<ConnectivityResult>
      return results.any((r) => r != ConnectivityResult.none);
    });
  }

  /// One-shot check of the current connectivity status.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
