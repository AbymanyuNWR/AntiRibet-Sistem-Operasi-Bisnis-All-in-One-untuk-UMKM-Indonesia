import 'package:flutter/material.dart';
import 'dart:async';
import 'package:antiribet/core/network/auth_service.dart';
import 'package:antiribet/core/network/dio_client.dart';
import 'package:antiribet/core/theme/v2_colors.dart';
import 'package:antiribet/core/theme/v2_typography.dart';
import 'package:antiribet/core/components/v2_buttons.dart';
import 'package:antiribet/core/components/v2_clickable_card.dart';
import 'package:antiribet/core/components/v2_status_badge.dart';

class QueueMonitorScreen extends StatefulWidget {
  const QueueMonitorScreen({super.key});

  @override
  State<QueueMonitorScreen> createState() => _QueueMonitorScreenState();
}

class _QueueMonitorScreenState extends State<QueueMonitorScreen> {
  Timer? _timer;
  bool _isLoading = false;
  String _error = "";
  List<dynamic> _queues = [];

  @override
  void initState() {
    super.initState();
    _fetchQueues();
    // Auto-refresh every 5 seconds for TV Monitor
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchQueues());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchQueues() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/queues');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _queues = response.data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Gagal memuat antrean.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCalling = _queues.where((q) => q['status'] == 'calling' || q['status'] == 'serving').toList();
    final waiting = _queues.where((q) => q['status'] == 'waiting').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Monitor Antrean', style: V2Typography.headingMd),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchQueues),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Kiri: Nomor Antrean Saat Ini (Besar)
          Expanded(
            flex: 6,
            child: Container(
              color: V2Colors.primaryBlue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('NOMOR ANTREAN', style: TextStyle(color: Colors.white70, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4)),
                  const SizedBox(height: 24),
                  if (currentCalling.isEmpty)
                    const Text('--', style: TextStyle(color: Colors.white, fontSize: 160, fontWeight: FontWeight.w900))
                  else
                    Text(
                      currentCalling.first['queue_number'],
                      style: const TextStyle(color: Colors.white, fontSize: 160, fontWeight: FontWeight.w900),
                    ),
                  const SizedBox(height: 24),
                  if (currentCalling.isNotEmpty)
                    Text('Menuju ke Kasir / Layanan', style: const TextStyle(color: Colors.white70, fontSize: 24)),
                ],
              ),
            ),
          ),
          
          // Kanan: Daftar Tunggu
          Expanded(
            flex: 4,
            child: Container(
              color: V2Colors.pageBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: V2Colors.cardBackground,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                    child: Text('Daftar Menunggu', style: V2Typography.headingLg.copyWith(color: V2Colors.primaryBlue)),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: waiting.isEmpty
                      ? const Center(child: Text('Tidak ada daftar tunggu', style: TextStyle(fontSize: 24, color: Colors.grey)))
                      : ListView.builder(
                          itemCount: waiting.length > 5 ? 5 : waiting.length, // Tampilkan max 5
                          itemBuilder: (context, index) {
                            final q = waiting[index];
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: V2Colors.border)),
                                color: V2Colors.cardBackground,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(q['queue_number'], style: V2Typography.headingLg.copyWith(fontSize: 40)),
                                  Text(q['customer_name'] ?? 'Pelanggan', style: V2Typography.bodyLg.copyWith(fontSize: 24)),
                                ],
                              ),
                            );
                          },
                        ),
                  ),
                  // Running text or logo placeholder
                  Container(
                    color: V2Colors.cardBackground,
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('Powered by AntiRibet App', style: V2Typography.bodySm.copyWith(color: V2Colors.mutedText)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
