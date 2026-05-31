import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class HqDashboardScreen extends StatefulWidget {
  const HqDashboardScreen({super.key});

  @override
  State<HqDashboardScreen> createState() => _HqDashboardScreenState();
}

class _HqDashboardScreenState extends State<HqDashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _outlets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;
      final dbRes = await dio.get('/merchant/hq/dashboard');
      final outRes = await dio.get('/merchant/hq/outlets');
      
      if (mounted) {
        setState(() {
          _dashboardData = dbRes.data['data'];
          _outlets = outRes.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTransferDialog() {
    int? fromOutlet;
    int? toOutlet;
    // Di real app, fetch list of ingredients. Kita mock ID 1 untuk demo.
    int ingredientId = 1; 
    final qtyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) {
          return AlertDialog(
            title: Text('Mutasi Stok Antar Cabang', style: V2Typography.headingSm),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: fromOutlet,
                  decoration: const InputDecoration(labelText: 'Dari Outlet'),
                  items: _outlets.map((o) => DropdownMenuItem<int>(
                    value: o['id'],
                    child: Text(o['name']),
                  )).toList(),
                  onChanged: (val) => setStateBuilder(() => fromOutlet = val),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: toOutlet,
                  decoration: const InputDecoration(labelText: 'Ke Outlet'),
                  items: _outlets.map((o) => DropdownMenuItem<int>(
                    value: o['id'],
                    child: Text(o['name']),
                  )).toList(),
                  onChanged: (val) => setStateBuilder(() => toOutlet = val),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah (Item 1)'),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              V2Button(
                label: 'Transfer Stok',
                size: V2ButtonSize.small,
                onPressed: () async {
                  if (fromOutlet != null && toOutlet != null && qtyCtrl.text.isNotEmpty) {
                    try {
                      final dio = DioClient().dio;
                      await dio.post('/merchant/hq/stock-transfer', data: {
                        'from_outlet_id': fromOutlet,
                        'to_outlet_id': toOutlet,
                        'ingredient_id': ingredientId,
                        'quantity': num.parse(qtyCtrl.text),
                      });
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok berhasil ditransfer!')));
                      }
                    } catch (e) {
                       // ignore
                    }
                  }
                },
              )
            ],
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HQ / Kantor Pusat', style: V2Typography.headingMd),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardData == null
              ? const Center(child: Text('Gagal memuat data HQ'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF141E30), Color(0xFF243B55)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.public, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text('Global Consolidated Revenue', style: V2Typography.labelMd.copyWith(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rp ${_dashboardData!['total_omzet']}',
                            style: V2Typography.headingXl.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Transaksi', style: V2Typography.bodySm.copyWith(color: Colors.white70)),
                                    Text('${_dashboardData!['total_transaksi']}', style: V2Typography.labelMd.copyWith(color: V2Colors.accentTeal)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Outlet Aktif', style: V2Typography.bodySm.copyWith(color: Colors.white70)),
                                    Text('${_dashboardData!['outlets_count']}', style: V2Typography.labelMd.copyWith(color: V2Colors.warningAmber)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daftar Outlet (Cabang)', style: V2Typography.headingSm),
                        V2Button(
                          label: 'Mutasi Stok',
                          size: V2ButtonSize.small,
                          onPressed: _showTransferDialog,
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._outlets.map((o) => V2ClickableCard(
                      onTap: () {},
                      
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: V2Colors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.storefront, color: V2Colors.primaryBlue),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(o['name'], style: V2Typography.labelMd),
                                  Text(o['address'] ?? 'Alamat belum diatur', style: V2Typography.bodySm),
                                ],
                              ),
                            ),
                            const Icon(Icons.login, color: V2Colors.mutedText),
                          ],
                        ),
                      ),
                    ))
                  ],
                ),
    );
  }
}
