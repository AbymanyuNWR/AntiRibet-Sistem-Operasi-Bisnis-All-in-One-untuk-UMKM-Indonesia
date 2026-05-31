import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _isLoading = true;
  List<dynamic> _catalogItems = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  Future<void> _fetchCatalog() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/catalog');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _catalogItems = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat katalog.';
      });
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      final dio = DioClient().dio;
      await dio.delete('/merchant/catalog/$id');
      _fetchCatalog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Menu dihapus.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: V2Colors.errorRed,
        ));
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _toggleAvailability(int id, bool currentStatus) async {
    try {
      final dio = DioClient().dio;
      await dio.put('/merchant/catalog/$id', data: {'is_available': !currentStatus});
      _fetchCatalog();
    } catch (e) {
      // Ignore
    }
  }

  void _showFormDialog({Map<String, dynamic>? item}) {
    final nameController = TextEditingController(text: item?['name']);
    final descController = TextEditingController(text: item?['description']);
    final priceController = TextEditingController(text: item?['price']?.toString());
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: V2Colors.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item == null ? 'Tambah Menu' : 'Edit Menu', style: V2Typography.headingMd),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(color: V2Colors.divider, height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Produk / Menu'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi Singkat'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 32),
                  V2Button(
                    label: 'Simpan Menu',
                    isFullWidth: true,
                    size: V2ButtonSize.large,
                    isLoading: isSaving,
                    onPressed: () async {
                      if (nameController.text.isEmpty || priceController.text.isEmpty) return;
                      setModalState(() => isSaving = true);
                      
                      try {
                        final dio = DioClient().dio;
                        final data = {
                          'name': nameController.text,
                          'description': descController.text,
                          'price': int.parse(priceController.text),
                        };

                        if (item == null) {
                          await dio.post('/merchant/catalog', data: data);
                        } else {
                          await dio.put('/merchant/catalog/${item['id']}', data: data);
                        }
                        
                        if (mounted) {
                          Navigator.pop(context);
                          _fetchCatalog();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Menu tersimpan.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
                            backgroundColor: V2Colors.successGreen,
                          ));
                        }
                      } catch (e) {
                        setModalState(() => isSaving = false);
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katalog Menu & Produk', style: V2Typography.headingMd),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchCatalog),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: V2Colors.primaryBlue))
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: V2Typography.bodyMd.copyWith(color: V2Colors.errorRed)))
              : _catalogItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 64, color: V2Colors.mutedText),
                          const SizedBox(height: 16),
                          Text('Belum ada Menu', style: V2Typography.headingSm),
                          const SizedBox(height: 8),
                          Text('Katalog produk Anda masih kosong.', style: V2Typography.bodyMd),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _catalogItems.length,
                      itemBuilder: (context, index) {
                        final item = _catalogItems[index];
                        final isAvailable = item['is_available'] == 1 || item['is_available'] == true;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: V2ClickableCard(
                            onTap: () => _showFormDialog(item: item),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: V2Colors.pageBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: V2Colors.border),
                                  ),
                                  child: const Center(child: Icon(Icons.fastfood_outlined, color: V2Colors.secondaryText)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name'], style: V2Typography.labelLg),
                                      const SizedBox(height: 4),
                                      Text('Rp ${item['price']}', style: V2Typography.numericMd.copyWith(color: V2Colors.primaryBlue)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8, height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isAvailable ? V2Colors.successGreen : V2Colors.errorRed,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isAvailable ? 'Tersedia' : 'Habis',
                                            style: V2Typography.labelSm.copyWith(color: isAvailable ? V2Colors.successGreen : V2Colors.errorRed),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isAvailable,
                                  onChanged: (val) => _toggleAvailability(item['id'], isAvailable),
                                  activeColor: V2Colors.successGreen,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: V2Colors.errorRed),
                                  onPressed: () => _deleteItem(item['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: V2Colors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Menu', style: V2Typography.labelLg.copyWith(color: Colors.white)),
      ),
    );
  }
}
