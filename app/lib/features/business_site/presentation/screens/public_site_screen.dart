import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../app/theme.dart';

class PublicSiteScreen extends StatefulWidget {
  final String slug;
  final String? tableNumber;

  const PublicSiteScreen({
    super.key,
    required this.slug,
    this.tableNumber,
  });

  @override
  State<PublicSiteScreen> createState() => _PublicSiteScreenState();
}

class _PublicSiteScreenState extends State<PublicSiteScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _businessData;
  List<dynamic> _catalogItems = [];
  
  // Keranjang belanja customer
  // format: catalog_item_id -> Map{ 'product': data, 'qty': int }
  final Map<int, Map<String, dynamic>> _cart = {};

  @override
  void initState() {
    super.initState();
    _fetchBusinessData();
  }

  Future<void> _fetchBusinessData() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        headers: {'Accept': 'application/json'},
      ));

      // Simulasi API Public yang telah kita buat di backend sebelumnya
      final response = await dio.get('/public/businesses/${widget.slug}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _businessData = response.data['data']['business'];
            _catalogItems = response.data['data']['catalog'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Bisnis tidak ditemukan.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat halaman bisnis.';
          _isLoading = false;
        });
      }
    }
  }

  void _addToCart(dynamic product) {
    setState(() {
      final id = product['id'] as int;
      if (_cart.containsKey(id)) {
        _cart[id]!['qty'] = (_cart[id]!['qty'] as int) + 1;
      } else {
        _cart[id] = {
          'product': product,
          'qty': 1,
        };
      }
    });
  }

  void _removeFromCart(int productId) {
    setState(() {
      if (_cart.containsKey(productId)) {
        final currentQty = _cart[productId]!['qty'] as int;
        if (currentQty > 1) {
          _cart[productId]!['qty'] = currentQty - 1;
        } else {
          _cart.remove(productId);
        }
      }
    });
  }

  int get _totalItems {
    int total = 0;
    for (var item in _cart.values) {
      total += item['qty'] as int;
    }
    return total;
  }

  num get _totalPrice {
    num total = 0;
    for (var item in _cart.values) {
      final product = item['product'];
      final qty = item['qty'] as int;
      total += (product['price'] * qty);
    }
    return total;
  }

  String _selectedPaymentMethod = 'cash'; // Default: cash or online

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Pesanan Anda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(child: Text('Keranjang masih kosong.'))
                        : ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final entry = _cart.entries.elementAt(index);
                              final id = entry.key;
                              final data = entry.value;
                              final product = data['product'];
                              final qty = data['qty'] as int;
                              
                              return ListTile(
                                title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('Rp ${product['price']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.info, color: AppTheme.primaryColor),
                                      onPressed: () {
                                        _removeFromCart(id);
                                        setModalState(() {});
                                      },
                                    ),
                                    Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    IconButton(
                                      icon: Icon(Icons.info, color: AppTheme.primaryColor),
                                      onPressed: () {
                                        _addToCart(product);
                                        setModalState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Metode Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                              value: _selectedPaymentMethod,
                              items: const [
                                DropdownMenuItem(value: 'cash', child: Text('Bayar di Kasir')),
                                DropdownMenuItem(value: 'online', child: Text('Bayar Online (QRIS/GoPay)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setModalState(() => _selectedPaymentMethod = val);
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 18)),
                            Text('Rp $_totalPrice', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _cart.isEmpty ? null : () => _submitOrder(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Pesan Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    ).whenComplete(() {
      setState(() {});
    });
  }

  Future<void> _submitOrder(BuildContext bottomSheetContext) async {
    Navigator.pop(bottomSheetContext); // Tutup bottom sheet
    
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
    );

    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        headers: {'Accept': 'application/json'},
      ));

      final itemsData = _cart.values.map((item) {
        return {
          'catalog_item_id': item['product']['id'],
          'quantity': item['qty'],
          'price': item['product']['price'],
        };
      }).toList();

      final response = await dio.post('/public/businesses/${widget.slug}/orders', data: {
        'table_number': widget.tableNumber,
        'customer_name': 'Pelanggan Meja ${widget.tableNumber ?? 'Takeaway'}',
        'items': itemsData,
        'total_amount': _totalPrice,
        'payment_method': _selectedPaymentMethod,
      });

      Navigator.pop(context); // Tutup loading dialog

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final paymentUrl = data['payment_url'];

        if (mounted) {
          setState(() {
            _cart.clear(); // Kosongkan keranjang
          });

          if (_selectedPaymentMethod == 'online' && paymentUrl != null) {
            // Simulasi buka Midtrans
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Membuka Pembayaran...'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Sistem akan mengarahkan Anda ke URL Midtrans berikut:'),
                    const SizedBox(height: 16),
                    Text(paymentUrl, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 12)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Simulasi webhook berhasil
                        dio.post('/public/payment/midtrans/callback', data: {
                          'order_id': data['invoice_number'],
                          'transaction_status': 'settlement'
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran Berhasil Disimulasikan!')));
                      },
                      child: const Text('Simulasi Bayar QRIS Sukses'),
                    )
                  ],
                ),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                icon: Icon(Icons.info, color: AppTheme.primaryColor),
                title: const Text('Pesanan Berhasil!'),
                content: const Text('Pesanan Anda sudah masuk ke Dapur/Kasir. Silakan bayar di kasir.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['message'] ?? 'Gagal memesan.'), backgroundColor: AppTheme.errorColor),
          );
        }
      }
    } on DioException catch (e) {
      Navigator.pop(context); // Tutup loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.response?.data['message'] ?? 'Network Error: ${e.message}'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Future<void> _showTakeQueueDialog() async {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ambil Antrean'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Silakan masukkan nama Anda untuk mengambil nomor urut antrean.'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Anda', border: OutlineInputBorder()),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(ctx);
              
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
              
              try {
                final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'));
                final response = await dio.post('/public/businesses/${widget.slug}/queue', data: {
                  'customer_name': nameController.text
                });
                
                if (mounted) Navigator.pop(context);
                
                if (response.data['success']) {
                  final qNum = response.data['data']['queue_number'];
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Sukses!'),
                        content: Text('Nomor Antrean Anda:\n\n$qNum', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                      )
                    );
                  }
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil antrean.')));
              }
            },
            child: const Text('Ambil Nomor')
          )
        ]
      )
    );
  }

  Future<void> _showBookingDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reservasi Tempat/Layanan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'No. WhatsApp', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) return;
              Navigator.pop(ctx);
              
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
              
              try {
                final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api'));
                final response = await dio.post('/public/businesses/${widget.slug}/booking', data: {
                  'customer_name': nameController.text,
                  'customer_phone': phoneController.text,
                  'booking_date': DateTime.now().toString().split(' ')[0], // Dummy today
                  'booking_time': '18:00', // Dummy time
                });
                
                if (mounted) Navigator.pop(context);
                
                if (response.data['success']) {
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Reservasi Berhasil'),
                        content: const Text('Reservasi Anda berhasil dibuat. Staf kami akan mengkonfirmasi via WhatsApp.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                      )
                    );
                  }
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat reservasi.')));
              }
            },
            child: const Text('Reservasi Sekarang')
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(_error, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
      );
    }

    final businessName = _businessData?['name'] ?? 'AntiRibet Merchant';
    final businessDesc = _businessData?['description'] ?? 'Toko digital terpercaya.';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(businessName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black45, blurRadius: 4)])),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.storefront, size: 80, color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tableNumber != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text('Meja Nomor: ${widget.tableNumber}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(businessDesc, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                  const SizedBox(height: 24),
                  
                  // Fitur Layanan (Antrean & Booking)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.people_alt),
                          label: const Text('Ambil Antrean'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showTakeQueueDialog(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.event_seat),
                          label: const Text('Reservasi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppTheme.accentColor),
                            ),
                          ),
                          onPressed: () => _showBookingDialog(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Daftar Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _catalogItems.isEmpty
              ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Katalog belum tersedia.'))))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _catalogItems[index];
                      final id = item['id'] as int;
                      final price = item['price'];
                      final name = item['name'];
                      final qtyInCart = _cart.containsKey(id) ? _cart[id]!['qty'] as int : 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.fastfood_outlined, color: Colors.grey),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('Rp $price', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              qtyInCart > 0
                                ? Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.info, color: AppTheme.primaryColor),
                                        onPressed: () => _removeFromCart(id),
                                      ),
                                      Text('$qtyInCart', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      IconButton(
                                        icon: Icon(Icons.info, color: AppTheme.primaryColor),
                                        onPressed: () => _addToCart(item),
                                      ),
                                    ],
                                  )
                                : ElevatedButton(
                                    onPressed: () => _addToCart(item),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                      foregroundColor: AppTheme.primaryColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Tambah'),
                                  ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _catalogItems.length,
                  ),
                ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Ruang untuk bottom bar
        ],
      ),
      bottomSheet: _totalItems > 0
        ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_totalItems item', style: const TextStyle(color: Colors.white70)),
                      Text('Rp $_totalPrice', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _showCartBottomSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Lihat Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          )
        : null,
    );
  }
}
