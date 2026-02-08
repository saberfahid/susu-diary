import 'package:equatable/equatable.dart';

class MoodData extends Equatable {
  final DateTime date;
  final String mood;
  final int energyLevel;
  final double sentimentScore; // -1 to 1
  final List<String> keywords;
  final String? summary;

  const MoodData({
    required this.date,
    required this.mood,
    required this.energyLevel,
    required this.sentimentScore,
    this.keywords = const [],
    this.summary,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'energyLevel': energyLevel,
      'sentimentScore': sentimentScore,
      'keywords': keywords.join(','),
      'summary': summary,
    };
  }

  factory MoodData.fromMap(Map<String, dynamic> map) {
    return MoodData(
      date: DateTime.parse(map['date'] as String),
      mood: map['mood'] as String,
      energyLevel: map['energyLevel'] as int,
      sentimentScore: (map['sentimentScore'] as num).toDouble(),
      keywords: (map['keywords'] as String?)?.isNotEmpty == true
          ? (map['keywords'] as String).split(',')
          : [],
      summary: map['summary'] as String?,
    );
  }

  @override
  List<Object?> get props => [date, mood, energyLevel, sentimentScore, keywords, summary];
}

class WeeklySummary extends Equatable {
  final DateTime weekStart;
  final DateTime weekEnd;
  final String dominantMood;
  final double averageEnergy;
  final double averageSentiment;
  final Map<String, int> moodDistribution;
  final List<String> highlights;
  final List<String> challenges;
  final String aiSummary;
  final List<String> recommendations;

  const WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.dominantMood,
    required this.averageEnergy,
    required this.averageSentiment,
    required this.moodDistribution,
    this.highlights = const [],
    this.challenges = const [],
    required this.aiSummary,
    this.recommendations = const [],
  });

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        dominantMood,
        averageEnergy,
        averageSentiment,
        moodDistribution,
        highlights,
        challenges,
        aiSummary,
        recommendations,
      ];
}

class MonthlySummary extends Equatable {
  final int year;
  final int month;
  final Map<String, int> moodDistribution;
  final double averageEnergy;
  final double averageSentiment;
  final List<String> topKeywords;
  final List<WeeklySummary> weeklySummaries;
  final String aiInsights;
  final List<String> patterns;
  final List<String> growthAreas;

  const MonthlySummary({
    required this.year,
    required this.month,
    required this.moodDistribution,
    required this.averageEnergy,
    required this.averageSentiment,
    this.topKeywords = const [],
    this.weeklySummaries = const [],
    required this.aiInsights,
    this.patterns = const [],
    this.growthAreas = const [],
  });

  @override
  List<Object?> get props => [
        year,
        month,
        moodDistribution,
        averageEnergy,
        averageSentiment,
        topKeywords,
        weeklySummaries,
        aiInsights,
        patterns,
        growthAreas,
      ];
}
