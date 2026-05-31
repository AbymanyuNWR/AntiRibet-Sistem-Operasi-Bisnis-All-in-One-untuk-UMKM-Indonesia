import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/auth_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_clickable_card.dart';
import '../../../../core/components/v2_buttons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  num _totalSales = 0;
  num _totalOrders = 0;
  num _walletBalance = 0;
  String _businessSlug = '';
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final dio = DioClient().dio;

      final response = await dio.get('/merchant/dashboard');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (mounted) {
          setState(() {
            _businessSlug = data['business_slug'] ?? '';
            _totalSales = data['total_sales_today'] ?? 0;
            _totalOrders = data['total_orders_today'] ?? 0;
            _walletBalance = data['wallet_balance'] ?? 0;
            _isLoading = false;
          });
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.response?.data?['message'] ?? 'Gagal memuat data. Periksa koneksi server.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Terjadi kesalahan: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: V2Colors.primaryBlue),
        ),
      );
    }

    final bool isLowBalance = _walletBalance < 10000;
    // Hanya tampilkan onboarding jika slug benar-benar kosong (bukan 'unknown-business')
    final bool needsOnboarding = _businessSlug.isEmpty || _businessSlug == 'unknown-business';

    return Scaffold(
      appBar: AppBar(
        title: Text('Overview Bisnis', style: V2Typography.headingMd),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: _fetchDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: V2Colors.errorRed),
            tooltip: 'Keluar',
            onPressed: () async {
              final storage = const FlutterSecureStorage();
              await storage.delete(key: 'auth_token');
              AuthService.logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error State
            if (_error.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: V2Colors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: V2Colors.errorRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: V2Colors.errorRed),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error, style: V2Typography.bodyMd)),
                    V2Button(
                      label: 'Coba Lagi',
                      size: V2ButtonSize.small,
                      variant: V2ButtonVariant.secondary,
                      onPressed: () {
                        setState(() => _isLoading = true);
                        _fetchDashboardData();
                      },
                    )
                  ],
                ),
              ),

            if (needsOnboarding && _error.isEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: V2Colors.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: V2Colors.primaryBlue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings_outlined, color: V2Colors.primaryBlue, size: 20),
                        const SizedBox(width: 10),
                        Text('Lengkapi Pengaturan Bisnis', style: V2Typography.headingSm),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan informasi bisnis Anda agar pelanggan dapat memesan via QR dan Website.',
                      style: V2Typography.bodyMd.copyWith(color: V2Colors.secondaryText),
                    ),
                    const SizedBox(height: 16),
                    V2Button(
                      label: 'Mulai Pengaturan',
                      onPressed: () => context.go('/onboarding'),
                    ),
                  ],
                ),
              ),

            // Low Balance Warning
            if (isLowBalance && AuthService.userRole != 'merchant_staff')
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: V2Colors.warningAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: V2Colors.warningAmber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: V2Colors.warningAmber, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saldo Wallet Hampir Habis', style: V2Typography.labelLg),
                          const SizedBox(height: 4),
                          Text(
                            'Transaksi kasir & QR order mungkin tertunda jika saldo habis.',
                            style: V2Typography.bodySm,
                          ),
                        ],
                      ),
                    ),
                    V2Button(
                      label: 'Top Up',
                      size: V2ButtonSize.small,
                      onPressed: () => context.go('/dashboard/wallet'),
                    ),
                  ],
                ),
              ),

            Text('Ringkasan Hari Ini', style: V2Typography.headingLg),
            const SizedBox(height: 16),

            // Clickable Metrics
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MetricCard(
                  label: 'Total Penjualan',
                  value: 'Rp $_totalSales',
                  icon: Icons.trending_up,
                  iconColor: V2Colors.successGreen,
                  onTap: () => context.go('/dashboard/reports'),
                ),
                _MetricCard(
                  label: 'Pesanan Sukses',
                  value: '$_totalOrders',
                  icon: Icons.receipt_long,
                  iconColor: V2Colors.primaryBlue,
                  onTap: () => context.go('/dashboard/reports'),
                ),
                if (AuthService.userRole != 'merchant_staff')
                  _MetricCard(
                    label: 'Saldo AntiRibet',
                    value: 'Rp $_walletBalance',
                    icon: Icons.account_balance_wallet,
                    iconColor: V2Colors.warningAmber,
                    backgroundColor: isLowBalance ? V2Colors.warningAmber.withOpacity(0.05) : null,
                    onTap: () => context.go('/dashboard/wallet'),
                  ),
              ],
            ),

            const SizedBox(height: 40),
            Text('Akses Modul Cepat', style: V2Typography.headingLg),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ModuleCard(
                  title: 'Kasir POS',
                  icon: Icons.point_of_sale,
                  color: V2Colors.primaryBlue,
                  onTap: () => context.go('/dashboard/pos'),
                ),
                _ModuleCard(
                  title: 'Antrean',
                  icon: Icons.people_alt,
                  color: V2Colors.accentTeal,
                  onTap: () => context.go('/dashboard/queue'),
                ),
                _ModuleCard(
                  title: 'Dapur (KDS)',
                  icon: Icons.soup_kitchen,
                  color: V2Colors.errorRed,
                  onTap: () => context.go('/dashboard/kds'),
                ),
                _ModuleCard(
                  title: 'Pengiriman (Kurir)',
                  icon: Icons.delivery_dining,
                  color: Colors.orange,
                  onTap: () => context.go('/dashboard/delivery'),
                ),
                if (AuthService.userRole != 'merchant_staff') ...[
                  _ModuleCard(
                    title: 'Katalog',
                    icon: Icons.inventory_2,
                    color: V2Colors.infoBlue,
                    onTap: () => context.go('/dashboard/catalog'),
                  ),
                  _ModuleCard(
                    title: 'QR Order',
                    icon: Icons.qr_code_2,
                    color: V2Colors.successGreen,
                    onTap: () => context.go('/dashboard/qr', extra: _businessSlug),
                  ),
                  _ModuleCard(
                    title: 'Gudang (BOM)',
                    icon: Icons.kitchen,
                    color: V2Colors.warningAmber,
                    onTap: () => context.go('/dashboard/inventory'),
                  ),
                  _ModuleCard(
                    title: 'Pembelian (PO)',
                    icon: Icons.local_shipping,
                    color: Colors.brown,
                    onTap: () => context.go('/dashboard/supply'),
                  ),
                  _ModuleCard(
                    title: 'Akuntansi (P&L)',
                    icon: Icons.account_balance,
                    color: Colors.blueGrey,
                    onTap: () => context.go('/dashboard/accounting'),
                  ),
                  _ModuleCard(
                    title: 'Pemasaran (Ads)',
                    icon: Icons.campaign,
                    color: Colors.pinkAccent,
                    onTap: () => context.go('/dashboard/marketing'),
                  ),
                  _ModuleCard(
                    title: 'HQ (Franchise)',
                    icon: Icons.account_balance,
                    color: Colors.black87,
                    onTap: () => context.go('/dashboard/hq'),
                  ),
                  _ModuleCard(
                    title: 'SaaS Platform Admin',
                    icon: Icons.admin_panel_settings,
                    color: Colors.deepPurple,
                    onTap: () => context.go('/dashboard/platform'),
                  ),
                  _ModuleCard(
                    title: 'CRM & Loyalti',
                    icon: Icons.loyalty,
                    color: Colors.purple,
                    onTap: () => context.go('/dashboard/crm'),
                  ),
                  _ModuleCard(
                    title: 'Asisten AI',
                    icon: Icons.smart_toy,
                    color: V2Colors.primaryBlue,
                    onTap: () => context.go('/dashboard/ai'),
                  ),
                  _ModuleCard(
                    title: 'Pegawai',
                    icon: Icons.badge,
                    color: V2Colors.secondaryText,
                    onTap: () => context.go('/dashboard/staff'),
                  ),
                  _ModuleCard(
                    title: 'HRD & Penggajian',
                    icon: Icons.groups,
                    color: Colors.indigo,
                    onTap: () => context.go('/dashboard/hris'),
                  ),
                  _ModuleCard(
                    title: 'Printer',
                    icon: Icons.print,
                    color: V2Colors.secondaryText,
                    onTap: () => context.go('/dashboard/printer'),
                  ),
                ] else ...[
                  _ModuleCard(
                    title: 'Absensi (Clock-In)',
                    icon: Icons.access_time_filled,
                    color: Colors.indigo,
                    onTap: () => context.go('/dashboard/hris'),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: V2ClickableCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: V2Typography.labelSm,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: V2ClickableCard(
        onTap: onTap,
        backgroundColor: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: V2Typography.bodySm),
                    const SizedBox(height: 2),
                    Text(value, style: V2Typography.numericLg),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: V2Colors.mutedText, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
