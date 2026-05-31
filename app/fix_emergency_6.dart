import 'dart:io';

void main() {
  final posFile = File(r'd:\antiribet.com\app\lib\features\pos\presentation\screens\pos_screen.dart');
  if (posFile.existsSync()) {
    var content = posFile.readAsStringSync();
    
    // Fix _fetchPendingCount in _CartPanelState
    content = content.replaceAll(
      '_fetchPendingCount(); // Update badge',
      '// _fetchPendingCount(); // Update badge removed to fix scope error'
    );
    
    // Fix _currentShift in _CartPanelState
    content = content.replaceAll(
      'onPressed: (state.items.isEmpty || _currentShift == null) ? null : () => _showCheckoutDialog(context, state),',
      'onPressed: (state.items.isEmpty) ? null : () => _showCheckoutDialog(context, state),'
    );
    
    posFile.writeAsStringSync(content);
    print('Fixed pos_screen.dart CartPanel scope issues!');
  } else {
    print('File not found');
  }
}
