// Centralized API configuration
// Uses Android emulator loopback (10.0.2.2) when running on Android; otherwise localhost.
import 'dart:io' show Platform;
import 'env.dart';

class Api {
  static String get _host {
    // Android emulator needs special host to reach host machine
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get _devBase {
    final host = Env.devHostOverride.isNotEmpty ? Env.devHostOverride : _host;
    return 'http://$host:${Env.devPort}';
  }

  static String get base => Env.prod ? Env.prodBase : _devBase;
  static String path(String p) => '$base$p';

  // Auth
  static String get login => path('/api/login');
  static String get register => path('/api/register');
  static String get me => path('/api/me');

  // Music
  static String like(String musicId) => path('/api/music/like/$musicId');
  // Use query parameter 'q' for search to avoid complex path encodings
  static String search(String q) => path('/api/music/search?q=${Uri.encodeComponent(q)}');
  static String streamByFilename(String filename) => path('/api/music/$filename');

  // Normalize image/audio URLs returned by backend.
  // Backend may return URLs with 'localhost' which is not reachable from Android emulator.
  // Replace 'localhost' with the emulator host when necessary (10.0.2.2 on Android).
  static String normalizeUrl(dynamic url) {
    // Accepts nullable/dynamic inputs from decoded JSON.
    if (url == null) return '';
    final s = url.toString();
    if (s.isEmpty) return '';
    if (s.contains('localhost')) {
      return s.replaceAll('localhost', _host);
    }
    return s;
  }
}
