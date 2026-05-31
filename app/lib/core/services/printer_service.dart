import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class PrinterDevice {
  final String name;
  final String address;
  PrinterDevice(this.name, this.address);
}

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  PrinterDevice? connectedDevice;
  bool get isConnected => connectedDevice != null;

  // Simulasi mencari printer bluetooth
  Future<List<PrinterDevice>> scanDevices() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      PrinterDevice('Epson TM-m30', '00:11:22:33:44:55'),
      PrinterDevice('Mini Thermal 58mm', 'AA:BB:CC:DD:EE:FF'),
      PrinterDevice('Zebra ZQ320', '11:22:33:44:55:66'),
    ];
  }

  Future<bool> connect(PrinterDevice device) async {
    await Future.delayed(const Duration(seconds: 1));
    connectedDevice = device;
    debugPrint('Connected to thermal printer: ${device.name}');
    return true;
  }

  void disconnect() {
    debugPrint('Disconnected from thermal printer.');
    connectedDevice = null;
  }

  Future<bool> printReceipt(Map<String, dynamic> transactionData) async {
    if (!isConnected) {
      debugPrint('Error: No printer connected.');
      return false;
    }

    try {
      // --- ESC/POS Raw Byte Generator ---
      List<int> bytes = [];

      // Initialize Printer (ESC @)
      bytes.addAll([27, 64]);

      // Align Center (ESC a 1)
      bytes.addAll([27, 97, 1]);
      
      // Bold On (ESC E 1)
      bytes.addAll([27, 69, 1]);
      
      // Header Text
      bytes.addAll(utf8.encode("ANTI RIBET POS\n"));
      bytes.addAll(utf8.encode("==============================\n"));
      
      // Bold Off, Align Left
      bytes.addAll([27, 69, 0]);
      bytes.addAll([27, 97, 0]);
      
      bytes.addAll(utf8.encode("No Transaksi: ${transactionData['invoice_number'] ?? '-'}\n"));
      bytes.addAll(utf8.encode("Meja: ${transactionData['table_number'] ?? 'Takeaway'}\n"));
      bytes.addAll(utf8.encode("Kasir: ${transactionData['cashier_name'] ?? 'Admin'}\n"));
      bytes.addAll(utf8.encode("==============================\n"));
      
      // Items loop (Simulasi jika data items ada)
      if (transactionData['items'] != null && transactionData['items'] is List) {
        for (var item in transactionData['items']) {
          bytes.addAll(utf8.encode("${item['name'] ?? 'Item'}\n"));
          bytes.addAll(utf8.encode("  ${item['quantity']} x Rp ${item['price']} = Rp ${item['total_price'] ?? (item['quantity'] * item['price'])}\n"));
        }
      } else {
        bytes.addAll(utf8.encode("Total Tagihan\n"));
      }
      
      bytes.addAll(utf8.encode("------------------------------\n"));
      
      // Align Right for Total
      bytes.addAll([27, 97, 2]);
      bytes.addAll([27, 69, 1]); // Bold
      bytes.addAll(utf8.encode("TOTAL: Rp ${transactionData['total_amount']}\n"));
      bytes.addAll([27, 69, 0]); // Unbold
      
      // Align Center for Footer
      bytes.addAll([27, 97, 1]);
      bytes.addAll(utf8.encode("------------------------------\n"));
      bytes.addAll(utf8.encode("Terima kasih atas kunjungan Anda!\n"));
      bytes.addAll(utf8.encode("Powered by AntiRibet.com\n"));
      
      // Feed 4 lines (Print and feed paper)
      bytes.addAll([27, 100, 4]);
      
      // Cut Paper (GS V 0)
      bytes.addAll([29, 86, 0]);

      // Karena kita running di Windows/Web tanpa native bluetooth device:
      // Kita membuang output byte ke log untuk membuktikan "Super Logic" ini berjalan.
      debugPrint('--- ESC/POS BYTES GENERATED SUCCESSFULLY ---');
      debugPrint('Bytes Length: ${bytes.length}');
      debugPrint('Raw Data: $bytes');
      debugPrint('---------------------------------------------');

      await Future.delayed(const Duration(milliseconds: 500)); // Simulate transmission
      return true;
      
    } catch (e) {
      debugPrint('Print Error: $e');
      return false;
    }
  }
}
