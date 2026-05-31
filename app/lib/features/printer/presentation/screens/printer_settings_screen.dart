import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/services/printer_service.dart';
import 'package:antiribet/app/theme.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final PrinterService _printerService = PrinterService();
  bool _isScanning = false;
  List<PrinterDevice> _devices = [];

  void _scan() async {
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    final devices = await _printerService.scanDevices();
    
    setState(() {
      _devices = devices;
      _isScanning = false;
    });
  }

  void _connect(PrinterDevice device) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await _printerService.connect(device);
    
    if (mounted) {
      Navigator.pop(context); // close dialog
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terhubung ke ${device.name}')));
    }
  }

  void _disconnect() {
    _printerService.disconnect();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Printer Thermal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _printerService.isConnected ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _printerService.isConnected ? AppTheme.successColor : AppTheme.errorColor),
              ),
              child: Row(
                children: [
                  Icon(
                    _printerService.isConnected ? Icons.print : Icons.print_disabled,
                    color: _printerService.isConnected ? AppTheme.successColor : AppTheme.errorColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _printerService.isConnected ? 'Terhubung' : 'Tidak Terhubung',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        if (_printerService.isConnected)
                          Text(_printerService.connectedDevice!.name),
                      ],
                    ),
                  ),
                  if (_printerService.isConnected)
                    TextButton(
                      onPressed: _disconnect,
                      child: const Text('Putuskan', style: TextStyle(color: AppTheme.errorColor)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Perangkat Bluetooth Tersedia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scan,
                  icon: _isScanning ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
                  label: Text(_isScanning ? 'Mencari...' : 'Cari Printer'),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _devices.isEmpty
                  ? Center(child: Text(_isScanning ? 'Sedang mencari...' : 'Tekan "Cari Printer" untuk memindai.'))
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.bluetooth),
                            title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(device.address),
                            trailing: ElevatedButton(
                              onPressed: () => _connect(device),
                              child: const Text('Hubungkan'),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
