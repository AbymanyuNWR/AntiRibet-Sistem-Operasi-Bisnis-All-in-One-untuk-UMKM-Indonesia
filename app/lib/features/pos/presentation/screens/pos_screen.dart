import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';
import '../../../../core/components/v2_status_badge.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/services/sync_service.dart';
import '../providers/pos_cart_bloc.dart';

import 'dart:async';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<dynamic> _pendingOrders = [];
  int _offlineQueueCount = 0;
  Timer? _pollingTimer;
  Map<String, dynamic>? _currentShift;
  bool _isShiftLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentShift();
    _startPollingPendingOrders();
    _fetchPendingCount();
  }

  Future<void> _checkCurrentShift() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/shift/current');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _currentShift = response.data['data'];
            _isShiftLoading = false;
          });
          
          if (_currentShift == null) {
            _showOpenShiftDialog();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isShiftLoading = false);
      }
    }
  }

  void _showOpenShiftDialog() {
    final cashController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            title: Text('Buka Kasir (Shift)', style: V2Typography.headingSm),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.point_of_sale, size: 64, color: V2Colors.primaryBlue),
                const SizedBox(height: 16),
                Text('Masukkan uang modal awal (Cash in Drawer) sebelum menerima pesanan.', style: V2Typography.bodyMd),
                const SizedBox(height: 16),
                TextField(
                  controller: cashController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Modal Awal Kasir (Rp)'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => context.go('/dashboard'), child: const Text('Batal (Kembali)')),
              V2Button(
                label: 'Buka Shift',
                size: V2ButtonSize.small,
                isLoading: isSubmitting,
                onPressed: () async {
                  if (cashController.text.isEmpty) return;
                  setStateModal(() => isSubmitting = true);
                  try {
                    final dio = DioClient().dio;
                    await dio.post('/merchant/shift/open', data: {
                      'starting_cash': double.parse(cashController.text)
                    });
                    if (mounted) {
                      Navigator.pop(ctx);
                      _checkCurrentShift();
                    }
                  } catch (e) {
                    setStateModal(() => isSubmitting = false);
                  }
                },
              )
            ],
          );
        }
      )
    );
  }

  void _showCloseShiftDialog() {
    final cashController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            title: Text('Tutup Kasir (Shift)', style: V2Typography.headingSm),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_clock, size: 64, color: V2Colors.warningAmber),
                const SizedBox(height: 16),
                Text('Hitung seluruh uang tunai yang ada di laci kasir saat ini.', style: V2Typography.bodyMd),
                const SizedBox(height: 16),
                TextField(
                  controller: cashController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Uang Tunai di Laci (Rp)'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              V2Button(
                label: 'Selesai & Tutup',
                size: V2ButtonSize.small,
                isLoading: isSubmitting,
                onPressed: () async {
                  if (cashController.text.isEmpty) return;
                  setStateModal(() => isSubmitting = true);
                  try {
                    final dio = DioClient().dio;
                    final res = await dio.post('/merchant/shift/close', data: {
                      'actual_cash': double.parse(cashController.text)
                    });
                    if (mounted) {
                      Navigator.pop(ctx);
                      final data = res.data['data'];
                      final diff = num.tryParse(data['difference'].toString()) ?? 0;
                      
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Shift Ditutup'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Expected Cash: Rp ${data['expected_cash']}'),
                              Text('Actual Cash: Rp ${data['actual_cash']}'),
                              const SizedBox(height: 16),
                              Text(
                                diff == 0 ? 'Balance (Sesuai)' : (diff > 0 ? 'Overage (Kelebihan) Rp $diff' : 'Shortage (Kurang) Rp $diff'),
                                style: TextStyle(
                                  color: diff == 0 ? V2Colors.successGreen : V2Colors.errorRed, 
                                  fontWeight: FontWeight.bold
                                )
                              )
                            ],
                          ),
                          actions: [
                            V2Button(label: 'Tutup Aplikasi', onPressed: () => context.go('/dashboard'))
                          ]
                        )
                      );
                    }
                  } catch (e) {
                    setStateModal(() => isSubmitting = false);
                  }
                },
              )
            ],
          );
        }
      )
    );
  }

  Future<void> _fetchPendingCount() async {
    final count = await SyncService().getPendingCount();
    if (mounted) {
      setState(() {
        _offlineQueueCount = count;
      });
    }
  }

  void _startPollingPendingOrders() {
    _fetchPendingOrders();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchPendingOrders();
      _fetchPendingCount();
    });
  }

  Future<void> _fetchPendingOrders() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/pos/transactions/pending');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _pendingOrders = response.data['data'];
          });
        }
      }
    } catch (e) {
      // Ignore polling errors
    }
  }

  Future<void> _acceptOrder(int id) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      final dio = DioClient().dio;
      final response = await dio.post('/merchant/pos/transactions/$id/accept');
      
      if (mounted) Navigator.pop(context); // Close loading

      if (response.statusCode == 200 && response.data['success'] == true) {
        _fetchPendingOrders(); // Refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message']), backgroundColor: V2Colors.successGreen),
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.response?.data['message'] ?? 'Gagal menerima pesanan'), backgroundColor: V2Colors.errorRed),
        );
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Kasir (POS)', style: V2Typography.headingMd),
          actions: [
            InkWell(
              onTap: () async {
                if (_offlineQueueCount > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyinkronkan data offline...')));
                  await SyncService().syncPendingTransactions();
                  _fetchPendingCount();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      _offlineQueueCount > 0 ? Icons.cloud_off : Icons.cloud_done,
                      color: _offlineQueueCount > 0 ? V2Colors.warningAmber : V2Colors.successGreen,
                    ),
                    if (_offlineQueueCount > 0) ...[
                      const SizedBox(width: 8),
                      Text('$_offlineQueueCount Antrean', style: V2Typography.labelMd.copyWith(color: V2Colors.warningAmber)),
                    ]
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.lock_clock),
              tooltip: 'Tutup Shift',
              onPressed: _currentShift == null ? null : _showCloseShiftDialog,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: _isShiftLoading || _currentShift == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            if (_pendingOrders.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: V2Colors.warningAmber.withOpacity(0.1),
                child: Column(
                  children: _pendingOrders.map((order) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active, color: V2Colors.warningAmber),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pesanan QR Baru: ${order['transaction_number']}', style: V2Typography.labelMd),
                                  Text('Meja: ${order['table_number'] ?? '-'} | Rp ${order['total_amount']}', style: V2Typography.bodySm),
                                ],
                              ),
                            ],
                          ),
                          V2Button(
                            label: 'Terima & Proses',
                            size: V2ButtonSize.small,
                            onPressed: () => _acceptOrder(order['id']),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _ProductGrid()),
                        const VerticalDivider(width: 1, color: V2Colors.border),
                        Expanded(flex: 2, child: _CartPanel()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Expanded(child: _ProductGrid()),
                      _MobileCartSummary(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGrid extends StatefulWidget {
  @override
  State<_ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<_ProductGrid> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/catalog');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response.data['data']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat katalog menu.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: V2Colors.primaryBlue));
    }
    
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: V2Colors.errorRed),
            const SizedBox(height: 16),
            Text(_error, style: V2Typography.bodyLg.copyWith(color: V2Colors.errorRed)),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: V2Colors.mutedText),
            const SizedBox(height: 16),
            Text('Katalog kosong', style: V2Typography.headingSm),
            const SizedBox(height: 8),
            Text('Silakan tambahkan produk di menu Katalog', style: V2Typography.bodyMd),
            const SizedBox(height: 24),
            V2Button(
              label: 'Buka Katalog',
              onPressed: () => context.go('/dashboard/catalog'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        final num price = product['price'];
        return V2ClickableCard(
          padding: const EdgeInsets.all(12),
          onTap: () {
            context.read<PosCartBloc>().add(AddProductToCart(product));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product['name']} ditambahkan'),
                duration: const Duration(milliseconds: 500),
                backgroundColor: V2Colors.primaryText,
              )
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: V2Colors.pageBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: V2Colors.border),
                  ),
                  child: const Center(
                    child: Icon(Icons.fastfood_outlined, size: 40, color: V2Colors.mutedText),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product['name'], 
                style: V2Typography.labelLg, 
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Rp $price',
                style: V2Typography.numericMd.copyWith(color: V2Colors.primaryBlue),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartPanel extends StatefulWidget {
  @override
  State<_CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<_CartPanel> {
  bool _isProcessing = false;

  void _showSuccessDialog(BuildContext context, String transactionNumber, num totalAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: V2Colors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 64, color: V2Colors.successGreen),
            ),
            const SizedBox(height: 24),
            Text('Transaksi Berhasil', style: V2Typography.headingMd),
            const SizedBox(height: 8),
            Text(transactionNumber, style: V2Typography.bodyMd.copyWith(color: V2Colors.secondaryText)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: V2Colors.pageBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: V2Colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: V2Typography.labelLg),
                  Text('Rp $totalAmount', style: V2Typography.numericLg.copyWith(color: V2Colors.primaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            V2Button(
              label: 'Cetak Struk',
              isFullWidth: true,
              size: V2ButtonSize.large,
              icon: Icons.print,
              onPressed: () {
                final printer = PrinterService();
                if (printer.isConnected) {
                  printer.printReceipt({
                    'transaction_number': transactionNumber,
                    'table_number': 'Kasir',
                    'status': 'LUNAS',
                    'total_amount': totalAmount,
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            V2Button(
              label: 'Kirim Struk via WA',
              isFullWidth: true,
              variant: V2ButtonVariant.secondary,
              icon: Icons.chat,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            V2Button(
              label: 'Transaksi Baru',
              isFullWidth: true,
              variant: V2ButtonVariant.ghost,
              onPressed: () {
                context.read<PosCartBloc>().add(ClearCart());
                Navigator.of(ctx).pop(); // Close dialog
              },
            ),
          ],
        ),
      )
    );
  }

  Future<void> _processCheckout(BuildContext context, PosCartState state, String? customerPhone, int redeemPoints) async {
    setState(() => _isProcessing = true);

    try {
      final itemsData = state.items.map((item) => {
        'catalog_item_id': item['id'],
        'quantity': item['qty'],
        'price': item['price'],
      }).toList();

      final idempotencyKey = const Uuid().v4();
      final payload = {
        'items': itemsData,
        'payment_method': 'cash',
        'amount_paid': state.total,
        'idempotency_key': idempotencyKey,
        'customer_phone': customerPhone,
        'redeem_points': redeemPoints,
      };

      bool isOffline = false;
      final txNum = 'INV-${DateTime.now().millisecondsSinceEpoch}'; // Temporary ID for offline

      try {
        final dio = DioClient().dio;
        final response = await dio.post('/merchant/pos/transactions', data: payload);
        if (response.statusCode != 200 || response.data['success'] != true) {
          throw Exception('API Error');
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          // Offline, enqueue
          isOffline = true;
          await SyncService().enqueueTransaction(payload);
          // _fetchPendingCount(); // Update badge removed to fix scope error
        } else {
          rethrow;
        }
      }

      if (mounted) {
        // Auto-print receipt if printer is connected
        final printer = PrinterService();
        if (printer.isConnected) {
          printer.printReceipt({
            'invoice_number': txNum,
            'cashier_name': 'Admin Kasir',
            'total_amount': state.total,
            'items': itemsData, 
            'is_offline': isOffline,
          });
        }

        if (isOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda Sedang Offline! Transaksi disimpan dan akan disinkronisasi nanti.'), backgroundColor: V2Colors.warningAmber),
          );
        }
        
        _showSuccessDialog(context, txNum, state.total);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout Gagal: $e'), backgroundColor: V2Colors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showCheckoutDialog(BuildContext context, PosCartState state) {
    final phoneController = TextEditingController();
    final pointsController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Proses Pembayaran', style: V2Typography.headingSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No HP Pelanggan (Opsional - CRM)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tukar Poin (1 Poin = Rp100)'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Belanja:', style: V2Typography.labelLg),
                Text('Rp ${state.total}', style: V2Typography.numericLg.copyWith(color: V2Colors.primaryBlue)),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          V2Button(
            label: 'Bayar Sekarang',
            size: V2ButtonSize.small,
            onPressed: () {
              Navigator.pop(ctx);
              _processCheckout(
                context, 
                state, 
                phoneController.text.isEmpty ? null : phoneController.text,
                int.tryParse(pointsController.text) ?? 0,
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCartBloc, PosCartState>(
      builder: (context, state) {
        return Container(
          color: V2Colors.cardBackground,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: V2Colors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Keranjang (${state.items.length})', style: V2Typography.headingSm),
                    if (state.items.isNotEmpty)
                      InkWell(
                        onTap: () => context.read<PosCartBloc>().add(ClearCart()),
                        child: Text('Kosongkan', style: V2Typography.labelMd.copyWith(color: V2Colors.errorRed)),
                      )
                  ],
                ),
              ),
              Expanded(
                child: state.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_basket_outlined, size: 64, color: V2Colors.border),
                          const SizedBox(height: 16),
                          Text('Belum ada pesanan', style: V2Typography.bodyMd.copyWith(color: V2Colors.mutedText)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const Divider(color: V2Colors.divider, height: 1),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: V2Typography.labelLg),
                                    const SizedBox(height: 4),
                                    Text('Rp ${item['price']}', style: V2Typography.numericMd.copyWith(color: V2Colors.primaryBlue)),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: V2Colors.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () => context.read<PosCartBloc>().add(RemoveProductFromCart(item['id'])),
                                    ),
                                    Text('${item['qty']}', style: V2Typography.numericMd),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () => context.read<PosCartBloc>().add(AddProductToCart(item)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: V2Colors.cardBackground,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Tagihan', style: V2Typography.labelLg),
                        Text('Rp ${state.total}', style: V2Typography.numericXl.copyWith(color: V2Colors.primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    V2Button(
                      label: 'Proses Pembayaran',
                      size: V2ButtonSize.large,
                      isFullWidth: true,
                      isLoading: _isProcessing,
                      onPressed: (state.items.isEmpty) ? null : () => _showCheckoutDialog(context, state),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _MobileCartSummary extends StatelessWidget {
  void _showMobileCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: V2Colors.cardBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: V2Colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  BlocBuilder<PosCartBloc, PosCartState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Keranjang (${state.items.length})', style: V2Typography.headingSm),
                                if (state.items.isNotEmpty)
                                  InkWell(
                                    onTap: () {
                                      context.read<PosCartBloc>().add(ClearCart());
                                      Navigator.pop(sheetContext);
                                    },
                                    child: Text('Kosongkan', style: V2Typography.labelMd.copyWith(color: V2Colors.errorRed)),
                                  )
                              ],
                            ),
                          ),
                          const Divider(color: V2Colors.border, height: 1),
                          Expanded(
                            child: state.items.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.shopping_basket_outlined, size: 48, color: V2Colors.border),
                                        const SizedBox(height: 12),
                                        Text('Keranjang kosong', style: V2Typography.bodyMd.copyWith(color: V2Colors.mutedText)),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    controller: scrollController,
                                    itemCount: state.items.length,
                                    separatorBuilder: (_, __) => const Divider(color: V2Colors.divider, height: 1),
                                    itemBuilder: (context, index) {
                                      final item = state.items[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item['name'], style: V2Typography.labelLg),
                                                  const SizedBox(height: 4),
                                                  Text('Rp ${item['price']}', style: V2Typography.numericMd.copyWith(color: V2Colors.primaryBlue)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: V2Colors.border),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.remove, size: 16),
                                                    onPressed: () => context.read<PosCartBloc>().add(RemoveProductFromCart(item['id'])),
                                                  ),
                                                  Text('${item['qty']}', style: V2Typography.numericMd),
                                                  IconButton(
                                                    icon: const Icon(Icons.add, size: 16),
                                                    onPressed: () => context.read<PosCartBloc>().add(AddProductToCart(item)),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Tagihan', style: V2Typography.labelLg),
                                    Text('Rp ${state.total}', style: V2Typography.numericXl.copyWith(color: V2Colors.primaryBlue)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                V2Button(
                                  label: 'Proses Pembayaran',
                                  size: V2ButtonSize.large,
                                  isFullWidth: true,
                                  onPressed: (state.items.isEmpty)
                                      ? null
                                      : () {
                                          Navigator.pop(sheetContext);
                                          // Trigger checkout from parent
                                        },
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCartBloc, PosCartState>(
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: V2Colors.primaryBlue,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${state.items.length} Item Tersimpan', style: V2Typography.bodySm.copyWith(color: Colors.white70)),
                  Text('Rp ${state.total}', style: V2Typography.numericLg.copyWith(color: Colors.white)),
                ],
              ),
              V2Button(
                label: 'Lihat Keranjang',
                variant: V2ButtonVariant.secondary,
                onPressed: () => _showMobileCartSheet(context),
              )
            ],
          ),
        );
      },
    );
  }
}
