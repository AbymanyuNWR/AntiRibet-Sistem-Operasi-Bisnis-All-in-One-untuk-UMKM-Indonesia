import 'dart:io';

void main() {
  final file = File(r'd:\antiribet.com\app\lib\features\dashboard\presentation\screens\dashboard_screen.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    
    // Fix ModuleCard layout to prevent bottom overflow
    content = content.replaceAll(
      '      width: 140,\n      height: 140,\n      child: V2ClickableCard(\n        onTap: onTap,\n        padding: const EdgeInsets.all(20),',
      '      width: 140,\n      height: 160,\n      child: V2ClickableCard(\n        onTap: onTap,\n        padding: const EdgeInsets.all(12),'
    );
    
    file.writeAsStringSync(content);
    print('Fixed dashboard layout overflow!');
  } else {
    print('File not found');
  }
}
