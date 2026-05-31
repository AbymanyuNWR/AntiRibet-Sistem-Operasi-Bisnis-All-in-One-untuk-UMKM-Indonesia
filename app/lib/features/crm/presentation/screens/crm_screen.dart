import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import 'package:intl/intl.dart';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});

  @override
  State<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends State<CrmScreen> {
  List<dynamic> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/crm/leaderboard');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _customers = response.data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRM & Loyalti', style: V2Typography.headingMd),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: V2Colors.mutedText),
                      const SizedBox(height: 16),
                      Text('Belum ada pelanggan terdaftar', style: V2Typography.headingSm),
                      Text('Masukkan No. HP pelanggan saat checkout di Kasir', style: V2Typography.bodyMd),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    final rank = index + 1;
                    
                    Color rankColor = V2Colors.primaryBlue;
                    if (rank == 1) rankColor = V2Colors.warningAmber; // Gold
                    if (rank == 2) rankColor = Colors.grey.shade400; // Silver
                    if (rank == 3) rankColor = Colors.brown.shade400; // Bronze

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: V2Colors.border),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rankColor.withOpacity(0.1),
                          child: Text('#$rank', style: V2Typography.labelLg.copyWith(color: rankColor)),
                        ),
                        title: Text(customer['name'] ?? customer['phone'], style: V2Typography.labelLg),
                        subtitle: Text(
                          'Total Belanja: Rp ${NumberFormat('#,###', 'id_ID').format(num.tryParse(customer['total_spent'] ?? '0'))}',
                          style: V2Typography.bodyMd.copyWith(color: V2Colors.secondaryText),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${customer['points']}', style: V2Typography.headingSm.copyWith(color: V2Colors.successGreen)),
                            Text('Poin', style: V2Typography.bodySm.copyWith(color: V2Colors.mutedText)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
