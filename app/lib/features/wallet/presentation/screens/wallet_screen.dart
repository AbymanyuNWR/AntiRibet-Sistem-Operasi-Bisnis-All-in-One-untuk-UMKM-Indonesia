import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/auth_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  num _balance = 0;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _error = '';

  final TextEditingController _topUpController = TextEditingController();
  bool _isToppingUp = false;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/wallet');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _balance = data['wallet']['balance'] ?? 0;
          _transactions = data['transactions'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data dompet.';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestTopUp() async {
    final amountText = _topUpController.text;
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Minimal Top Up adalah Rp 10.000', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: V2Colors.errorRed,
      ));
      return;
    }

    setState(() => _isToppingUp = true);

    try {
      final dio = DioClient().dio;
      final response = await dio.post('/merchant/wallet/topup', data: {
        'amount': amount,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Request Top Up Berhasil. Menunggu persetujuan Admin.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
            backgroundColor: V2Colors.successGreen,
          ));
          _topUpController.clear();
          _fetchWalletData();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data['message'] ?? 'Gagal Request Top Up', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: V2Colors.errorRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _isToppingUp = false);
    }
  }

  void _showTransactionDetails(dynamic tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: V2Colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Detail Transaksi', style: V2Typography.headingMd),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(color: V2Colors.divider, height: 32),
            Text(tx['description'], style: V2Typography.bodyLg),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Waktu', style: V2Typography.bodyMd.copyWith(color: V2Colors.secondaryText)),
                Text(tx['created_at'], style: V2Typography.labelMd),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nominal', style: V2Typography.bodyMd.copyWith(color: V2Colors.secondaryText)),
                Text(
                  'Rp ${tx['amount']}',
                  style: V2Typography.numericLg.copyWith(
                    color: tx['type'] == 'credit' ? V2Colors.successGreen : V2Colors.errorRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            V2Button(
              label: 'Bantuan Transaksi',
              isFullWidth: true,
              variant: V2ButtonVariant.secondary,
              onPressed: () {
                // Future Support Action
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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

    final bool isLowBalance = _balance < 10000;

    return Scaffold(
      appBar: AppBar(
        title: Text('Saldo & Tagihan', style: V2Typography.headingMd),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(_error, style: V2Typography.bodyMd.copyWith(color: V2Colors.errorRed)),
              ),
            
            // Professional V2 Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: V2Colors.primaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: V2Colors.primaryBlue.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 24),
                      const SizedBox(width: 12),
                      Text('Saldo Tersedia', style: V2Typography.bodyLg.copyWith(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Rp $_balance', style: V2Typography.numericXl.copyWith(color: Colors.white, fontSize: 40)),
                  if (isLowBalance) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: V2Colors.warningAmber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: V2Colors.warningAmber.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber, color: V2Colors.warningAmber, size: 16),
                          const SizedBox(width: 8),
                          Text('Saldo rendah, disarankan Top Up.', style: V2Typography.labelSm.copyWith(color: V2Colors.warningAmber)),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Text('Isi Saldo (Top Up)', style: V2Typography.headingLg),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: V2Colors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: V2Colors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _topUpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Minimal Rp 10.000',
                        prefixText: 'Rp ',
                        labelText: 'Nominal Top Up',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  V2Button(
                    label: 'Request Top Up',
                    isLoading: _isToppingUp,
                    size: V2ButtonSize.large,
                    onPressed: _requestTopUp,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Text('Riwayat Transaksi', style: V2Typography.headingLg),
            const SizedBox(height: 16),
            
            if (_transactions.isEmpty) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: V2Colors.pageBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: V2Colors.border, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long, size: 48, color: V2Colors.mutedText),
                    const SizedBox(height: 16),
                    Text('Belum ada riwayat.', style: V2Typography.bodyMd.copyWith(color: V2Colors.secondaryText)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  final isCredit = tx['type'] == 'credit';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: V2ClickableCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () => _showTransactionDetails(tx),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCredit ? V2Colors.successGreen.withOpacity(0.1) : V2Colors.errorRed.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isCredit ? V2Colors.successGreen : V2Colors.errorRed,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx['description'],
                                  style: V2Typography.labelLg,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(tx['created_at'], style: V2Typography.bodySm),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${isCredit ? '+' : '-'} Rp ${tx['amount']}',
                            style: V2Typography.numericMd.copyWith(
                              color: isCredit ? V2Colors.successGreen : V2Colors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
