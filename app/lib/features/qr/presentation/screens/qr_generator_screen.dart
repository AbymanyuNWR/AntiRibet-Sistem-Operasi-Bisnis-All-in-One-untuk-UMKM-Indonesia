import 'package:flutter/material.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';

class QrGeneratorScreen extends StatefulWidget {
  final String businessSlug;

  const QrGeneratorScreen({super.key, required this.businessSlug});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final _tableController = TextEditingController();
  String _qrUrl = '';
  String _targetUrl = '';

  void _generateQr() {
    if (_tableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Silakan isi nomor meja.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: V2Colors.errorRed,
      ));
      return;
    }

    final table = _tableController.text.trim();
    _targetUrl = 'https://antiribet.id/b/${widget.businessSlug}?table=$table';
    _qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=$_targetUrl';
    
    setState(() {});
  }

  void _resetQr() {
    setState(() {
      _qrUrl = '';
      _targetUrl = '';
      _tableController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cetak QR Code', style: V2Typography.headingMd),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_qrUrl.isEmpty) ...[
              const Icon(Icons.qr_code_scanner, size: 64, color: V2Colors.primaryBlue),
              const SizedBox(height: 24),
              Text(
                'Buat QR Code untuk Meja',
                style: V2Typography.headingLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pelanggan dapat memindai QR ini untuk memesan langsung tanpa harus memanggil pelayan.',
                style: V2Typography.bodyLg.copyWith(color: V2Colors.secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: V2Colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: V2Colors.border),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _tableController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor atau Nama Meja',
                        hintText: 'Contoh: 1, 2, VIP-A',
                      ),
                    ),
                    const SizedBox(height: 24),
                    V2Button(
                      label: 'Generate QR Code',
                      isFullWidth: true,
                      size: V2ButtonSize.large,
                      onPressed: _generateQr,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text('QR Code Berhasil Dibuat!', style: V2Typography.headingMd.copyWith(color: V2Colors.successGreen)),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: V2Colors.cardBackground,
                  border: Border.all(color: V2Colors.border),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 10))
                  ]
                ),
                child: Column(
                  children: [
                    Image.network(
                      _qrUrl,
                      width: 200,
                      height: 200,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 200, height: 200,
                          child: Center(child: CircularProgressIndicator(color: V2Colors.primaryBlue)),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Meja ${_tableController.text}',
                      style: V2Typography.headingLg.copyWith(color: V2Colors.primaryText),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  V2Button(
                    label: 'Buat Baru',
                    variant: V2ButtonVariant.secondary,
                    onPressed: _resetQr,
                  ),
                  const SizedBox(width: 16),
                  V2Button(
                    label: 'Simpan / Cetak',
                    icon: Icons.print,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Simpan/Print belum diimplementasikan di Sandbox.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
                        backgroundColor: V2Colors.infoBlue,
                      ));
                    },
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
