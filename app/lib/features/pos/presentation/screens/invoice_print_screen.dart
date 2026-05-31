import 'package:flutter/material.dart';

class InvoicePrintScreen extends StatelessWidget {
  final String trxNumber;

  const InvoicePrintScreen({super.key, required this.trxNumber});

  @override
  Widget build(BuildContext context) {
    // Pada real app, view ini bisa di-convert jadi bitmap/image untuk dikirim ke package blue_thermal_printer
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak Struk Thermal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Trigger bluetooth print
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          width: 300, // Simulasi lebar kertas 58mm/80mm
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('--- ANTIRIBET POS ---', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('TRX: $trxNumber', style: const TextStyle(fontFamily: 'monospace')),
              const Text('Tanggal: 2026-05-27 10:00:00', style: TextStyle(fontFamily: 'monospace')),
              const Divider(color: Colors.black, thickness: 2),
              _buildLineItem('Kopi Senja (1x)', '25.000'),
              _buildLineItem('Roti Bakar (1x)', '15.000'),
              const Divider(color: Colors.black, thickness: 2),
              _buildLineItem('TOTAL', '40.000', isBold: true),
              const SizedBox(height: 16),
              const Text('Terima kasih atas kunjungan Anda!', style: TextStyle(fontFamily: 'monospace', fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineItem(String name, String price, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontFamily: 'monospace', fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(price, style: TextStyle(fontFamily: 'monospace', fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
