import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/auth_service.dart';

class SuperadminDashboardScreen extends StatefulWidget {
  const SuperadminDashboardScreen({super.key});

  @override
  State<SuperadminDashboardScreen> createState() => _SuperadminDashboardScreenState();
}

class _SuperadminDashboardScreenState extends State<SuperadminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  Map<String, dynamic> _kpiData = {};
  List<dynamic> _merchants = [];
  List<dynamic> _topups = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Accept': 'application/json',
        },
      ));

      final dashboardRes = await dio.get('/admin/dashboard');
      if (dashboardRes.data['success']) {
        _kpiData = dashboardRes.data['data']['kpi'];
        _merchants = dashboardRes.data['data']['merchants'];
      }

      final topupsRes = await dio.get('/admin/topups');
      if (topupsRes.data['success']) {
        _topups = topupsRes.data['data'];
      }

    } catch (e) {
      debugPrint('Superadmin fetch error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _approveTopup(int id) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Accept': 'application/json',
        },
      ));
      final res = await dio.post('/admin/topups/$id/approve');
      if (res.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Top Up Disetujui')));
        _fetchData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antiribet Super Admin'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey[900],
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Center(child: Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 24))),
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.white70),
                  title: const Text('Global Stats', style: TextStyle(color: Colors.white)),
                  selected: _selectedIndex == 0,
                  selectedTileColor: Colors.blue.withOpacity(0.2),
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: Colors.white70),
                  title: const Text('Top Up Requests', style: TextStyle(color: Colors.white)),
                  selected: _selectedIndex == 1,
                  selectedTileColor: Colors.blue.withOpacity(0.2),
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _selectedIndex == 0 ? _buildGlobalStats() : _buildTopups(),
          )
        ],
      ),
    );
  }

  Widget _buildGlobalStats() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Global Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('Total Merchants', '${_kpiData['total_merchants'] ?? 0}', Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Platform Revenue', 'Rp ${_kpiData['total_platform_revenue'] ?? 0}', Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('Success Transactions', '${_kpiData['total_successful_transactions'] ?? 0}', Colors.orange),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Registered Merchants', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _merchants.length,
              itemBuilder: (context, index) {
                final m = _merchants[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.storefront),
                    title: Text(m['name']),
                    subtitle: Text('Saldo: Rp ${m['balance']} | Terdaftar: ${m['joined_at']}'),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopups() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pending Top Up Requests', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _topups.length,
              itemBuilder: (context, index) {
                final t = _topups[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.money),
                    title: Text('${t['merchant_name']} - Rp ${t['amount']}'),
                    subtitle: Text('Metode: ${t['payment_method']} | Status: ${t['status']}'),
                    trailing: t['status'] == 'pending' 
                      ? ElevatedButton(
                          onPressed: () => _approveTopup(t['id']),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text('Approve'),
                        )
                      : null,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
