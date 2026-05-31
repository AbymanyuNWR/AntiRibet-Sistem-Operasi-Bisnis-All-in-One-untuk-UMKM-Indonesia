import 'dart:io';

void main() {
  final file = File(r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\onboarding_wizard_screen.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll("import '../../../../app/theme.dart';", "import 'package:antiribet/app/theme.dart';");
    file.writeAsStringSync(content);
  }
  
  final qFile = File(r'd:\antiribet.com\app\lib\features\queue\presentation\screens\queue_monitor_screen.dart');
  if (qFile.existsSync()) {
    var content = qFile.readAsStringSync();
    // Fix the queue monitor screen imports just in case
    content = content.replaceAll("import '../../../../core/", "import 'package:antiribet/core/");
    qFile.writeAsStringSync(content);
  }

  print("Fixed imports to package:");
}
