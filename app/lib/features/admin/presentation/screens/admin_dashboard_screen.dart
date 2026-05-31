import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/auth_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _error = '';
  
  Map<String, dynamic> _kpi = {};
  List<dynamic> _merchants = [];
  List<dynamic> _topups = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;

      // Fetch Dashboard Data
      final responseDash = await dio.get('/admin/dashboard');
      if (responseDash.statusCode == 200 && responseDash.data['success'] == true) {
        _kpi = responseDash.data['data']['kpi'];
        _merchants = responseDash.data['data']['merchants'];
      }

      // Fetch Topups Data
      final responseTopups = await dio.get('/admin/topups');
      if (responseTopups.statusCode == 200 && responseTopups.data['success'] == true) {
        _topups = responseTopups.data['data'];
      }

      setState(() {
        _isLoading = false;
        _error = '';
      });
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.response?.data['message'] ?? 'Akses Ditolak. Anda bukan Super Admin.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Terjadi kesalahan sistem.';
      });
    }
  }

  Future<void> _approveTopup(int id) async {
    try {
      final dio = DioClient().dio;

      final response = await dio.post('/admin/topups/$id/approve');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const           SnackBar(content: Text('Top-Up Berhasil Disetujui!'), backgroundColor: V2Colors.successGreen),
        );
        _fetchAdminData(); // Refresh data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyetujui Top-Up.'), backgroundColor: V2Colors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin AntiRibet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAdminData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.logout();
              context.go('/login');
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
            indicatorColor: V2Colors.primaryBlue,
          tabs: const [
            Tab(text: 'Platform Overview', icon: Icon(Icons.insights)),
            Tab(text: 'Top-Up Requests', icon: Icon(Icons.account_balance_wallet)),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error.isNotEmpty
            ? Center(child: Text(_error, style: TextStyle(color: V2Colors.errorRed, fontWeight: FontWeight.bold)))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildTopupTab(),
                ],
              ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform KPI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _kpiCard('Total Merchant', '${_kpi['total_merchants'] ?? 0}', Icons.storefront, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _kpiCard('Total Omzet (Fee)', 'Rp ${_kpi['total_platform_revenue'] ?? 0}', Icons.monetization_on, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _kpiCard('Total Transaksi', '${_kpi['total_successful_transactions'] ?? 0}', Icons.receipt_long, Colors.orange)),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Daftar Merchant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _merchants.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final m = _merchants[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: V2Colors.primaryBlue.withOpacity(0.1),
                    child: Icon(Icons.info, color: V2Colors.primaryBlue),
                  ),
                  title: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Kategori: ${m['category']} | Join: ${m['joined_at']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Saldo Wallet', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('Rp ${m['balance']}', style: TextStyle(color: V2Colors.primaryBlue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopupTab() {
    final pendingTopups = _topups.where((t) => t['status'] == 'pending').toList();
    
    if (pendingTopups.isEmpty) {
      return const Center(child: Text('Tidak ada permintaan Top-Up saat ini.', style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: pendingTopups.length,
      itemBuilder: (context, index) {
        final t = pendingTopups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.orange, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top-Up Merchant ID: ${t['business_id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Rp ${t['amount']}', style: TextStyle(color: V2Colors.primaryBlue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Metode: ${t['payment_method']} | Tanggal: ${t['created_at'].toString().substring(0, 10)}'),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _approveTopup(t['id']),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(backgroundColor: V2Colors.successGreen, foregroundColor: Colors.white),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
