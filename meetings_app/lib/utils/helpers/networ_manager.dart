import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:meetings_app/utils/popups/loaders.dart';

class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
      _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        _updateConnectionStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);
      });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus.value = result;
    if (_connectionStatus.value == ConnectivityResult.none) {
      LLoaders.customToast(message: 'No Internet Connection');
    }
  }


  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty && results.first != ConnectivityResult.none;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Dispose or close the active connectivity stream
  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
