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

  // 1. queue_monitor_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\queue\presentation\screens\queue_monitor_screen.dart', {
    '  State<QueueMonitorScreen> createState() => _QueueMonitorScreenState();\n}\n\n  Timer? _timer;': '  State<QueueMonitorScreen> createState() => _QueueMonitorScreenState();\n}\n\nclass _QueueMonitorScreenState extends State<QueueMonitorScreen> {\n  Timer? _timer;',
    '  State<QueueMonitorScreen> createState() => _QueueMonitorScreenState();\n}\n  Timer? _timer;': '  State<QueueMonitorScreen> createState() => _QueueMonitorScreenState();\n}\n\nclass _QueueMonitorScreenState extends State<QueueMonitorScreen> {\n  Timer? _timer;'
  });

  // 2. onboarding_wizard_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\onboarding_wizard_screen.dart', {
    "import '../../../app/theme.dart';": "",
  });

  // 3. accounting_screen.dart
  replaceInFile(r'd:\antiribet.com\app\lib\features\reports\presentation\screens\accounting_screen.dart', {
    'margin: const EdgeInsets.only(bottom: 16),': '',
  });

  print('Fix 3 applied!');
}
