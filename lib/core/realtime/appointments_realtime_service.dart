import 'dart:async';
import 'dart:convert';

import 'package:sigetu/core/auth/auth_session.dart';
import 'package:sigetu/core/constants/api_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppointmentsRealtimeService {
  AppointmentsRealtimeService({String? wsUrl})
      : _wsUrl = wsUrl ?? ApiConstants.appointmentsWsUrl;

  final String _wsUrl;

  final _updatesController = StreamController<void>.broadcast();
  Stream<void> get updates => _updatesController.stream;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _reconnectTimer;
  bool _disposed = false;

  void connect() {
    if (_disposed || !AuthSession.hasToken || _channel != null) {
      return;
    }

    final uri = _buildUriWithToken();
    _channel = WebSocketChannel.connect(uri);
    _channelSubscription = _channel!.stream.listen(
      (message) {
        if (_disposed) return;

        if (message is String && message.isNotEmpty) {
          try {
            jsonDecode(message);
          } catch (_) {}
        }

        _updatesController.add(null);
      },
      onDone: _scheduleReconnect,
      onError: (_) => _scheduleReconnect(),
      cancelOnError: true,
    );
  }

  Uri _buildUriWithToken() {
    final uri = Uri.parse(_wsUrl);
    final params = <String, String>{...uri.queryParameters};

    if (AuthSession.hasToken) {
      params['token'] = AuthSession.accessToken!;
    }

    return uri.replace(queryParameters: params);
  }

  void _scheduleReconnect() {
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel = null;

    if (_disposed || !AuthSession.hasToken) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), connect);
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _channelSubscription?.cancel();
    _channelSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    await _updatesController.close();
  }
}
