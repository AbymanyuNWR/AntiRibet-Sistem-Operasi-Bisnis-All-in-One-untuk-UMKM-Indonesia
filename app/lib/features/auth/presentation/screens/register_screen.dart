import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/auth_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/v2_colors.dart';
import '../../../../core/theme/v2_typography.dart';
import '../../../../core/components/v2_buttons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final dio = DioClient().dio;

      final response = await dio.post('/auth/register', data: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _passwordController.text,
        'business_name': _businessNameController.text,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'] as String;
        final user = data['user'] as Map<String, dynamic>? ?? {};

        await _secureStorage.write(key: 'auth_token', value: token);
        AuthService.token = token;
        AuthService.userRole = data['role'] ?? user['role'] ?? 'merchant';
        AuthService.currentUser = user;

        if (mounted) {
          context.go('/dashboard');
        }
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Registrasi gagal.';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data['message'] ?? 'Network Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan tidak terduga.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2Colors.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: V2Colors.primaryText),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: V2Colors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10)),
                ],
                border: Border.all(color: V2Colors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Buat Akun Bisnis', style: V2Typography.display.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text('Mulai digitalisasi bisnis Anda dalam hitungan menit.', style: V2Typography.bodyLg.copyWith(color: V2Colors.secondaryText)),
                  const SizedBox(height: 32),
                  
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: V2Colors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: V2Colors.errorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: V2Colors.errorRed, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(_errorMessage, style: V2Typography.labelSm.copyWith(color: V2Colors.errorRed)),
                          ),
                        ],
                      ),
                    ),
                  
                  _buildInputLabel('Nama Lengkap Pemilik'),
                  _buildTextField(_nameController, Icons.person_outline, 'Sesuai KTP'),
                  
                  _buildInputLabel('Nama Bisnis / Toko'),
                  _buildTextField(_businessNameController, Icons.storefront_outlined, 'Cth: Kopi Senja'),
                  
                  _buildInputLabel('Email Aktif'),
                  _buildTextField(_emailController, Icons.email_outlined, 'Untuk login & notifikasi', isEmail: true),
                  
                  _buildInputLabel('Password'),
                  _buildTextField(_passwordController, Icons.lock_outline, 'Minimal 6 karakter', isPassword: true),
                  
                  const SizedBox(height: 32),
                  V2Button(
                    label: 'Daftar & Mulai Jualan',
                    size: V2ButtonSize.large,
                    isLoading: _isLoading,
                    onPressed: _register,
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ', style: V2Typography.bodyMd.copyWith(color: V2Colors.secondaryText)),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text('Masuk di sini', style: V2Typography.labelLg.copyWith(color: V2Colors.primaryBlue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(label, style: V2Typography.labelMd),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {bool isPassword = false, bool isEmail = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: V2Colors.secondaryText),
        filled: true,
        fillColor: V2Colors.pageBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: V2Colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: V2Colors.border),
        ),
      ),
    );
  }
}
