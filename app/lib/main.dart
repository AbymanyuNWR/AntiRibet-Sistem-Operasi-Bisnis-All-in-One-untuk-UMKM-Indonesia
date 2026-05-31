import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app/router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/network/auth_service.dart';
import 'core/theme/v2_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore token from SecureStorage on startup
  const secureStorage = FlutterSecureStorage();
  final storedToken = await secureStorage.read(key: 'auth_token');
  if (storedToken != null) {
    AuthService.token = storedToken;
  }

  // Saat token expired (401), redirect ke halaman login
  AuthService.onUnauthorized = () async {
    await secureStorage.delete(key: 'auth_token');
    appRouter.go('/login');
  };

  runApp(const AntiribetApp());
}

class AntiribetApp extends StatelessWidget {
  const AntiribetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AntiRibet',
      debugShowCheckedModeBanner: false,
      theme: V2Theme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
