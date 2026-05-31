import 'dart:async';
import 'package:flutter/foundation.dart';

/// SyncService - Mengelola sinkronisasi transaksi offline ke server
/// (LocalDatabase belum diimplementasikan, menggunakan in-memory queue untuk sementara)
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Timer? _syncTimer;

  // In-memory queue untuk transaksi offline
  final List<Map<String, dynamic>> _pendingQueue = [];

  int get pendingCount => _pendingQueue.length;

  Future<int> getPendingCount() async {
    return _pendingQueue.length;
  }

  void addPendingTransaction(Map<String, dynamic> tx) {
    _pendingQueue.add(tx);
    debugPrint('SyncService: Queued transaction. Total pending: ${_pendingQueue.length}');
  }

  void startBackgroundSync() {
    debugPrint('SyncService: Starting Background Sync Worker...');
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_pendingQueue.isEmpty) return;
      debugPrint('SyncService: Found ${_pendingQueue.length} pending transactions.');
    });
  }

  void stop() {
    _syncTimer?.cancel();
  }
}
