import 'package:flutter/material.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_clickable_card.dart';
import 'package:fl_chart/fl_chart.dart'; // We use this for V2 charts

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = true;
  num _totalRevenue = 0;
  num _totalTransactions = 0;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final response = await DioClient().dio.get('/merchant/reports/daily');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _totalRevenue = data['total_revenue'] ?? 0;
          _totalTransactions = data['total_transactions'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat laporan.';
        _isLoading = false;
      });
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan & Analitik', style: V2Typography.headingMd),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
          const SizedBox(width: 16),
        ],
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
            
            Text('Performa Hari Ini', style: V2Typography.headingLg),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: V2Colors.primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: V2Colors.primaryBlue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.trending_up, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text('Total Omzet', style: V2Typography.labelMd.copyWith(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Rp $_totalRevenue', style: V2Typography.numericLg.copyWith(color: Colors.white, fontSize: 32)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: V2Colors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: V2Colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: V2Colors.accentTeal.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.receipt_long, color: V2Colors.accentTeal, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text('Total Transaksi', style: V2Typography.labelMd.copyWith(color: V2Colors.secondaryText)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('$_totalTransactions', style: V2Typography.numericLg.copyWith(fontSize: 32)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tren Mingguan', style: V2Typography.headingLg),
                Text('7 Hari Terakhir', style: V2Typography.bodySm.copyWith(color: V2Colors.secondaryText)),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              height: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: V2Colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: V2Colors.border),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(color: V2Colors.secondaryText, fontWeight: FontWeight.bold, fontSize: 12);
                          String text;
                          switch (value.toInt()) {
                            case 0: text = 'Sen'; break;
                            case 1: text = 'Sel'; break;
                            case 2: text = 'Rab'; break;
                            case 3: text = 'Kam'; break;
                            case 4: text = 'Jum'; break;
                            case 5: text = 'Sab'; break;
                            case 6: text = 'Min'; break;
                            default: text = ''; break;
                          }
                          return Padding(padding: const EdgeInsets.only(top: 10), child: Text(text, style: style));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(color: V2Colors.divider, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 40, color: V2Colors.primaryBlue, width: 20, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: V2Colors.primaryBlue, width: 20, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 30, color: V2Colors.primaryBlue, width: 20, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 80, color: V2Colors.primaryBlue, width: 20, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 50, color: V2Colors.primaryBlue, width: 20, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 90, color: V2Colors.accentTeal, width: 20, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 70, color: V2Colors.accentTeal, width: 20, borderRadius: BorderRadius.circular(4))]),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            Text('Aksi Laporan', style: V2Typography.headingLg),
            const SizedBox(height: 16),
            V2ClickableCard(
              onTap: () {},
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: V2Colors.successGreen.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.file_download_outlined, color: V2Colors.successGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Export Laporan Excel', style: V2Typography.labelLg),
                        Text('Unduh mutasi penjualan bulan ini', style: V2Typography.bodySm.copyWith(color: V2Colors.secondaryText)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: V2Colors.mutedText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
