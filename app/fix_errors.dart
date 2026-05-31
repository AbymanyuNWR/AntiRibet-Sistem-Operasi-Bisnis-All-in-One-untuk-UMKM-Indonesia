import 'dart:io';

void main() {
  // Fix platform_admin_screen.dart
  final platformFile = File(r'd:\antiribet.com\app\lib\features\platform\presentation\screens\platform_admin_screen.dart');
  if (platformFile.existsSync()) {
    var content = platformFile.readAsStringSync();
    content = content.replaceAll('variant: V2ButtonVariant.outline', 'variant: V2ButtonVariant.secondary');
    content = content.replaceAll('margin: const EdgeInsets.only(bottom: 12),', '');
    platformFile.writeAsStringSync(content);
  }

  // Fix supply_chain_screen.dart
  final supplyFile = File(r'd:\antiribet.com\app\lib\features\supply\presentation\screens\supply_chain_screen.dart');
  if (supplyFile.existsSync()) {
    var content = supplyFile.readAsStringSync();
    content = content.replaceAll('margin: const EdgeInsets.only(bottom: 16),', '');
    supplyFile.writeAsStringSync(content);
  }

  // Fix public_site_screen.dart
  final publicFile = File(r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\public_site_screen.dart');
  if (publicFile.existsSync()) {
    var content = publicFile.readAsStringSync();
    content = content.replaceAll('builder: (context) => Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))),', 
                                 'builder: (context) => Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),');
    publicFile.writeAsStringSync(content);
  }

  // Fix theme.dart
  final themeFile = File(r'd:\antiribet.com\app\lib\app\theme.dart');
  if (themeFile.existsSync()) {
    var content = themeFile.readAsStringSync();
    content = content.replaceAll('cardTheme: CardTheme(', 'cardTheme: const CardTheme(');
    content = content.replaceAll('CardThemeData', 'CardTheme');
    // Just remove cardTheme entirely to be safe
    content = content.replaceAll(RegExp(r'cardTheme:\s*CardTheme\([^)]*\),'), '');
    themeFile.writeAsStringSync(content);
  }

  print("Repaired!");
}
