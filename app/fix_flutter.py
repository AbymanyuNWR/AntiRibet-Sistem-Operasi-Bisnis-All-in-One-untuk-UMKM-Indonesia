import os
import re

files_to_fix = [
    r'd:\antiribet.com\app\lib\features\printer\presentation\screens\printer_settings_screen.dart',
    r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\public_site_screen.dart',
    r'd:\antiribet.com\app\lib\features\business_site\presentation\screens\onboarding_wizard_screen.dart',
    r'd:\antiribet.com\app\lib\features\admin\presentation\screens\admin_dashboard_screen.dart'
]

for filepath in files_to_fix:
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add import for AppTheme if not exists
        if 'import \'../../../../app/theme.dart\';' not in content:
            content = content.replace('import \'package:flutter/material.dart\';', 
                                      'import \'package:flutter/material.dart\';\nimport \'../../../../app/theme.dart\';')
        
        # Remove invalid const keywords causing errors
        content = re.sub(r'const\s+(SnackBar\([^)]*backgroundColor:\s*AppTheme\.[^)]+\))', r'\1', content)
        content = re.sub(r'const\s+(TextStyle\([^)]*color:\s*AppTheme\.[^)]+\))', r'\1', content)
        content = re.sub(r'const\s+(Icon\([^)]*color:\s*AppTheme\.[^)]+\))', r'\1', content)
        content = re.sub(r'const\s+(Center\([^)]*color:\s*AppTheme\.[^)]+\))', r'\1', content)
        content = re.sub(r'const\s+(BoxShadow\([^)]*color:\s*AppTheme\.[^)]+\))', r'\1', content)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

print("Fixed AppTheme and const errors!")
