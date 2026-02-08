import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/diary_entry.dart';
import '../../../core/services/database_service.dart';
import '../widgets/mood_pie_chart.dart';
import '../widgets/energy_line_chart.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  String _selectedPeriod = 'week';
  Map<String, int> _moodDistribution = {};
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;
  int _totalEntries = 0;
  int _streak = 0;
  double _averageEnergy = 0;
  String _dominantMood = 'neutral';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedPeriod) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      final entries = await DatabaseService.instance.getEntriesByDateRange(
        startDate,
        now,
      );

      // Calculate mood distribution
      final Map<String, int> moodCounts = {};
      double totalEnergy = 0;

      for (final entry in entries) {
        moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
        totalEnergy += entry.energyLevel;
      }

      // Find dominant mood
      String dominant = 'neutral';
      int maxCount = 0;
      moodCounts.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          dominant = mood;
        }
      });

      final total = await DatabaseService.instance.getTotalEntriesCount();
      final streak = await DatabaseService.instance.getCurrentStreak();

      setState(() {
        _entries = entries;
        _moodDistribution = moodCounts;
        _totalEntries = total;
        _streak = streak;
        _averageEnergy = entries.isNotEmpty ? totalEnergy / entries.length : 0;
        _dominantMood = dominant;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Analytics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period selector
                    _buildPeriodSelector()
                        .animate()
                        .fadeIn()
                        .slideY(begin: -0.1, end: 0),

                    const SizedBox(height: 24),

                    // Stats cards
                    _buildStatsRow()
                        .animate()
                        .fadeIn(delay: 100.ms),

                    const SizedBox(height: 24),

                    // Mood distribution pie chart
                    _buildMoodDistributionCard()
                        .animate()
                        .fadeIn(delay: 200.ms),

                    const SizedBox(height: 24),

                    // Energy trend line chart
                    _buildEnergyTrendCard()
                        .animate()
                        .fadeIn(delay: 300.ms),

                    const SizedBox(height: 24),

                    // Mood breakdown list
                    _buildMoodBreakdownCard()
                        .animate()
                        .fadeIn(delay: 400.ms),

                    const SizedBox(height: 24),

                    // Insights
                    _buildInsightsCard()
                        .animate()
                        .fadeIn(delay: 500.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton('week', 'Week'),
          _buildPeriodButton('month', 'Month'),
          _buildPeriodButton('year', 'Year'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPeriod = period);
          _loadData();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.book_rounded,
            value: '${_entries.length}',
            label: 'Entries',
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            value: '$_streak',
            label: 'Streak',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bolt_rounded,
            value: _averageEnergy.toStringAsFixed(1),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildMoodDistributionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Mood Distribution',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_moodDistribution.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            MoodPieChart(moodDistribution: _moodDistribution),
        ],
      ),
    );
  }

  Widget _buildEnergyTrendCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, color: AppTheme.secondaryColor),
              SizedBox(width: 8),
              Text(
                'Energy Trend',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            EnergyLineChart(entries: _entries),
        ],
      ),
    );
  }

  Widget _buildMoodBreakdownCard() {
    final sortedMoods = _moodDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = _moodDistribution.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt_rounded, color: AppTheme.accentColor),
              SizedBox(width: 8),
              Text(
                'Mood Breakdown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sortedMoods.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            ...sortedMoods.map((entry) {
              final percent = total > 0 ? (entry.value / total * 100) : 0;
              final color = AppTheme.getMoodColor(entry.key);
              final emoji = AppTheme.getMoodEmoji(entry.key);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _capitalize(entry.key),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${entry.value} (${percent.toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent / 100,
                              backgroundColor: color.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    final insights = _generateInsights();

    return Container(
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Insights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_right,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<String> _generateInsights() {
    final insights = <String>[];

    if (_entries.isEmpty) {
      insights.add('Start journaling to get personalized insights!');
      return insights;
    }

    // Dominant mood insight
    final moodEmoji = AppTheme.getMoodEmoji(_dominantMood);
    insights.add(
      'Your most common mood this $_selectedPeriod was $moodEmoji ${_capitalize(_dominantMood)}.',
    );

    // Energy insight
    if (_averageEnergy >= 4) {
      insights.add('Great job! Your average energy level has been high.');
    } else if (_averageEnergy <= 2) {
      insights.add('Your energy has been low. Consider activities that boost your energy.');
    }

    // Streak insight
    if (_streak >= 7) {
      insights.add('Amazing! You\'ve maintained a $_streak day journaling streak!');
    } else if (_streak >= 3) {
      insights.add('Good progress! Keep your $_streak day streak going.');
    }

    // Frequency insight
    final periodDays = _selectedPeriod == 'week'
        ? 7
        : _selectedPeriod == 'month'
            ? 30
            : 365;
    final frequency = (_entries.length / periodDays * 100).round();
    if (frequency >= 80) {
      insights.add('Excellent consistency! You\'ve journaled most days.');
    } else if (frequency >= 50) {
      insights.add('You\'re doing well! Try to write a bit more often.');
    }

    return insights;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
