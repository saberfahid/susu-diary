import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/security_service.dart';
import '../../../core/services/database_service.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  int _attempts = 0;
  bool _isLocked = false;
  bool _isShaking = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _tryBiometrics();
  }

  Future<void> _tryBiometrics() async {
    final biometricsEnabled = await SecurityService.instance.isBiometricsEnabled();
    if (biometricsEnabled) {
      final success = await SecurityService.instance.authenticateWithBiometrics();
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    }
  }

  void _onNumberTap(String number) {
    if (_isLocked) return;
    
    HapticFeedback.lightImpact();
    
    if (_pin.length < 4) {
      setState(() => _pin += number);
      
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_isLocked) return;
    
    HapticFeedback.lightImpact();
    
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _verifyPin() async {
    final isValid = await SecurityService.instance.verifyPin(_pin);
    
    if (isValid) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    } else {
      _attempts++;
      HapticFeedback.heavyImpact();
      
      setState(() {
        _isShaking = true;
        _pin = '';
      });
      
      _shakeController.forward().then((_) {
        _shakeController.reset();
        setState(() => _isShaking = false);
      });
      
      if (_attempts >= 5) {
        setState(() => _isLocked = true);
        
        // Lock for 30 seconds
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted) {
            setState(() {
              _isLocked = false;
              _attempts = 0;
            });
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Too many attempts. Please wait 30 seconds.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showForgotPinDialog() async {
    final biometricsAvailable = await SecurityService.instance.isBiometricsAvailable();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Forgot PIN?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (biometricsAvailable) ...[
              const Text(
                'You can reset your PIN using biometric authentication (fingerprint/face).',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _resetPinWithBiometrics();
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Reset with Biometrics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Or you can erase all data and start fresh:',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ] else ...[
              const Text(
                'Since biometrics are not set up, the only way to recover is to erase all data and start fresh.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'This will permanently delete all diary entries, recordings, and settings.',
                style: TextStyle(fontSize: 13, color: Colors.red.shade400),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEraseDataConfirmation();
                },
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Erase All Data', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPinWithBiometrics() async {
    final success = await SecurityService.instance.authenticateWithBiometrics(
      skipEnabledCheck: true,
    );
    
    if (!success || !mounted) return;
    
    // Show new PIN dialog
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_open_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Set New PIN'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Identity verified! Enter your new PIN.'),
            const SizedBox(height: 16),
            TextField(
              controller: newPinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New PIN',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPinController.text.length < 4) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('PIN must be at least 4 digits')),
                );
                return;
              }
              if (newPinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('PINs do not match')),
                );
                return;
              }
              
              await SecurityService.instance.setPin(newPinController.text);
              if (!mounted) return;
              Navigator.pop(dialogContext);
              Navigator.pushReplacementNamed(context, AppRouter.home);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('PIN reset successfully!'),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  void _showEraseDataConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Are you sure?'),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL your data including diary entries, voice recordings, chat history, and settings.\n\nThis action CANNOT be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Delete all data
              await DatabaseService.instance.deleteAllData();
              await SecurityService.instance.clearAllSecureData();
              
              if (!mounted) return;
              Navigator.pop(dialogContext);
              
              // Navigate to onboarding/setup
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.onboarding,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Erase Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                          color: _isLocked 
                              ? Colors.red.withOpacity(0.3)
                              : AppTheme.primaryColor.withOpacity(0.3),
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
                            color: _isLocked
                                ? Colors.red.withOpacity(0.1)
                                : AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            _isLocked ? Icons.lock_clock : Icons.lock_outline_rounded,
                            size: 50,
                            color: _isLocked ? Colors.red : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    _isLocked ? 'Locked' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isLocked ? Colors.red : null,
                        ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _isLocked
                        ? 'Please wait before trying again'
                        : 'Enter your PIN to unlock',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // PIN dots with shake animation
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final sineValue = _isShaking
                          ? 10 * (0.5 - (0.5 - _shakeController.value).abs()) *
                              ((_shakeController.value * 4 * 3.14159).abs() % 2 == 0 ? 1 : -1)
                          : 0.0;
                      
                      return Transform.translate(
                        offset: Offset(sineValue, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _pin.length;
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled
                                ? (_isShaking ? Colors.red : AppTheme.primaryColor)
                                : Colors.transparent,
                            border: Border.all(
                              color: _isShaking
                                  ? Colors.red
                                  : (_isLocked ? Colors.grey : AppTheme.primaryColor),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Biometrics button
                  FutureBuilder<bool>(
                    future: SecurityService.instance.isBiometricsEnabled(),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return TextButton.icon(
                          onPressed: _isLocked ? null : _tryBiometrics,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Use Biometrics'),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Forgot PIN button
                  TextButton(
                    onPressed: _isLocked ? null : _showForgotPinDialog,
                    child: Text(
                      'Forgot PIN?',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
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
          onPressed: _isLocked ? null : _onBackspace,
          icon: Icon(
            Icons.backspace_outlined,
            color: _isLocked ? Colors.grey : null,
          ),
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
          color: _isLocked ? Colors.grey.shade200 : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: _isLocked ? Colors.grey : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}
