import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/diary_entry.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/ai_service.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _weeklySummary = '';
  String _monthlySummary = '';
  List<DiaryEntry> _weeklyEntries = [];
  List<DiaryEntry> _monthlyEntries = [];
  bool _isGeneratingWeekly = false;
  bool _isGeneratingMonthly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      
      // Load weekly entries
      final weekStart = now.subtract(const Duration(days: 7));
      _weeklyEntries = await DatabaseService.instance.getEntriesByDateRange(
        weekStart,
        now,
      );

      // Load monthly entries
      final monthStart = DateTime(now.year, now.month - 1, now.day);
      _monthlyEntries = await DatabaseService.instance.getEntriesByDateRange(
        monthStart,
        now,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateWeeklySummary() async {
    if (_weeklyEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No entries this week to summarize')),
      );
      return;
    }

    setState(() => _isGeneratingWeekly = true);

    try {
      final summary = await AIService.instance.generateWeeklySummary(_weeklyEntries);
      setState(() => _weeklySummary = summary);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isGeneratingWeekly = false);
    }
  }

  Future<void> _generateMonthlySummary() async {
    if (_monthlyEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No entries this month to summarize')),
      );
      return;
    }

    setState(() => _isGeneratingMonthly = true);

    try {
      final summary = await AIService.instance.generateMonthlySummary(_monthlyEntries);
      setState(() => _monthlySummary = summary);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isGeneratingMonthly = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Summary'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Weekly Tab
                _buildSummaryTab(
                  entries: _weeklyEntries,
                  summary: _weeklySummary,
                  isGenerating: _isGeneratingWeekly,
                  onGenerate: _generateWeeklySummary,
                  periodLabel: 'week',
                ),
                
                // Monthly Tab
                _buildSummaryTab(
                  entries: _monthlyEntries,
                  summary: _monthlySummary,
                  isGenerating: _isGeneratingMonthly,
                  onGenerate: _generateMonthlySummary,
                  periodLabel: 'month',
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryTab({
    required List<DiaryEntry> entries,
    required String summary,
    required bool isGenerating,
    required VoidCallback onGenerate,
    required String periodLabel,
  }) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats overview
            _buildStatsOverview(entries, periodLabel)
                .animate()
                .fadeIn()
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Quick mood breakdown
            _buildMoodBreakdown(entries)
                .animate()
                .fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // AI Summary section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI ${periodLabel.substring(0, 1).toUpperCase()}${periodLabel.substring(1)} Summary',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (summary.isNotEmpty)
                    Text(
                      summary,
                      style: const TextStyle(
                        height: 1.6,
                        fontSize: 15,
                      ),
                    )
                  else if (isGenerating)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Generating your summary...'),
                          ],
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.summarize_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            entries.isEmpty
                                ? 'No entries this $periodLabel'
                                : 'Generate an AI-powered summary\nof your $periodLabel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: entries.isEmpty ? null : onGenerate,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Generate Summary'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Recent entries
            Text(
              'Entries this $periodLabel',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            
            if (entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.note_add_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No entries yet this $periodLabel',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...entries.take(5).map((entry) {
                final moodColor = AppTheme.getMoodColor(entry.mood);
                final moodEmoji = AppTheme.getMoodEmoji(entry.mood);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: moodColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(moodEmoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('MMM d, h:mm a').format(entry.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(List<DiaryEntry> entries, String period) {
    final avgEnergy = entries.isEmpty
        ? 0.0
        : entries.map((e) => e.energyLevel).reduce((a, b) => a + b) / entries.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.book_rounded,
            value: '${entries.length}',
            label: 'Entries',
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bolt_rounded,
            value: avgEnergy.toStringAsFixed(1),
            label: 'Avg Energy',
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodBreakdown(List<DiaryEntry> entries) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final moodCounts = <String, int>{};
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Overview',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: sortedMoods.take(5).map((entry) {
              final color = AppTheme.getMoodColor(entry.key);
              final emoji = AppTheme.getMoodEmoji(entry.key);
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.value}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
