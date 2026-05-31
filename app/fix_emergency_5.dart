import 'dart:io';

void main() {
  void replaceInFile(String path, Map<String, String> replacements) {
    final file = File(path);
    if (!file.existsSync()) return;
    var content = file.readAsStringSync();
    replacements.forEach((key, value) {
      content = content.replaceAll(key, value);
    });
    file.writeAsStringSync(content);
  }

  // 1. Fix pos_screen.dart
  final posFile = File(r'd:\antiribet.com\app\lib\features\pos\presentation\screens\pos_screen.dart');
  if (posFile.existsSync()) {
    var content = posFile.readAsStringSync();
    // Fix missing state class declaration
    if (!content.contains('class _PosScreenState extends State<PosScreen> {')) {
      content = content.replaceAll(
        '  State<PosScreen> createState() => _PosScreenState();\n}\n\n  List<dynamic> _pendingOrders', 
        '  State<PosScreen> createState() => _PosScreenState();\n}\n\nclass _PosScreenState extends State<PosScreen> {\n  List<dynamic> _pendingOrders'
      );
    }
    // Fix missing _fetchPendingCount method signature
    if (!content.contains('Future<void> _fetchPendingCount() async {')) {
      content = content.replaceAll(
        '  }\n    final count = await SyncService().getPendingCount();\n    if (mounted) {',
        '  }\n\n  Future<void> _fetchPendingCount() async {\n    final count = await SyncService().getPendingCount();\n    if (mounted) {'
      );
    }
    posFile.writeAsStringSync(content);
  }

  // 2. Fix v2_theme.dart
  replaceInFile(r'd:\antiribet.com\app\lib\core\theme\v2_theme.dart', {
    'cardTheme: CardTheme(': 'cardTheme: CardThemeData(',
  });

  // 3. Fix printer_settings_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\printer\presentation\screens\printer_settings_screen.dart', {
    "import '../../../app/theme.dart';": "import 'package:antiribet/app/theme.dart';",
  });

  // 4. Fix public_site_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\public_site_screen.dart', {
    "import '../../../app/theme.dart';": "import 'package:antiribet/app/theme.dart';",
  });

  // 5. Fix admin_dashboard_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\admin\presentation\screens\admin_dashboard_screen.dart', {
    "import '../../../app/theme.dart';": "import 'package:antiribet/app/theme.dart';",
  });
  
  print("Fix 5 completed!");
}
