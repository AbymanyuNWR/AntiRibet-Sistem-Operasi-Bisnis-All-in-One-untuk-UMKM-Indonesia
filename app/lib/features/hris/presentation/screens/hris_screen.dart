import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/auth_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class HrisScreen extends StatefulWidget {
  const HrisScreen({super.key});

  @override
  State<HrisScreen> createState() => _HrisScreenState();
}

class _HrisScreenState extends State<HrisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _staffList = [];
  List<dynamic> _payrolls = [];
  bool _isLoading = true;
  bool _isClockedIn = false;

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
      if (AuthService.userRole != 'merchant_staff') {
        final staffRes = await dio.get('/merchant/hr/staff');
        final payrollRes = await dio.get('/merchant/hr/payrolls');
        if (mounted) {
          setState(() {
            _staffList = staffRes.data['data'] ?? [];
            _payrolls = payrollRes.data['data'] ?? [];
          });
        }
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _clockIn() async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/hr/attendance/clock-in');
      setState(() => _isClockedIn = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Berhasil Clock-In! Selamat bekerja.'),
          backgroundColor: V2Colors.successGreen,
        ));
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _clockOut() async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/hr/attendance/clock-out');
      setState(() => _isClockedIn = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Berhasil Clock-Out! Sampai jumpa.'),
          backgroundColor: V2Colors.primaryBlue,
        ));
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _generatePayroll(int userId) async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/hr/payroll/generate', data: {'user_id': userId});
      _fetchData();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _payPayroll(int id) async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/hr/payrolls/$id/pay');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gaji dibayar & tercatat di Akuntansi!'),
          backgroundColor: V2Colors.successGreen,
        ));
        _fetchData();
      }
    } catch (e) {
      // ignore
    }
  }

  Widget _buildAttendanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_filled, size: 80, color: _isClockedIn ? V2Colors.successGreen : V2Colors.mutedText),
          const SizedBox(height: 24),
          Text(
            _isClockedIn ? 'Status: Sedang Bekerja' : 'Status: Belum Clock-In',
            style: V2Typography.headingSm,
          ),
          const SizedBox(height: 32),
          if (!_isClockedIn)
            V2Button(
              label: 'CLOCK IN',
              size: V2ButtonSize.large,
              onPressed: _clockIn,
            )
          else
            V2Button(
              label: 'CLOCK OUT',
              size: V2ButtonSize.large,
              variant: V2ButtonVariant.secondary,
              onPressed: _clockOut,
            ),
        ],
      ),
    );
  }

  Widget _buildOwnerTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Pegawai', style: V2Typography.headingSm),
        const SizedBox(height: 8),
        ..._staffList.map((staff) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(staff['name'], style: V2Typography.labelMd),
              subtitle: Text('Upah: Rp ${staff['hourly_rate']}/jam'),
              trailing: V2Button(
                label: 'Buat Slip Gaji',
                size: V2ButtonSize.small,
                onPressed: () => _generatePayroll(staff['id']),
              ),
            )),
        const Divider(height: 32),
        Text('Daftar Slip Gaji', style: V2Typography.headingSm),
        const SizedBox(height: 8),
        ..._payrolls.map((payroll) {
          final isPaid = payroll['status'] == 'paid';
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
                      Text(payroll['user']?['name'] ?? 'Pegawai', style: V2Typography.labelMd),
                      Text(
                        isPaid ? 'PAID' : 'PENDING',
                        style: V2Typography.labelMd.copyWith(color: isPaid ? V2Colors.successGreen : V2Colors.warningAmber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Total Gaji: Rp ${payroll['total_amount']}', style: V2Typography.headingSm),
                  const SizedBox(height: 12),
                  if (!isPaid)
                    V2Button(
                      label: 'Bayar & Masukkan ke Jurnal Akuntansi',
                      isFullWidth: true,
                      size: V2ButtonSize.small,
                      onPressed: () => _payPayroll(payroll['id']),
                    )
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = AuthService.userRole != 'merchant_staff';
    return Scaffold(
      appBar: AppBar(
        title: Text('SDM & Penggajian (HRIS)', style: V2Typography.headingMd),
        bottom: isOwner ? TabBar(
          controller: _tabController,
          labelColor: V2Colors.primaryBlue,
          unselectedLabelColor: V2Colors.secondaryText,
          indicatorColor: V2Colors.primaryBlue,
          tabs: const [
            Tab(text: 'Absensi Anda'),
            Tab(text: 'Admin HRD (Owner)'),
          ],
        ) : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isOwner
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAttendanceTab(),
                    _buildOwnerTab(),
                  ],
                )
              : _buildAttendanceTab(),
    );
  }
}
