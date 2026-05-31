import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/auth_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';
import '../../../../core/components/v2_clickable_card.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  List<dynamic> _staffList = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/merchant/staff');
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _staffList = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat data staf.';
      });
    }
  }

  Future<void> _deleteStaff(int id) async {
    try {
      final dio = DioClient().dio;
      await dio.delete('/merchant/staff/$id');
      _fetchStaff();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Akses staf dihapus.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: V2Colors.errorRed,
        ));
      }
    } catch (e) {
      // Ignore
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
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
                      Text('Tambah Kasir / Staf', style: V2Typography.headingMd),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(color: V2Colors.divider, height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Login (Username)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password (min 6 karakter)'),
                  ),
                  const SizedBox(height: 32),
                  V2Button(
                    label: 'Berikan Akses Kasir',
                    isFullWidth: true,
                    size: V2ButtonSize.large,
                    isLoading: isSaving,
                    onPressed: () async {
                      if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) return;
                      setModalState(() => isSaving = true);
                      
                      try {
                        final dio = DioClient().dio;
                        await dio.post('/merchant/staff', data: {
                          'name': nameController.text,
                          'email': emailController.text,
                          'password': passwordController.text,
                        });
                        
                        if (mounted) {
                          Navigator.pop(context);
                          _fetchStaff();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Staf berhasil ditambahkan.', style: V2Typography.bodyMd.copyWith(color: Colors.white)),
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
        title: Text('Manajemen Kasir', style: V2Typography.headingMd),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchStaff),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: V2Colors.primaryBlue))
        : _error.isNotEmpty
          ? Center(child: Text(_error, style: V2Typography.bodyMd.copyWith(color: V2Colors.errorRed)))
          : _staffList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_off_outlined, size: 64, color: V2Colors.mutedText),
                    const SizedBox(height: 16),
                    Text('Belum ada staf', style: V2Typography.headingSm),
                    const SizedBox(height: 8),
                    Text('Beri akses kasir kepada pegawai Anda.', style: V2Typography.bodyMd),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _staffList.length,
                itemBuilder: (context, index) {
                  final staff = _staffList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: V2ClickableCard(
                      onTap: () {},
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: const BoxDecoration(
                              color: V2Colors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                staff['name'].substring(0, 1).toUpperCase(),
                                style: V2Typography.headingLg.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(staff['name'], style: V2Typography.labelLg),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 14, color: V2Colors.secondaryText),
                                    const SizedBox(width: 4),
                                    Text(staff['email'], style: V2Typography.bodySm.copyWith(color: V2Colors.secondaryText)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: V2Colors.errorRed),
                            onPressed: () => _deleteStaff(staff['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: V2Colors.primaryBlue,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text('Tambah Kasir', style: V2Typography.labelLg.copyWith(color: Colors.white)),
      ),
    );
  }
}
