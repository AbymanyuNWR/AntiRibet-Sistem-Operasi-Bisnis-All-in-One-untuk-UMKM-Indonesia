import 'package:flutter/material.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Staf & Akses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Buka dialog tambah staf
              _showAddStaffDialog(context);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStaffCard('Budi (Owner)', 'Pemilik Bisnis', Colors.purple),
          _buildStaffCard('Siti (Kasir)', 'Kasir Utama', Colors.blue),
          _buildStaffCard('Agus (Dapur)', 'Monitor Antrean', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStaffCard(String name, String role, Color roleColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: roleColor.withOpacity(0.2), child: Icon(Icons.person, color: roleColor)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Role: $role'),
        trailing: const Icon(Icons.settings),
        onTap: () {
          // Edit staff
        },
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Staf Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: const InputDecoration(labelText: 'Nama Lengkap')),
              TextField(decoration: const InputDecoration(labelText: 'Email Login')),
              TextField(decoration: const InputDecoration(labelText: 'Password Sementara')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Pilih Role Akses'),
                items: const [
                  DropdownMenuItem(value: 'cashier', child: Text('Kasir (POS)')),
                  DropdownMenuItem(value: 'kitchen', child: Text('Dapur (Monitor Antrean)')),
                ],
                onChanged: (val) {},
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                // TODO: Panggil API /api/merchant/staff
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }
}
