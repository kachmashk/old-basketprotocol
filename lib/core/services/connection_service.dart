import 'dart:async';

import 'package:connectivity/connectivity.dart';

abstract class BaseConnectionService {
  Stream<bool> get connection;
  bool getStatusFromResult(ConnectivityResult _result);
}

class ConnectionService implements BaseConnectionService {
  Stream<bool> get connection {
    return Connectivity()
        .onConnectivityChanged
        .map((ConnectivityResult _result) {
      return getStatusFromResult(_result);
    });
  }

  bool getStatusFromResult(ConnectivityResult _result) {
    switch (_result) {
      case ConnectivityResult.wifi:
        return true;
        break;
      case ConnectivityResult.mobile:
        return true;
        break;
      case ConnectivityResult.none:
        return false;
        break;
      default:
        return null;
    }
  }
}
