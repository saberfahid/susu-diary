import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/security_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _biometricsEnabled = false;
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final biometrics = await SecurityService.instance.isBiometricsEnabled();
    
    setState(() {
      _biometricsEnabled = biometrics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance')
                .animate()
                .fadeIn()
                .slideX(begin: -0.1, end: 0),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Toggle dark theme',
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                  // TODO: Implement theme switching with provider
                },
              ),
            ]).animate().fadeIn(delay: 50.ms),

            const SizedBox(height: 24),

            // Security Section
            _buildSectionHeader('Security')
                .animate()
                .fadeIn(delay: 100.ms)
                .slideX(begin: -0.1, end: 0),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.pin_rounded,
                title: 'Change PIN',
                subtitle: 'Update your security PIN',
                onTap: _showChangePinDialog,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Unlock',
                subtitle: 'Use fingerprint or face ID',
                value: _biometricsEnabled,
                onChanged: (value) async {
                  if (value) {
                    final success = await SecurityService.instance.authenticateWithBiometrics();
                    if (success) {
                      await SecurityService.instance.setBiometricsEnabled(true);
                      setState(() => _biometricsEnabled = true);
                    }
                  } else {
                    await SecurityService.instance.setBiometricsEnabled(false);
                    setState(() => _biometricsEnabled = false);
                  }
                },
              ),
            ]).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 24),

            // AI Status Section (no configuration needed - embedded key)
            _buildSectionHeader('AI Assistant')
                .animate()
                .fadeIn(delay: 200.ms)
                .slideX(begin: -0.1, end: 0),
            _buildSettingsCard([
              _buildInfoTile(
                icon: Icons.auto_awesome,
                title: 'AI Powered',
                subtitle: 'Smart writing & mood analysis enabled',
              ),
              const Divider(height: 1),
              _buildUsageTile(),
            ]).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications')
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.1, end: 0),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_rounded,
                title: 'Daily Reminder',
                subtitle: 'Get reminded to write',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  // TODO: Schedule/cancel notifications
                },
              ),
              if (_notificationsEnabled) ...[
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.access_time_rounded,
                  title: 'Reminder Time',
                  subtitle: _reminderTime.format(context),
                  onTap: _showTimePickerDialog,
                ),
              ],
            ]).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: 24),

            // Data Section
            _buildSectionHeader('Data & Privacy')
                .animate()
                .fadeIn(delay: 400.ms)
                .slideX(begin: -0.1, end: 0),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.download_rounded,
                title: 'Export Data',
                subtitle: 'Download your diary entries',
                onTap: _exportData,
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.delete_forever_rounded,
                title: 'Delete All Data',
                subtitle: 'Permanently remove all entries',
                titleColor: Colors.red,
                onTap: _showDeleteDataDialog,
              ),
            ]).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About')
                .animate()
                .fadeIn(delay: 500.ms)
                .slideX(begin: -0.1, end: 0),
            _buildSettingsCard([
              _buildInfoTile(
                icon: Icons.info_outline_rounded,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
            ]).animate().fadeIn(delay: 550.ms),

            const SizedBox(height: 40),

            // App info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.auto_fix_high_rounded,
                          size: 32,
                          color: AppTheme.primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Susu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Your AI Diary',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppTheme.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: titleColor ?? AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildUsageTile() {
    final aiService = AIService.instance;
    final usedK = (aiService.tokensUsedToday / 1000).toStringAsFixed(1);
    final remainingK = (aiService.tokensRemaining / 1000).toStringAsFixed(1);
    final percentage = aiService.usagePercentage;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.data_usage_rounded, color: AppTheme.secondaryColor, size: 22),
      ),
      title: const Text('Daily Usage', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('${usedK}K / 500K tokens (${remainingK}K remaining)', 
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 80 ? Colors.red : AppTheme.secondaryColor,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Resets at midnight (Beijing Time)',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                counterText: '',
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
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New PINs do not match')),
                );
                return;
              }

              final success = await SecurityService.instance.changePin(
                currentPinController.text,
                newPinController.text,
              );

              if (!mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'PIN changed successfully' : 'Incorrect current PIN',
                  ),
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (time != null) {
      setState(() => _reminderTime = time);
      // TODO: Schedule notification
    }
  }

  Future<void> _exportData() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Exporting data...'),
          ],
        ),
      ),
    );

    try {
      final entries = await DatabaseService.instance.getAllEntries();
      
      // Create JSON export
      final exportData = entries.map((e) => e.toMap()).toList();
      
      // TODO: Actually save to file or share
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${entries.length} entries')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your diary entries, chat history, and mood data. This action cannot be undone.\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService.instance.deleteAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
