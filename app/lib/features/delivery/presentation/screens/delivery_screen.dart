import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/auth_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _drivers = [];
  List<dynamic> _pendingTransactions = [];
  List<dynamic> _deliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;
      final role = AuthService.userRole;

      if (role != 'driver') {
        final drvRes = await dio.get('/merchant/delivery/drivers');
        final txRes = await dio.get('/merchant/delivery/pending-transactions');
        _drivers = drvRes.data['data'] ?? [];
        _pendingTransactions = txRes.data['data'] ?? [];
      }

      final delivRes = await dio.get('/merchant/delivery');
      _deliveries = delivRes.data['data'] ?? [];
      
      if (mounted) setState(() {});
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _assignDriver(int txId, int driverId, String address) async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/delivery/assign', data: {
        'transaction_id': txId,
        'driver_id': driverId,
        'delivery_address': address,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kurir berhasil di-assign')));
        _fetchData();
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _updateStatus(int deliveryId, String status) async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/delivery/$deliveryId/status', data: {'status': status});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diupdate')));
        _fetchData();
      }
    } catch (e) {
      // ignore
    }
  }

  void _showAssignDialog(int txId) {
    int? selectedDriverId;
    String address = 'Jl. Contoh Alamat Pengiriman No 123'; // Dummy address for testing

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: Text('Assign Kurir', style: V2Typography.headingSm),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih Kurir:', style: V2Typography.bodyMd),
                  const SizedBox(height: 8),
                  ..._drivers.map((drv) => RadioListTile<int>(
                    title: Text(drv['name']),
                    value: drv['id'],
                    groupValue: selectedDriverId,
                    onChanged: (val) => setStateBuilder(() => selectedDriverId = val),
                  )),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                V2Button(
                  label: 'Assign',
                  size: V2ButtonSize.small,
                  onPressed: () {
                    if (selectedDriverId != null) {
                      Navigator.pop(ctx);
                      _assignDriver(txId, selectedDriverId!, address);
                    }
                  },
                )
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildDispatcherTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Pesanan Siap Antar', style: V2Typography.headingSm),
        const SizedBox(height: 8),
        if (_pendingTransactions.isEmpty)
          const Text('Tidak ada pesanan siap antar.')
        else
          ..._pendingTransactions.map((tx) => V2ClickableCard(
            onTap: () {},
            
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['transaction_number'], style: V2Typography.labelMd),
                      Text('Rp ${tx['total_amount']}', style: V2Typography.bodySm),
                    ],
                  ),
                  V2Button(
                    label: 'Assign Kurir',
                    size: V2ButtonSize.small,
                    onPressed: () => _showAssignDialog(tx['id']),
                  )
                ],
              ),
            ),
          )),
        
        const Divider(height: 32),
        Text('Status Armada', style: V2Typography.headingSm),
        const SizedBox(height: 8),
        ..._deliveries.map((d) {
          final isDelivered = d['status'] == 'delivered';
          return ListTile(
            leading: const Icon(Icons.delivery_dining, color: V2Colors.primaryBlue),
            title: Text('Tx: ${d['transaction']?['transaction_number']} - ${d['driver']?['name']}'),
            subtitle: Text('Status: ${d['status']}'),
            trailing: isDelivered ? const Icon(Icons.check_circle, color: V2Colors.successGreen) : const Icon(Icons.sync, color: V2Colors.warningAmber),
          );
        })
      ],
    );
  }

  Widget _buildDriverTab() {
    final activeDeliveries = _deliveries.where((d) => d['status'] != 'delivered').toList();
    final history = _deliveries.where((d) => d['status'] == 'delivered').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Pesanan Untuk Diantar', style: V2Typography.headingSm),
        const SizedBox(height: 8),
        if (activeDeliveries.isEmpty)
          const Text('Belum ada tugas pengantaran.')
        else
          ...activeDeliveries.map((d) => V2ClickableCard(
            onTap: () {},
            
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tujuan: ${d['delivery_address']}', style: V2Typography.labelMd),
                  const SizedBox(height: 4),
                  Text('Tx: ${d['transaction']?['transaction_number']}', style: V2Typography.bodySm),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (d['status'] == 'assigned')
                        V2Button(
                          label: 'Pick Up / OTW',
                          size: V2ButtonSize.small,
                          onPressed: () => _updateStatus(d['id'], 'on_the_way'),
                        )
                      else if (d['status'] == 'on_the_way')
                        V2Button(
                          label: 'Selesai Diantar',
                          size: V2ButtonSize.small,
                          variant: V2ButtonVariant.primary,
                          onPressed: () => _updateStatus(d['id'], 'delivered'),
                        )
                    ],
                  )
                ],
              ),
            ),
          )),
        const Divider(height: 32),
        Text('Riwayat Pengantaran', style: V2Typography.headingSm),
        ...history.map((d) => ListTile(
          leading: const Icon(Icons.check_circle, color: V2Colors.successGreen),
          title: Text(d['delivery_address']),
          subtitle: Text('Selesai pada: ${d['delivered_at']}'),
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = AuthService.userRole;
    final isDriver = role == 'driver';

    return Scaffold(
      appBar: AppBar(
        title: Text('Logistik & Kurir', style: V2Typography.headingMd),
        bottom: !isDriver ? TabBar(
          controller: _tabController,
          labelColor: V2Colors.primaryBlue,
          unselectedLabelColor: V2Colors.secondaryText,
          indicatorColor: V2Colors.primaryBlue,
          tabs: const [
            Tab(text: 'Dispatcher (Kasir)'),
            Tab(text: 'Tugas Kurir'),
          ],
        ) : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isDriver
              ? _buildDriverTab()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDispatcherTab(),
                    _buildDriverTab(), // Owner can see both views
                  ],
                ),
    );
  }
}
