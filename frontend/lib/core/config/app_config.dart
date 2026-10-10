
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Global application configuration and environment settings.
class AppConfig {
  static const String appName = 'ShopLite';
  static const Duration requestTimeout = Duration(seconds: 12);

  // Override using --dart-define=API_URL=http://...
  static const String _definedBaseUrl =
      String.fromEnvironment('API_URL');

  static String _customBaseUrl = '';

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    if (_definedBaseUrl.isNotEmpty) {
      return _definedBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(
      RegExp(r'/+$'),
      '',
    );
  }

  static void resetCustomBaseUrl() {
    _customBaseUrl = '';
  }
}
