import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> _ingredients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/inventory');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _ingredients = response.data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final unitController = TextEditingController(text: 'pcs');
    final minStockController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Bahan Baku', style: V2Typography.headingSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Bahan (cth: Susu, Gula)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: 'Satuan (gram, ml, pcs)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minStockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peringatan Stok Minimum'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          V2Button(
            label: 'Simpan',
            size: V2ButtonSize.small,
            onPressed: () async {
              try {
                final dio = DioClient().dio;
                await dio.post('/merchant/inventory', data: {
                  'name': nameController.text,
                  'unit': unitController.text,
                  'current_stock': 0, // Awalnya 0, harus restock
                  'minimum_stock': int.parse(minStockController.text),
                });
                if (mounted) {
                  Navigator.pop(ctx);
                  _fetchInventory();
                }
              } catch (e) {
                // error
              }
            },
          )
        ],
      ),
    );
  }

  void _showRestockDialog(int id, String name) {
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restock $name', style: V2Typography.headingSm),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Jumlah Tambahan Stok'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          V2Button(
            label: 'Tambah',
            size: V2ButtonSize.small,
            onPressed: () async {
              try {
                final dio = DioClient().dio;
                await dio.put('/merchant/inventory/$id/restock', data: {
                  'add_stock': num.parse(qtyController.text),
                });
                if (mounted) {
                  Navigator.pop(ctx);
                  _fetchInventory();
                }
              } catch (e) {
                // error
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gudang (Inventaris)', style: V2Typography.headingMd),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ingredients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 64, color: V2Colors.mutedText),
                      const SizedBox(height: 16),
                      Text('Gudang Kosong', style: V2Typography.headingSm),
                      Text('Tambahkan bahan baku untuk menggunakan fitur resep (BOM)', style: V2Typography.bodyMd),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final item = _ingredients[index];
                    final isLowStock = item['current_stock'] <= item['minimum_stock'];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: isLowStock ? V2Colors.errorRed : V2Colors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isLowStock ? V2Colors.errorRed.withOpacity(0.1) : V2Colors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.kitchen, color: isLowStock ? V2Colors.errorRed : V2Colors.primaryBlue),
                        ),
                        title: Text(item['name'], style: V2Typography.labelLg),
                        subtitle: Text(
                          'Sisa: ${item['current_stock']} ${item['unit']} (Min: ${item['minimum_stock']})',
                          style: V2Typography.bodyMd.copyWith(color: isLowStock ? V2Colors.errorRed : V2Colors.secondaryText),
                        ),
                        trailing: V2Button(
                          label: 'Restock',
                          size: V2ButtonSize.small,
                          variant: V2ButtonVariant.secondary,
                          onPressed: () => _showRestockDialog(item['id'], item['name']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
