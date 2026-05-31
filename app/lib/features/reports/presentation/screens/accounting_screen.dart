import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_clickable_card.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  Map<String, dynamic>? _pnlData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPnL();
  }

  Future<void> _fetchPnL() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('/merchant/accounting/pnl');
      if (mounted) {
        setState(() {
          _pnlData = res.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laba Rugi (P&L)', style: V2Typography.headingMd),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pnlData == null
              ? const Center(child: Text('Gagal memuat data keuangan'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('Laba Kotor (Gross Profit)', style: V2Typography.labelMd.copyWith(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            'Rp ${_pnlData!['gross_profit']}',
                            style: V2Typography.headingXl.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pendapatan', style: V2Typography.bodySm.copyWith(color: Colors.white70)),
                                  Text('Rp ${_pnlData!['revenue']}', style: V2Typography.labelMd.copyWith(color: V2Colors.successGreen)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Harga Pokok (HPP)', style: V2Typography.bodySm.copyWith(color: Colors.white70)),
                                  Text('Rp ${_pnlData!['expense']}', style: V2Typography.labelMd.copyWith(color: V2Colors.errorRed)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Riwayat Buku Besar (General Ledger)', style: V2Typography.headingSm),
                    const SizedBox(height: 16),
                    ...(_pnlData!['journals'] as List).map((journal) {
                      return V2ClickableCard(
                        onTap: () {},
                        
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(journal['description'], style: V2Typography.labelMd),
                              Text('Ref: ${journal['reference_type']} #${journal['reference_id']}', style: V2Typography.bodySm.copyWith(color: V2Colors.secondaryText)),
                              const Divider(height: 24),
                              ...(journal['lines'] as List).map((line) {
                                final isDebit = line['debit'] > 0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(line['account']['name'], style: V2Typography.bodyMd),
                                      Text(
                                        isDebit ? 'Db Rp ${line['debit']}' : 'Cr Rp ${line['credit']}',
                                        style: V2Typography.bodyMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDebit ? V2Colors.primaryBlue : V2Colors.accentTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
