import 'dart:io';

void main() {
  final filesToFix = [
    r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\public_site_screen.dart',
    r'd:\antiribet.com\app\lib\features\admin\presentation\screens\admin_dashboard_screen.dart'
  ];

  for (final filepath in filesToFix) {
    final file = File(filepath);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      
      content = content.replaceAll('icon: \\1,', 'icon: Icon(Icons.info, color: AppTheme.primaryColor),');
      content = content.replaceAll('style: \\1)', 'style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))');
      content = content.replaceAll('builder: (context) => \\1),', 'builder: (context) => Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))),');
      content = content.replaceAll('child: \\1,', 'child: Icon(Icons.info, color: AppTheme.primaryColor),');
      content = content.replaceAll(RegExp(r'^\s*\\1,$', multiLine: true), '                          Icon(Icons.info, color: AppTheme.primaryColor),');
      
      file.writeAsStringSync(content);
    }
  }
  print("Repaired backreferences!");
}
