import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class MoodPieChart extends StatelessWidget {
  final Map<String, int> moodDistribution;

  const MoodPieChart({
    super.key,
    required this.moodDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final total = moodDistribution.values.fold(0, (a, b) => a + b);
    
    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data')),
      );
    }

    final sections = moodDistribution.entries.map((entry) {
      final percentage = entry.value / total * 100;
      final color = AppTheme.getMoodColor(entry.key);
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: percentage >= 10 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: moodDistribution.entries.map((entry) {
              final color = AppTheme.getMoodColor(entry.key);
              final emoji = AppTheme.getMoodEmoji(entry.key);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      _capitalize(entry.key),
                      style: const TextStyle(fontSize: 12),
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
