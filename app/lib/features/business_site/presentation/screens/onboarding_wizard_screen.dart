import 'package:flutter/material.dart';
import 'package:antiribet/app/theme.dart';

import 'package:go_router/go_router.dart';


class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  int _currentStep = 0;
  String _selectedCategory = '';
  final _businessNameController = TextEditingController();
  final _businessSlugController = TextEditingController();

  final List<String> _categories = [
    'F&B (Coffee Shop, Resto)',
    'Beauty (Salon, Barbershop)',
    'Retail (Toko Pakaian, Minimarket)',
    'Jasa (Laundry, Bengkel)',
    'Rental & Booking'
  ];

  void _finishSetup() async {
    // Simulasi memanggil BusinessSetupService API di backend
    // POST /api/merchant/business/setup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Setup Selesai! Anda mendapatkan Kuota Trial 50 Transaksi.'),
        backgroundColor: AppTheme.successColor,
      )
    );
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Bisnis Anda'),
        automaticallyImplyLeading: false,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            _finishSetup();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(isLastStep ? 'Selesai & Masuk Dashboard' : 'Selanjutnya'),
                  ),
                ),
                if (_currentStep > 0) const SizedBox(width: 16),
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Kembali'),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Pilih Kategori Bisnis'),
            content: Column(
              children: _categories.map((cat) => RadioListTile(
                title: Text(cat),
                value: cat,
                groupValue: _selectedCategory,
                activeColor: AppTheme.primaryColor,
                onChanged: (val) {
                  setState(() => _selectedCategory = val.toString());
                },
              )).toList(),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Informasi Profil'),
            content: Column(
              children: [
                TextField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Bisnis',
                    hintText: 'Misal: Kopi Senja',
                  ),
                  onChanged: (val) {
                    _businessSlugController.text = val.toLowerCase().replaceAll(' ', '-');
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _businessSlugController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Mini Website',
                    prefixText: 'antiribet.id/ ',
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Finalisasi'),
            content: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: AppTheme.successColor),
                    const SizedBox(height: 16),
                    const Text('Bisnis Anda siap diorbitkan!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Anda akan mendapatkan dompet digital otomatis dan 50 kuota transaksi percobaan.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
