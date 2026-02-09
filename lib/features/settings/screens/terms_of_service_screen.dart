import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                    AppTheme.secondaryColor.withOpacity(0.1),
                    AppTheme.accentColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    'Terms of Service',
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
              '1. Acceptance of Terms',
              'By downloading, installing, or using Susu — Your AI Diary ("App"), you agree to be bound by these Terms of Service. If you do not agree to these Terms, please do not use the App.',
            ),

            _buildSection(
              context,
              '2. Description of Service',
              'Susu is a personal diary and mood tracking application with AI-powered features. The App allows you to:',
              bullets: [
                '📝 Write and manage personal diary entries',
                '🎭 Track your daily mood and emotions',
                '📊 View mood analytics and patterns over time',
                '🤖 Chat with an AI companion for emotional support',
                '🎤 Record voice diary entries',
                '🔐 Secure your diary with PIN and biometric authentication',
              ],
            ),

            _buildSection(
              context,
              '3. User Eligibility',
              'You must be at least 13 years of age to use this App. By using the App, you represent and warrant that you are at least 13 years old. If you are under 18, you should review these Terms with a parent or guardian.',
            ),

            _buildSection(
              context,
              '4. User Account and Security',
              null,
              bullets: [
                'You are responsible for maintaining the confidentiality of your PIN code.',
                'You are responsible for all activities that occur under your app access.',
                'You should set a strong PIN and enable biometric authentication for added security.',
                'We are not responsible for any loss of data due to device failure, loss, or theft.',
              ],
            ),

            _buildSection(
              context,
              '5. User Content',
              null,
              subsections: [
                _SubSection('5.1 Ownership', [
                  'You retain full ownership of all content you create within the App, including diary entries, mood logs, voice recordings, and any attached images. We do not claim any ownership rights over your content.',
                ]),
                _SubSection('5.2 Your Responsibilities', [
                  'You are solely responsible for the content you create. You agree not to use the App to store illegal content, plan harmful activities, or violate any applicable laws.',
                ]),
                _SubSection('5.3 Data Storage', [
                  'Your content is stored locally on your device. We strongly recommend backing up your device regularly, as we cannot recover lost data if your device is damaged, lost, or reset.',
                ]),
              ],
            ),

            _buildSection(
              context,
              '6. AI Features',
              null,
              subsections: [
                _SubSection('6.1 AI Companion', [
                  'The AI chat companion feature is designed to provide emotional support and facilitate reflection.',
                  '⚠️ The AI is NOT a substitute for professional mental health care, therapy, or counseling.',
                  '⚠️ If you are experiencing a mental health crisis, please contact a qualified mental health professional or emergency services immediately.',
                  'AI responses are generated by artificial intelligence and may not always be accurate or appropriate.',
                ]),
                _SubSection('6.2 Limitations', [
                  'Does not provide medical, psychological, or professional advice.',
                  'May occasionally generate incorrect or inappropriate responses.',
                  'Should be used for personal reflection and journaling purposes only.',
                ]),
              ],
            ),

            _buildSection(
              context,
              '7. Intellectual Property',
              'The App, including its design, graphics, animations, code, and branding, is the intellectual property of Susu and is protected by copyright and other intellectual property laws.',
              bullets: [
                'Do not copy, modify, or distribute the App or its content.',
                'Do not reverse engineer, decompile, or disassemble the App.',
                'Do not use our branding, logos, or design elements without permission.',
              ],
            ),

            _buildSection(
              context,
              '8. Disclaimer of Warranties',
              'The App is provided "AS IS" and "AS AVAILABLE" without warranties of any kind, either express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, that the App will be uninterrupted or error-free, or regarding the accuracy of AI-generated content.',
            ),

            _buildSection(
              context,
              '9. Limitation of Liability',
              'To the maximum extent permitted by law, we shall not be liable for:',
              bullets: [
                'Any indirect, incidental, special, or consequential damages.',
                'Loss of data, profit, or goodwill.',
                'Any damages resulting from your use or inability to use the App.',
                'Any actions taken based on AI-generated content.',
                'Any unauthorized access to your data due to device compromise.',
              ],
            ),

            _buildSection(
              context,
              '10. Modifications to the App',
              'We reserve the right to modify, update, or discontinue any features of the App at any time, release updates that may change functionality, and add or remove features without prior notice.',
            ),

            _buildSection(
              context,
              '11. Termination',
              'You may stop using the App at any time by uninstalling it from your device. Upon uninstallation, all locally stored data will be permanently deleted.',
            ),

            _buildSection(
              context,
              '12. Changes to Terms',
              'We may update these Terms from time to time. We will notify you of significant changes through the App. Your continued use of the App after changes are posted constitutes your acceptance.',
            ),

            _buildSection(
              context,
              '13. Governing Law',
              'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which we operate, without regard to its conflict of law principles.',
            ),

            _buildSection(
              context,
              '14. Contact Us',
              'If you have any questions about these Terms of Service, please contact us at:',
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'Susu — Your AI Diary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
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
                  color: AppTheme.secondaryColor,
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
