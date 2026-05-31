import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class PlatformAdminScreen extends StatefulWidget {
  const PlatformAdminScreen({super.key});

  @override
  State<PlatformAdminScreen> createState() => _PlatformAdminScreenState();
}

class _PlatformAdminScreenState extends State<PlatformAdminScreen> {
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _merchants = [];
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
      final dbRes = await dio.get('/merchant/platform/dashboard');
      final mRes = await dio.get('/merchant/platform/merchants');
      
      if (mounted) {
        setState(() {
          _dashboardData = dbRes.data['data'];
          _merchants = mRes.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _renewSubscription(int id) async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/platform/merchants/$id/renew');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription Diperpanjang 30 Hari')));
        _fetchData();
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _lockSubscription(int id) async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/platform/merchants/$id/lock');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aplikasi Merchant Dikunci')));
        _fetchData();
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SaaS Platform Admin (God Mode)', style: V2Typography.headingMd),
        backgroundColor: Colors.deepPurple[900],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardData == null
              ? const Center(child: Text('Gagal memuat data Platform'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple[800]!, Colors.purple[500]!],
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
                              const Icon(Icons.monetization_on, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Total SaaS Revenue (Pendapatan Sewa)', style: V2Typography.labelMd.copyWith(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rp ${_dashboardData!['total_saas_revenue'] ?? 0}',
                            style: V2Typography.headingXl.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Restoran Terdaftar', style: V2Typography.bodySm.copyWith(color: Colors.white70)),
                                    Text('${_dashboardData!['total_merchants']}', style: V2Typography.labelMd.copyWith(color: Colors.white)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Langganan Aktif', style: V2Typography.bodySm.copyWith(color: Colors.white70)),
                                    Text('${_dashboardData!['active_subscriptions']}', style: V2Typography.labelMd.copyWith(color: V2Colors.successGreen)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Daftar Klien (Restoran)', style: V2Typography.headingSm),
                    const SizedBox(height: 16),
                    ..._merchants.map((m) {
                      final isActive = m['subscription_status'] == 'active';
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
                                  Text(m['name'], style: V2Typography.labelLg),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive ? V2Colors.successGreen.withOpacity(0.1) : V2Colors.errorRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isActive ? 'ACTIVE' : 'EXPIRED / NONE',
                                      style: V2Typography.bodySm.copyWith(
                                        color: isActive ? V2Colors.successGreen : V2Colors.errorRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Text('Pemilik: ${m['owner_name']}', style: V2Typography.bodyMd),
                              if (m['valid_until'] != null)
                                Text('Berlaku s/d: ${m['valid_until']}', style: V2Typography.bodySm),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isActive)
                                    V2Button(
                                      label: 'Kunci Akses (Suspend)',
                                      size: V2ButtonSize.small,
                                      variant: V2ButtonVariant.secondary,
                                      onPressed: () => _lockSubscription(m['id']),
                                    ),
                                  const SizedBox(width: 8),
                                  V2Button(
                                    label: '+ Perpanjang 30 Hari (Bayar)',
                                    size: V2ButtonSize.small,
                                    variant: V2ButtonVariant.primary,
                                    onPressed: () => _renewSubscription(m['id']),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
    );
  }
}
