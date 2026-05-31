import 'package:flutter/foundation.dart';

/// Simulasi Local Database menggunakan drift / sqflite (Mock/Scaffold)
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  /// Menyimpan katalog menu secara lokal agar bisa dipanggil saat kasir sedang offline.
  Future<void> cacheCatalogItems(List<Map<String, dynamic>> items) async {
    debugPrint('LocalDatabase: Caching ${items.length} items to local sqlite db...');
    // Logika sqflite INSERT OR REPLACE INTO catalog_items
  }

  /// Jika kasir offline, transaksi POS disave ke sqlite tabel `pending_transactions`
  Future<void> savePendingTransaction(Map<String, dynamic> transactionPayload) async {
    debugPrint('LocalDatabase: Saving 1 pending transaction locally (Internet Offline)');
    // Logika sqflite INSERT INTO pending_transactions
  }

  /// Ambil semua transaksi yang belum ter-sinkronisasi ke server (Laravel)
  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    // Ambil dari sqlite SELECT * FROM pending_transactions
    return []; 
  }

  /// Hapus transaksi dari queue lokal jika sudah sukses di-sync ke server
  Future<void> removePendingTransaction(int localId) async {
    debugPrint('LocalDatabase: Removing synced transaction #$localId');
  }
}
