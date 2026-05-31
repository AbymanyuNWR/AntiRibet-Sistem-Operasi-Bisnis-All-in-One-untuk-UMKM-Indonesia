import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _queueKey = 'offline_tx_queue';

  /// Adds a transaction payload to the offline queue
  Future<void> enqueueTransaction(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    
    // Add timestamp for local tracking
    payload['_queued_at'] = DateTime.now().toIso8601String();
    
    queue.add(jsonEncode(payload));
    await prefs.setStringList(_queueKey, queue);
  }

  /// Gets the count of pending transactions
  Future<int> getPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];
    return queue.length;
  }

  /// Attempts to sync all queued transactions to the backend
  Future<void> syncPendingTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList(_queueKey) ?? [];

    if (queue.isEmpty) return;

    final dio = DioClient().dio;
    List<String> remainingQueue = [];

    for (String itemStr in queue) {
      try {
        final Map<String, dynamic> payload = jsonDecode(itemStr);
        // Remove local metadata before sending
        payload.remove('_queued_at');

        final response = await dio.post('/merchant/pos/transactions', data: payload);
        
        if (response.statusCode == 200 && response.data['success'] == true) {
          // Success, do not add to remainingQueue
        } else {
          // Server error but reachable, maybe bad request. We might still remove it or keep it depending on logic.
          // For now, keep it if it's 5xx, discard if 4xx (except timeout).
          // To be safe, if we reach here and it's not success, we assume we should retry later unless we handle it explicitly.
          remainingQueue.add(itemStr);
        }
      } on DioException catch (e) {
        // If it's a network/timeout error, keep in queue
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          remainingQueue.add(itemStr);
        } else {
          // It's a 4xx or 5xx from server. We'll remove it to avoid blocking the queue forever,
          // or we can keep it for manual review. For this demo, let's remove 4xx errors, keep 5xx.
          if (e.response != null && e.response!.statusCode! >= 500) {
            remainingQueue.add(itemStr);
          }
        }
      } catch (_) {
        // Unknown error, keep in queue
        remainingQueue.add(itemStr);
      }
    }

    await prefs.setStringList(_queueKey, remainingQueue);
  }
}
