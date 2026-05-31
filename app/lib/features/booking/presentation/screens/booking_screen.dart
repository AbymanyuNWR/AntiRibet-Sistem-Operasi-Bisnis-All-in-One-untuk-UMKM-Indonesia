import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/auth_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';
import '../../../../core/components/v2_status_badge.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isLoading = true;
  List<dynamic> _bookings = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/bookings');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _bookings = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat jadwal booking.';
      });
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final dio = DioClient().dio;
      final response = await dio.post('/merchant/bookings/$id/status', data: {'status': status});
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Status Booking Diperbarui.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
            backgroundColor: V2Colors.successGreen,
          ));
          _fetchBookings();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data['message'] ?? 'Gagal update status.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: V2Colors.errorRed,
        ));
      }
    }
  }

  V2BadgeStatus _getBadgeStatus(String status) {
    switch (status) {
      case 'completed': return V2BadgeStatus.success;
      case 'pending': return V2BadgeStatus.warning;
      case 'confirmed': return V2BadgeStatus.info;
      case 'cancelled': return V2BadgeStatus.error;
      default: return V2BadgeStatus.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservasi & Booking', style: V2Typography.headingMd),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchBookings),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: V2Colors.primaryBlue))
        : _error.isNotEmpty
          ? Center(child: Text(_error, style: V2Typography.bodyMd.copyWith(color: V2Colors.errorRed)))
          : _bookings.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy_outlined, size: 64, color: V2Colors.mutedText),
                    const SizedBox(height: 16),
                    Text('Belum ada jadwal', style: V2Typography.headingSm),
                    const SizedBox(height: 8),
                    Text('Jadwal booking kosong.', style: V2Typography.bodyMd),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final b = _bookings[index];
                  final isFinished = b['status'] == 'completed' || b['status'] == 'cancelled';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: V2ClickableCard(
                      onTap: () {},
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b['customer_name'], style: V2Typography.headingSm),
                              V2StatusBadge(
                                label: b['status'].toUpperCase(),
                                status: _getBadgeStatus(b['status']),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 16, color: V2Colors.secondaryText),
                              const SizedBox(width: 8),
                              Text(b['booking_time'], style: V2Typography.bodyMd),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.design_services_outlined, size: 16, color: V2Colors.secondaryText),
                              const SizedBox(width: 8),
                              Text('${b['service_name']} (Rp ${b['price']})', style: V2Typography.bodyMd),
                            ],
                          ),
                          if (!isFinished) ...[
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                V2Button(
                                  label: 'Batalkan',
                                  variant: V2ButtonVariant.ghost,
                                  onPressed: () => _updateStatus(b['id'], 'cancelled'),
                                ),
                                const SizedBox(width: 12),
                                V2Button(
                                  label: b['status'] == 'pending' ? 'Konfirmasi' : 'Selesai (Potong Rp500)',
                                  onPressed: () => _updateStatus(b['id'], b['status'] == 'pending' ? 'confirmed' : 'completed'),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
