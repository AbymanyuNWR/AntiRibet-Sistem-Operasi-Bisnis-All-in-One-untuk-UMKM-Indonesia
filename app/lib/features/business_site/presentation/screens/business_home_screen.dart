import 'package:flutter/material.dart';

class BusinessHomeScreen extends StatelessWidget {
  final String slug;
  final String? table;

  const BusinessHomeScreen({super.key, required this.slug, this.table});

  @override
  Widget build(BuildContext context) {
    // Pada real app, fetch /api/public/businesses/{slug} di sini
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Mini Website: $slug'),
              background: Container(color: Colors.teal), // Dummy hero image
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (table != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.table_restaurant, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Text('Anda berada di Meja $table', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text('Selamat datang di halaman pemesanan kami.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  const Text('Menu Tersedia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Dummy catalog
                return ListTile(
                  leading: Container(width: 60, height: 60, color: Colors.grey[300]),
                  title: Text('Item Menu $index'),
                  subtitle: const Text('Rp 20.000'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // context.read<CustomerCartBloc>().add(AddItemToCustomerCart(...))
                    },
                    child: const Text('Tambah'),
                  ),
                );
              },
              childCount: 5,
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
          onPressed: () {
            // go to /b/slug/checkout
          },
          child: const Text('Lihat Keranjang (0)'),
        ),
      ),
    );
  }
}
