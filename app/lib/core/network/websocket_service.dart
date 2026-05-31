import 'package:flutter/foundation.dart';
// Note: Butuh package `pusher_channels_flutter` atau `laravel_echo` di pubspec.yaml

class WebsocketService {
  // Simulasi singleton untuk koneksi websocket
  static final WebsocketService _instance = WebsocketService._internal();
  factory WebsocketService() => _instance;
  WebsocketService._internal();

  bool isConnected = false;

  /// Membuka koneksi websocket ke Laravel Reverb
  Future<void> connect(String token, int businessId) async {
    try {
      debugPrint('Connecting to Laravel Reverb via ws://api.antiribet.id:8080...');
      
      // Setup Laravel Echo Client (Dummy logic)
      /*
      final echo = Echo(
        broadcaster: EchoBroadcasterType.Pusher,
        client: PusherClient(
          'reverb-app-key',
          PusherOptions(
            wsHost: 'api.antiribet.id',
            wsPort: 8080,
            forceTLS: false,
            disableStats: true,
            auth: PusherAuth('https://api.antiribet.id/api/broadcasting/auth',
              headers: {'Authorization': 'Bearer $token'}
            ),
          ),
        ),
      );
      */
      
      isConnected = true;
      _listenToMerchantChannel(businessId);
    } catch (e) {
      debugPrint('Websocket Connection Failed: $e');
    }
  }

  void _listenToMerchantChannel(int businessId) {
    debugPrint('Subscribing to private channel: private-merchant.$businessId');
    
    // echo.private('merchant.$businessId').listen('.qr.order.new', (e) {
    //   debugPrint('NEW QR ORDER RECEIVED IN REALTIME! ${e['transaction_number']}');
    //   // TODO: Dispatch event ke QueueMonitorBloc / BLoC Dapur
    // });
  }

  void disconnect() {
    // echo.disconnect();
    isConnected = false;
  }
}
