import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class KdsScreen extends StatefulWidget {
  const KdsScreen({super.key});

  @override
  State<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends State<KdsScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // In a real implementation, you would listen to Pusher/Echo channel here
    // e.g. Echo.channel('merchant.${businessId}.kitchen').listen('KitchenStatusUpdated', ...);
  }

  Future<void> _fetchOrders() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/kitchen/orders');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _orders = response.data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat antrean dapur';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/kitchen/orders/$id/status', data: {
        'kitchen_status': newStatus
      });
      _fetchOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal update status'), backgroundColor: V2Colors.errorRed)
        );
      }
    }
  }

  Widget _buildKanbanColumn(String title, String statusFilter, Color headerColor) {
    final filteredOrders = _orders.where((o) => o['kitchen_status'] == statusFilter).toList();
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: V2Colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: V2Colors.divider),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: V2Typography.headingSm.copyWith(color: headerColor)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredOrders.length}',
                      style: V2Typography.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  List<dynamic> items = [];
                  if (order['items'] is String) {
                    items = jsonDecode(order['items']);
                  } else {
                    items = order['items'] ?? [];
                  }

                  return V2ClickableCard(
                    onTap: () {},
                    
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order['transaction_number'], style: V2Typography.labelMd),
                            if (order['table_number'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: V2Colors.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Meja ${order['table_number']}', style: V2Typography.bodySm.copyWith(color: V2Colors.primaryBlue, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const Divider(height: 24, color: V2Colors.divider),
                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item['qty'] ?? item['quantity']}x', style: V2Typography.labelMd),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item['name'], style: V2Typography.bodyMd)),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),
                        if (statusFilter == 'pending')
                          V2Button(
                            label: 'Mulai Masak',
                            isFullWidth: true,
                            size: V2ButtonSize.small,
                            onPressed: () => _updateStatus(order['id'], 'cooking'),
                          )
                        else if (statusFilter == 'cooking')
                          V2Button(
                            label: 'Selesai (Siap Saji)',
                            isFullWidth: true,
                            size: V2ButtonSize.small,
                            
                            onPressed: () => _updateStatus(order['id'], 'ready'),
                          )
                        else if (statusFilter == 'ready')
                          V2Button(
                            label: 'Telah Disajikan',
                            isFullWidth: true,
                            size: V2ButtonSize.small,
                            variant: V2ButtonVariant.secondary,
                            onPressed: () => _updateStatus(order['id'], 'served'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Kitchen Display System (KDS)', style: V2Typography.headingMd),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: V2Colors.primaryBlue))
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: V2Typography.bodyMd.copyWith(color: V2Colors.errorRed)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildKanbanColumn('Pesanan Baru', 'pending', V2Colors.errorRed),
                      _buildKanbanColumn('Sedang Dimasak', 'cooking', V2Colors.warningAmber),
                      _buildKanbanColumn('Siap Saji', 'ready', V2Colors.successGreen),
                    ],
                  ),
                ),
    );
  }
}
