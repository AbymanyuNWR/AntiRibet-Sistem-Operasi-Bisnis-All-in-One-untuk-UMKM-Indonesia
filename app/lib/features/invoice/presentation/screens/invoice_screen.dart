import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';
import '../../../../core/components/v2_status_badge.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  bool _isLoading = true;
  List<dynamic> _invoices = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/invoices');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _invoices = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat invoice.';
      });
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final dio = DioClient().dio;
      final response = await dio.post('/merchant/invoices/$id/status', data: {'status': status});
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invoice berhasil dilunasi. Saldo dipotong Rp500.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
            backgroundColor: V2Colors.successGreen,
          ));
          _fetchInvoices();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data['message'] ?? 'Gagal update status.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: V2Colors.errorRed,
        ));
      }
    }
  }

  void _showCreateInvoiceDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: V2Colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Buat Invoice Baru', style: V2Typography.headingMd),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(color: V2Colors.divider, height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Klien / Perusahaan'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Tagihan',
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 32),
                  V2Button(
                    label: 'Terbitkan Invoice',
                    isFullWidth: true,
                    size: V2ButtonSize.large,
                    isLoading: isSubmitting,
                    onPressed: () async {
                      if (nameController.text.isEmpty || amountController.text.isEmpty) return;
                      
                      setModalState(() => isSubmitting = true);
                      try {
                        final dio = DioClient().dio;
                        await dio.post('/merchant/invoices', data: {
                          'client_name': nameController.text,
                          'total_amount': int.parse(amountController.text),
                          'items': [
                            {'description': 'Tagihan Layanan', 'qty': 1, 'price': int.parse(amountController.text)}
                          ],
                        });
                        if (mounted) {
                          Navigator.pop(context);
                          _fetchInvoices();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Invoice dibuat!', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
                            backgroundColor: V2Colors.successGreen,
                          ));
                        }
                      } catch (e) {
                        setModalState(() => isSubmitting = false);
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showInvoiceDetails(dynamic inv) {
    // Detail dialog flow
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Invoice ${inv['invoice_number']}', style: V2Typography.headingSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Klien: ${inv['client_name']}', style: V2Typography.bodyLg),
            const SizedBox(height: 8),
            Text('Total: Rp ${inv['total_amount']}', style: V2Typography.numericLg.copyWith(color: V2Colors.primaryBlue)),
          ],
        ),
        actions: [
          V2Button(
            label: 'Tutup',
            variant: V2ButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx),
          ),
          if (inv['status'] != 'paid')
            V2Button(
              label: 'Tandai Lunas',
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(inv['id'], 'paid');
              },
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Invoice', style: V2Typography.headingMd),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchInvoices),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: V2Colors.primaryBlue))
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: V2Typography.bodyMd.copyWith(color: V2Colors.errorRed)))
              : _invoices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 64, color: V2Colors.mutedText),
                          const SizedBox(height: 16),
                          Text('Belum ada Invoice', style: V2Typography.headingSm),
                          const SizedBox(height: 8),
                          Text('Buat tagihan pertama Anda sekarang.', style: V2Typography.bodyMd),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _invoices.length,
                      itemBuilder: (context, index) {
                        final inv = _invoices[index];
                        final isPaid = inv['status'] == 'paid';
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: V2ClickableCard(
                            onTap: () => _showInvoiceDetails(inv),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      inv['invoice_number'], 
                                      style: V2Typography.labelLg.copyWith(color: V2Colors.primaryBlue)
                                    ),
                                    V2StatusBadge(
                                      label: isPaid ? 'Lunas' : 'Belum Dibayar',
                                      status: isPaid ? V2BadgeStatus.success : V2BadgeStatus.warning,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(inv['client_name'], style: V2Typography.headingSm),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Tagihan', style: V2Typography.bodySm.copyWith(color: V2Colors.secondaryText)),
                                    Text('Rp ${inv['total_amount']}', style: V2Typography.numericMd),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateInvoiceDialog,
        backgroundColor: V2Colors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Buat Invoice', style: V2Typography.labelLg.copyWith(color: Colors.white)),
      ),
    );
  }
}
