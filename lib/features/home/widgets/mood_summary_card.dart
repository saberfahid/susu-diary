import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MoodSummaryCard extends StatelessWidget {
  final Map<String, int> moodDistribution;
  final VoidCallback? onTap;

  const MoodSummaryCard({
    super.key,
    required this.moodDistribution,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalEntries = moodDistribution.values.fold(0, (a, b) => a + b);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.mood_rounded,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'This Week\'s Mood',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (totalEntries == 0)
              Center(
                child: Text(
                  'No entries this week',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              )
            else
              Column(
                children: moodDistribution.entries.map((entry) {
                  final percent = (entry.value / totalEntries * 100).round();
                  final color = AppTheme.getMoodColor(entry.key);
                  final emoji = AppTheme.getMoodEmoji(entry.key);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          _capitalize(entry.key),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent / 100,
                              backgroundColor: color.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 35,
                          child: Text(
                            '$percent%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
  
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
