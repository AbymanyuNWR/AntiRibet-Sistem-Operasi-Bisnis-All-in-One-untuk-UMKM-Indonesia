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

  // 1. theme.dart - remove cardTheme completely
  final themePath = r'd:\antiribet.com\app\lib\app\theme.dart';
  final themeFile = File(themePath);
  if (themeFile.existsSync()) {
    var content = themeFile.readAsStringSync();
    // find cardTheme: CardTheme( ... ), and remove it
    // Because it spans multiple lines, we'll use RegExp
    content = content.replaceAll(RegExp(r'cardTheme:\s*const\s*CardTheme\([^)]*\),'), '');
    content = content.replaceAll(RegExp(r'cardTheme:\s*CardTheme\([^)]*\),'), '');
    themeFile.writeAsStringSync(content);
  }

  // 2. delivery_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\delivery\presentation\screens\delivery_screen.dart', {
    'variant: V2ButtonVariant.success': 'variant: V2ButtonVariant.primary',
    'margin: const EdgeInsets.only(bottom: 12),': '',
  });

  // 3. marketing_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\marketing\presentation\screens\marketing_screen.dart', {
    'V2Colors.surfaceLight': 'Colors.white',
    'V2Colors.borderLight': 'Colors.grey.shade300',
    'V2Colors.backgroundLight': 'Colors.grey.shade50',
    'margin: const EdgeInsets.only(bottom: 12),': '',
  });

  // 4. hq_dashboard_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\hq\presentation\screens\hq_dashboard_screen.dart', {
    'margin: const EdgeInsets.only(bottom: 12),': '',
  });

  print('Final emergency fixes applied!');
}
