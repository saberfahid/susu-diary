import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class DiaryEntry extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? enhancedContent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String mood;
  final int energyLevel; // 1-5
  final List<String> tags;
  final String? imageUrl;
  final String? voiceNoteUrl;
  final bool isVoiceEntry;
  final bool isFavorite;
  final Map<String, dynamic>? aiAnalysis;

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    this.enhancedContent,
    required this.createdAt,
    required this.updatedAt,
    required this.mood,
    required this.energyLevel,
    this.tags = const [],
    this.imageUrl,
    this.voiceNoteUrl,
    this.isVoiceEntry = false,
    this.isFavorite = false,
    this.aiAnalysis,
  });

  factory DiaryEntry.create({
    required String title,
    required String content,
    String? enhancedContent,
    required String mood,
    required int energyLevel,
    List<String> tags = const [],
    String? imageUrl,
    String? voiceNoteUrl,
    bool isVoiceEntry = false,
  }) {
    final now = DateTime.now();
    return DiaryEntry(
      id: const Uuid().v4(),
      title: title,
      content: content,
      enhancedContent: enhancedContent,
      createdAt: now,
      updatedAt: now,
      mood: mood,
      energyLevel: energyLevel,
      tags: tags,
      imageUrl: imageUrl,
      voiceNoteUrl: voiceNoteUrl,
      isVoiceEntry: isVoiceEntry,
    );
  }

  DiaryEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? enhancedContent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mood,
    int? energyLevel,
    List<String>? tags,
    String? imageUrl,
    String? voiceNoteUrl,
    bool? isVoiceEntry,
    bool? isFavorite,
    Map<String, dynamic>? aiAnalysis,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      enhancedContent: enhancedContent ?? this.enhancedContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      isVoiceEntry: isVoiceEntry ?? this.isVoiceEntry,
      isFavorite: isFavorite ?? this.isFavorite,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'enhancedContent': enhancedContent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'mood': mood,
      'energyLevel': energyLevel,
      'tags': tags.join(','),
      'imageUrl': imageUrl,
      'voiceNoteUrl': voiceNoteUrl,
      'isVoiceEntry': isVoiceEntry ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'aiAnalysis': aiAnalysis != null ? aiAnalysis.toString() : null,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      enhancedContent: map['enhancedContent'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      mood: map['mood'] as String,
      energyLevel: map['energyLevel'] as int,
      tags: (map['tags'] as String?)?.isNotEmpty == true
          ? (map['tags'] as String).split(',')
          : [],
      imageUrl: map['imageUrl'] as String?,
      voiceNoteUrl: map['voiceNoteUrl'] as String?,
      isVoiceEntry: (map['isVoiceEntry'] as int) == 1,
      isFavorite: (map['isFavorite'] as int) == 1,
      aiAnalysis: null, // Parse from JSON if needed
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        enhancedContent,
        createdAt,
        updatedAt,
        mood,
        energyLevel,
        tags,
        imageUrl,
        voiceNoteUrl,
        isVoiceEntry,
        isFavorite,
        aiAnalysis,
      ];
}
