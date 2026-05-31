import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class SupplyChainScreen extends StatefulWidget {
  const SupplyChainScreen({super.key});

  @override
  State<SupplyChainScreen> createState() => _SupplyChainScreenState();
}

class _SupplyChainScreenState extends State<SupplyChainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _pos = [];
  List<dynamic> _suppliers = [];
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
      final poRes = await dio.get('/merchant/purchase-orders');
      final supRes = await dio.get('/merchant/suppliers');
      
      if (mounted) {
        setState(() {
          _pos = poRes.data['data'] ?? [];
          _suppliers = supRes.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markReceived(int id) async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/purchase-orders/$id/receive');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Barang Diterima! Stok Gudang otomatis bertambah.'),
          backgroundColor: V2Colors.successGreen,
        ));
        _fetchData();
      }
    } catch (e) {
      // ignore
    }
  }

  Widget _buildPoList() {
    if (_pos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: V2Colors.mutedText),
            const SizedBox(height: 16),
            Text('Belum ada Purchase Order', style: V2Typography.bodyMd),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pos.length,
      itemBuilder: (context, index) {
        final po = _pos[index];
        final isReceived = po['status'] == 'received';
        return V2ClickableCard(
          onTap: () {},
          
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(po['po_number'], style: V2Typography.labelLg),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isReceived ? V2Colors.successGreen.withOpacity(0.1) : V2Colors.warningAmber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isReceived ? 'Received' : 'Pending',
                        style: V2Typography.bodySm.copyWith(
                          color: isReceived ? V2Colors.successGreen : V2Colors.warningAmber,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text('Pemasok: ${po['supplier']?['name'] ?? '-'}', style: V2Typography.bodyMd),
                Text('Total: Rp ${po['total_amount']}', style: V2Typography.labelMd.copyWith(color: V2Colors.primaryBlue)),
                const SizedBox(height: 16),
                if (!isReceived)
                  V2Button(
                    label: 'Tandai Barang Diterima',
                    isFullWidth: true,
                    size: V2ButtonSize.small,
                    onPressed: () => _markReceived(po['id']),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupplierList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suppliers.length,
      itemBuilder: (context, index) {
        final sup = _suppliers[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.local_shipping)),
          title: Text(sup['name'], style: V2Typography.labelMd),
          subtitle: Text(sup['contact'] ?? 'No Contact'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supply Chain (PO)', style: V2Typography.headingMd),
        bottom: TabBar(
          controller: _tabController,
          labelColor: V2Colors.primaryBlue,
          unselectedLabelColor: V2Colors.secondaryText,
          indicatorColor: V2Colors.primaryBlue,
          tabs: const [
            Tab(text: 'Purchase Orders'),
            Tab(text: 'Daftar Pemasok'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPoList(),
                _buildSupplierList(),
              ],
            ),
    );
  }
}
