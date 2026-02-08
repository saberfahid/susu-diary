import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/security_service.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _enableBiometrics = true;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await SecurityService.instance.isBiometricsAvailable();
    setState(() => _biometricsAvailable = available);
  }

  void _onNumberTap(String number) {
    HapticFeedback.lightImpact();
    
    if (_isConfirming) {
      if (_confirmPin.length < 4) {
        setState(() => _confirmPin += number);
        if (_confirmPin.length == 4) {
          _verifyPins();
        }
      }
    } else {
      if (_pin.length < 4) {
        setState(() => _pin += number);
        if (_pin.length == 4) {
          setState(() => _isConfirming = true);
        }
      }
    }
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    
    if (_isConfirming) {
      if (_confirmPin.isNotEmpty) {
        setState(() => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    }
  }

  Future<void> _verifyPins() async {
    if (_pin == _confirmPin) {
      await SecurityService.instance.setPin(_pin);
      if (_biometricsAvailable && _enableBiometrics) {
        await SecurityService.instance.setBiometricsEnabled(true);
      }
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    } else {
      // Show error
      HapticFeedback.heavyImpact();
      setState(() {
        _confirmPin = '';
        _isConfirming = false;
        _pin = '';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PINs do not match. Please try again.'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _skipPin() {
    Navigator.pushReplacementNamed(context, AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipPin,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppTheme.primaryColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 50,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    _isConfirming ? 'Confirm PIN' : 'Create PIN',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _isConfirming
                        ? 'Enter your PIN again to confirm'
                        : 'Set a 4-digit PIN to protect your diary',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final currentPin = _isConfirming ? _confirmPin : _pin;
                      final isFilled = index < currentPin.length;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Biometrics toggle
                  if (_biometricsAvailable && !_isConfirming)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          Icon(
                            Icons.fingerprint,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enable biometric unlock',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Switch(
                            value: _enableBiometrics,
                            onChanged: (value) {
                              setState(() => _enableBiometrics = value);
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Number pad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              child: Column(
                children: [
                  for (int row = 0; row < 4; row++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int col = 0; col < 3; col++)
                          _buildKeypadButton(row, col),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(int row, int col) {
    final numbers = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];
    
    final value = numbers[row][col];
    
    if (value.isEmpty) {
      return const SizedBox(width: 70, height: 70);
    }
    
    if (value == 'back') {
      return SizedBox(
        width: 70,
        height: 70,
        child: IconButton(
          onPressed: _onBackspace,
          icon: const Icon(Icons.backspace_outlined),
          iconSize: 28,
        ),
      );
    }
    
    return GestureDetector(
      onTap: () => _onNumberTap(value),
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
