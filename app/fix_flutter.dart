import 'dart:io';

void main() {
  final filesToFix = [
    r'd:\antiribet.com\app\lib\features\printer\presentation\screens\printer_settings_screen.dart',
    r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\public_site_screen.dart',
    r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\onboarding_wizard_screen.dart',
    r'd:\antiribet.com\app\lib\features\admin\presentation\screens\admin_dashboard_screen.dart'
  ];

  for (final filepath in filesToFix) {
    final file = File(filepath);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      
      if (!content.contains("import '../../../../app/theme.dart';")) {
        content = content.replaceAll(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\nimport '../../../../app/theme.dart';");
      }
      
      content = content.replaceAll(RegExp(r'const\s+(SnackBar\([^)]*backgroundColor:\s*AppTheme\.[^)]+\))'), r'\1');
      content = content.replaceAll(RegExp(r'const\s+(TextStyle\([^)]*color:\s*AppTheme\.[^)]+\))'), r'\1');
      content = content.replaceAll(RegExp(r'const\s+(Icon\([^)]*color:\s*AppTheme\.[^)]+\))'), r'\1');
      content = content.replaceAll(RegExp(r'const\s+(Center\([^)]*color:\s*AppTheme\.[^)]+\))'), r'\1');
      content = content.replaceAll(RegExp(r'const\s+(BoxShadow\([^)]*color:\s*AppTheme\.[^)]+\))'), r'\1');
      
      file.writeAsStringSync(content);
    }
  }
  print("Fixed!");
}
