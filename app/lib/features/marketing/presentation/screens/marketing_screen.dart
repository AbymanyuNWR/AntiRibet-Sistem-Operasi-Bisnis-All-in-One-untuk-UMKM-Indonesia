import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  List<dynamic> _campaigns = [];
  bool _isLoading = true;
  bool _isCreating = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  final _discountController = TextEditingController();
  String _selectedAudience = 'all';

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    setState(() => _isLoading = true);
    try {
      final dio = DioClient().dio;
      final res = await dio.get('/merchant/marketing/campaigns');
      if (mounted) {
        setState(() {
          _campaigns = res.data['data'] ?? [];
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createCampaign() async {
    try {
      final dio = DioClient().dio;
      await dio.post('/merchant/marketing/campaigns', data: {
        'name': _nameController.text,
        'target_audience': _selectedAudience,
        'message': _messageController.text,
        'discount_percentage': _discountController.text.isNotEmpty ? num.parse(_discountController.text) : 0,
      });
      _nameController.clear();
      _messageController.clear();
      _discountController.clear();
      setState(() => _isCreating = false);
      _fetchCampaigns();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign berhasil dibuat!')));
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _broadcast(int id) async {
    try {
      final dio = DioClient().dio;
      final res = await dio.post('/merchant/marketing/campaigns/$id/broadcast');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res.data['message']),
          backgroundColor: V2Colors.successGreen,
        ));
      }
      _fetchCampaigns();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal melakukan broadcast'),
          backgroundColor: V2Colors.errorRed,
        ));
      }
    }
  }

  Widget _buildCreateForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buat Promo Baru', style: V2Typography.headingSm),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Campaign (Cth: Promo Akhir Tahun)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedAudience,
            decoration: const InputDecoration(labelText: 'Target Audiens'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Semua Pelanggan')),
              DropdownMenuItem(value: 'sleeping', child: Text('Pelanggan Tidur (Hilang > 30 Hari)')),
              DropdownMenuItem(value: 'loyal', child: Text('Pelanggan Loyal (Poin >= 50)')),
            ],
            onChanged: (val) => setState(() => _selectedAudience = val!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Diskon % (Opsional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Pesan Broadcast (WA/Email)',
              hintText: 'Halo kak, kangen nih sama kakak. Ada diskon...',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _isCreating = false),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              V2Button(
                label: 'Simpan',
                size: V2ButtonSize.small,
                onPressed: _createCampaign,
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketing Auto-Pilot', style: V2Typography.headingMd),
        actions: [
          if (!_isCreating)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _isCreating = true),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_isCreating) ...[
                  _buildCreateForm(),
                  const SizedBox(height: 24),
                ],
                Text('Daftar Campaign', style: V2Typography.headingSm),
                const SizedBox(height: 16),
                if (_campaigns.isEmpty)
                  const Text('Belum ada campaign pemasaran.')
                else
                  ..._campaigns.map((c) {
                    final isBroadcasted = c['status'] == 'broadcasted';
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
                                Expanded(child: Text(c['name'], style: V2Typography.labelLg)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isBroadcasted ? V2Colors.successGreen.withOpacity(0.1) : V2Colors.warningAmber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isBroadcasted ? 'TERKIRIM' : 'DRAFT',
                                    style: V2Typography.bodySm.copyWith(
                                      color: isBroadcasted ? V2Colors.successGreen : V2Colors.warningAmber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Target: ${c['target_audience']}', style: V2Typography.bodyMd),
                            Text('Diskon: ${c['discount_percentage']}%', style: V2Typography.bodyMd),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey.shade50,
                              child: Text('"${c['message']}"', style: V2Typography.bodySm.copyWith(fontStyle: FontStyle.italic)),
                            ),
                            const SizedBox(height: 16),
                            if (!isBroadcasted)
                              V2Button(
                                label: ' JALANKAN BROADCAST SEKARANG',
                                isFullWidth: true,
                                variant: V2ButtonVariant.primary,
                                onPressed: () => _broadcast(c['id']),
                              )
                            else
                              Text(
                                'Berhasil menjangkau ${c['recipients_count']} pelanggan.',
                                style: V2Typography.bodySm.copyWith(color: V2Colors.successGreen),
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
