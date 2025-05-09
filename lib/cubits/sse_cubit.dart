// ⚠️ TEST IMPLEMENTATION — NOT SECURE FOR PRODUCTION
// This example demonstrates basic Server-Sent Events (SSE) handling in Flutter using Cubit.
// In production, secure the connection using HTTPS, validate the user with tokens,
// and handle errors and retries more robustly.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

class SseCubit extends Cubit<SseState> {
  late HttpClient _httpClient;
  HttpClientRequest? _request;
  HttpClientResponse? _response;
  StreamSubscription<String>? _subscription;
  Timer? _reconnectTimer;
  String? _currentUserId;

  SseCubit() : super(SseInitial()) {
    _httpClient = HttpClient();
  }

  // ⚠️ In production, pass a secure token and use HTTPS!
  Future<void> connectSSE(String userId) async {
    try {
      _currentUserId = userId;
      await _disconnect(); // clean previous connection if any
      emit(SseConnecting());

      // Android emulator uses 10.0.2.2 to access host machine
      final url =
          Platform.isAndroid ? "http://10.0.2.2:3000" : "http://127.0.0.1:3000";

      _request = await _httpClient.getUrl(
        Uri.parse('$url/events?userId=$userId'),
      );

      _response = await _request!.close();
      final stream = _response!.transform(utf8.decoder);

      // Start listening to SSE stream
      _subscription = stream.listen(
        _handleData,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      emit(SseConnected(messages: []));
    } catch (e) {
      emit(SseError('Connection failed: ${e.toString()}'));
      _scheduleReconnect();
    }
  }

  // Process incoming SSE message
  void _handleData(String data) {
    if (data.contains('event: session-end')) {
      final message = data.split('data: ')[1].trim();
      emit(SseSessionEnded(message: message));
      _disconnect(); // Stop SSE on session end
    } else if (data.startsWith('data:')) {
      final message = data.replaceFirst('data:', '').trim();
      if (state is SseConnected) {
        final currentState = state as SseConnected;
        emit(SseConnected(messages: [...currentState.messages, message]));
      }
    }
  }

  // Handle errors in SSE stream
  void _handleError(dynamic error) {
    emit(SseError('Connection error: ${error.toString()}'));
    _scheduleReconnect();
  }

  // Called when SSE connection is closed
  void _handleDisconnect() {
    emit(SseDisconnected());
  }

  // Public method to disconnect SSE manually
  Future<void> disconnect() async {
    await _disconnect();
    emit(SseDisconnected());
  }

  // Cancel and clean up resources
  Future<void> _disconnect() async {
    await _subscription?.cancel();
    _request?.abort();
    _reconnectTimer?.cancel();
    _subscription = null;
    _request = null;
    _response = null;
  }

  // Retry connection after delay (simple reconnection logic)
  void _scheduleReconnect() {
    if (_currentUserId == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (_currentUserId != null) {
        connectSSE(_currentUserId!);
      }
    });
  }

  @override
  Future<void> close() {
    _disconnect();
    _httpClient.close();
    return super.close();
  }
}

// States used by the SseCubit

abstract class SseState {}

class SseInitial extends SseState {}

class SseConnecting extends SseState {}

class SseConnected extends SseState {
  final List<String> messages;
  SseConnected({required this.messages});
}

class SseDisconnected extends SseState {}

class SseSessionEnded extends SseState {
  final String message;
  SseSessionEnded({required this.message});
}

class SseError extends SseState {
  final String message;
  SseError(this.message);
}
