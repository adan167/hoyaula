import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    _connectivity.onConnectivityChanged.listen((result) {
      _isConnected = !result.contains(ConnectivityResult.none);
      notifyListeners();
    });
    _initialize();
  }

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> _initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = !result.contains(ConnectivityResult.none);
    notifyListeners();
  }
}
