import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:promise_client/promise_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

// When you are running the app on a physical device, you need to set the
// server URL to the IP address of your computer. You can find the IP
// address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
//
// You can set the variable when running or building your app like this:
// E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`.
//
// Otherwise, the server URL is fetched from the assets/config.json file or
// defaults to http://$localhost:8080/ if not found.
final serverUrl = getServerUrl();

Client? _client;

/// Returns the global client instance. Throws StateError if called before setupClient().
Client get client {
  if (_client == null) {
    throw StateError(
      'Client has not been initialized. Call setupClient() first.',
    );
  }
  return _client!;
}

/// Sets up the global client object exactly once.
/// Safe to call multiple times on Retry.
Future<void> setupClient() async {
  if (_client != null) return;
  debugPrint('CLIENT: Creating Serverpod client with URL: ${await serverUrl}');
  _client = Client(await serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
}
