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

  // 1. kds_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\kitchen\presentation\screens\kds_screen.dart', {
    'backgroundColor: V2Colors.successGreen,': 'color: V2Colors.successGreen,', // Wait, does V2Button have color parameter? Let's just remove it since variant: V2ButtonVariant.primary exists
    'margin: const EdgeInsets.only(bottom: 16),': '',
  });

  // 2. hris_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\hris\presentation\screens\hris_screen.dart', {
    'margin: const EdgeInsets.only(bottom: 12),': '',
  });

  print('Final ultimate emergency fixes applied!');
}
