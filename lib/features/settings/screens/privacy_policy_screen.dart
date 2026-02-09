import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: February 8, 2026',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 24),

            _buildSection(
              context,
              '1. Introduction',
              'Welcome to Susu — Your AI Diary. We are committed to protecting your privacy and personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.\n\nBy using Susu, you agree to the terms of this Privacy Policy. If you do not agree, please do not use the App.',
            ),

            _buildSection(
              context,
              '2. Information We Collect',
              null,
              subsections: [
                _SubSection('What You Provide', [
                  '📝 Diary Entries — Text, mood selections, and notes you write',
                  '🎭 Mood Data — Your mood selections and emotional tracking',
                  '🔐 PIN/Security Data — Stored securely on device only',
                  '🎤 Voice Notes — Voice diary recordings stored locally',
                  '📷 Images — Photos attached to entries (stored locally)',
                ]),
                _SubSection('What We DO NOT Collect', [
                  '❌ No name, email, or phone number',
                  '❌ No location data',
                  '❌ No data sold to third parties',
                  '❌ No tracking across other apps',
                ]),
              ],
            ),

            _buildSection(
              context,
              '3. How Your Data is Stored',
              null,
              bullets: [
                '💾 All diary entries, mood data, and personal content are stored locally on your device. We do not upload your diary content to any server.',
                '🔒 Sensitive data is encrypted using industry-standard encryption methods.',
                '🔑 Your app is protected by a PIN code and optional biometric authentication.',
              ],
            ),

            _buildSection(
              context,
              '4. AI Features',
              'Susu includes AI-powered features such as chat companion and text analysis:',
              bullets: [
                'When you interact with the AI chat feature, your messages may be sent to our AI service provider for processing.',
                'AI conversations are not stored on our servers after processing.',
                'We do not use your diary entries or AI conversations for training AI models.',
                'You can use the App without the AI features if you prefer.',
              ],
            ),

            _buildSection(
              context,
              '5. Third-Party Services',
              'The App may use the following third-party services:',
              bullets: [
                'Google Play Services — For app distribution and updates.',
                'Speech Recognition — Uses your device\'s built-in speech recognition.',
                'Text-to-Speech — Uses your device\'s built-in TTS engine.',
              ],
            ),

            _buildSection(
              context,
              '6. Data Security',
              'We take reasonable measures to protect your data:',
              bullets: [
                'All sensitive data is encrypted on your device.',
                'PIN and biometric lock prevent unauthorized access.',
                'We use secure storage mechanisms provided by the operating system.',
                'No diary content is transmitted over the internet (except when using AI chat).',
              ],
            ),

            _buildSection(
              context,
              '7. Children\'s Privacy',
              'Susu is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13.',
            ),

            _buildSection(
              context,
              '8. Your Rights',
              'You have the right to:',
              bullets: [
                '👁️ Access — View all your data within the App at any time.',
                '🗑️ Delete — Delete any or all of your diary entries and data.',
                '📱 Uninstall — Uninstalling removes all locally stored data.',
                '⚙️ Opt-out — Use the diary without AI features.',
              ],
            ),

            _buildSection(
              context,
              '9. Data Retention',
              'Since your data is stored locally on your device:',
              bullets: [
                'Your data remains as long as the App is installed.',
                'Uninstalling the App permanently deletes all data.',
                'We do not retain any copies of your data on our servers.',
              ],
            ),

            _buildSection(
              context,
              '10. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting a notice within the App. Your continued use of the App after changes are posted constitutes your acceptance of the updated policy.',
            ),

            _buildSection(
              context,
              '11. Contact Us',
              'If you have any questions or concerns about this Privacy Policy, please contact us at:',
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'Susu — Your AI Diary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('support@susu-diary.com'),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String? description, {
    List<String>? bullets,
    List<_SubSection>? subsections,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          if (description != null)
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          if (subsections != null)
            ...subsections.map((sub) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...sub.items.map((item) => Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 4),
                            child: Text(
                              item,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          )),
                    ],
                  ),
                )),
          if (bullets != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: bullets
                    .map((b) => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: Colors.grey.shade600)),
                              Expanded(
                                child: Text(
                                  b,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubSection {
  final String title;
  final List<String> items;
  _SubSection(this.title, this.items);
}
