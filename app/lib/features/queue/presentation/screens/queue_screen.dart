import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';
import '../../../../core/components/v2_status_badge.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  List<dynamic> _queues = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchQueues();
  }

  Future<void> _fetchQueues() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/queues');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _queues = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat antrean.';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQueueStatus(int id, String status) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final dio = DioClient().dio;
      final response = await dio.put('/merchant/queues/$id/status', data: {'status': status});
      
      if (mounted) Navigator.pop(context); // close dialog

      if (response.statusCode == 200 && response.data['success'] == true) {
        _fetchQueues();
      }
    } on DioException catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.response?.data['message'] ?? 'Gagal update status'), backgroundColor: V2Colors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Antrean', style: V2Typography.headingMd),
        actions: [
          IconButton(
            icon: const Icon(Icons.tv),
            tooltip: 'Buka Monitor TV',
            onPressed: () => context.go('/dashboard/queue/monitor'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQueues,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error.isNotEmpty
          ? Center(child: Text(_error, style: V2Typography.bodyLg.copyWith(color: V2Colors.errorRed)))
          : _queues.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline, size: 64, color: V2Colors.mutedText),
                    const SizedBox(height: 16),
                    Text('Belum ada antrean.', style: V2Typography.headingSm),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _queues.length,
                itemBuilder: (context, index) {
                  final q = _queues[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: V2Colors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              q['queue_number'],
                              style: V2Typography.headingLg.copyWith(color: V2Colors.primaryBlue),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q['customer_name'] ?? 'Pelanggan', style: V2Typography.labelLg),
                                const SizedBox(height: 4),
                                V2StatusBadge(
                                  label: q['status'] == 'waiting' ? 'Menunggu' 
                                       : q['status'] == 'calling' ? 'Dipanggil' 
                                       : q['status'],
                                  status: q['status'] == 'waiting' ? V2BadgeStatus.warning 
                                        : q['status'] == 'calling' ? V2BadgeStatus.info 
                                        : V2BadgeStatus.success,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              if (q['status'] == 'waiting')
                                V2Button(
                                  label: 'Panggil',
                                  icon: Icons.campaign,
                                  size: V2ButtonSize.small,
                                  onPressed: () => _updateQueueStatus(q['id'], 'calling'),
                                ),
                              if (q['status'] == 'calling') ...[
                                V2Button(
                                  label: 'Selesai (Rp500)',
                                  icon: Icons.check,
                                  size: V2ButtonSize.small,
                                  onPressed: () => _updateQueueStatus(q['id'], 'completed'),
                                ),
                                const SizedBox(height: 8),
                                V2Button(
                                  label: 'Lewati',
                                  variant: V2ButtonVariant.secondary,
                                  size: V2ButtonSize.small,
                                  onPressed: () => _updateQueueStatus(q['id'], 'skipped'),
                                ),
                              ]
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: V2Colors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Modal tambah antrean manual
        },
      ),
    );
  }
}
