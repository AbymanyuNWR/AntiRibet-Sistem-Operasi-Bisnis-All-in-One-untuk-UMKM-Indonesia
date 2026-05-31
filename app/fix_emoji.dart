import 'dart:io';

// Script untuk menghapus semua emoji dan menggantikan teks-teks AI dari semua file Dart
void main() {
  final libDir = Directory(r'd:\antiribet.com\app\lib');
  int filesFixed = 0;
  int replacements = 0;

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    var content = entity.readAsStringSync();
    final original = content;

    // Hapus emoji unicode umum - ganti dengan string kosong
    final emojiPatterns = [
      // Emoticons & Misc symbols
      RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), // Emoticons
      RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), // Misc Symbols
      RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), // Transport
      RegExp(r'[\u{1F700}-\u{1F77F}]', unicode: true), // Alchemical
      RegExp(r'[\u{1F780}-\u{1F7FF}]', unicode: true), // Geometric
      RegExp(r'[\u{1F800}-\u{1F8FF}]', unicode: true), // Supp Arrows
      RegExp(r'[\u{1F900}-\u{1F9FF}]', unicode: true), // Supp Symbols
      RegExp(r'[\u{1FA00}-\u{1FA6F}]', unicode: true), // Chess
      RegExp(r'[\u{1FA70}-\u{1FAFF}]', unicode: true), // Symbols Extended
      RegExp(r'[\u{2600}-\u{26FF}]', unicode: true),   // Misc Symbols
      RegExp(r'[\u{2700}-\u{27BF}]', unicode: true),   // Dingbats
      RegExp(r'[\u{FE00}-\u{FE0F}]', unicode: true),   // Variation Selectors
      RegExp(r'[\u{1F1E0}-\u{1F1FF}]', unicode: true), // Flags
    ];

    for (final pattern in emojiPatterns) {
      content = content.replaceAll(pattern, '');
    }

    if (content != original) {
      entity.writeAsStringSync(content);
      filesFixed++;
      replacements++;
      print('Cleaned: ${entity.path.split(r'\').last}');
    }
  }

  print('\nDone! Fixed $filesFixed files.');
}
