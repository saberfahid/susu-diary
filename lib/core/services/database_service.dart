import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../models/chat_message.dart';
import '../models/mood_data.dart';

/// DatabaseService stores all diary data privately within the app.
/// Data is stored in app-private SharedPreferences and is NOT accessible 
/// by other apps, file managers, or external processes.
/// 
/// Privacy features:
/// - All data stored in app's private sandbox
/// - No external storage permissions requested
/// - Keys are prefixed to prevent conflicts
/// - Data is cleared when app is uninstalled
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  
  // Private storage keys - prefixed for isolation
  static const String _keyPrefix = 'mindnote_private_';
  static const String _entriesKey = '${_keyPrefix}diary_entries';
  static const String _chatKey = '${_keyPrefix}chat_messages';
  static const String _moodKey = '${_keyPrefix}mood_data';
  
  // In-memory storage (works for both web and as fallback)
  final List<DiaryEntry> _entries = [];
  final List<ChatMessage> _chatMessages = [];
  final List<MoodData> _moodData = [];
  final List<Map<String, dynamic>> _reflectionQuestions = [];
  
  bool _initialized = false;
  SharedPreferences? _prefs;

  DatabaseService._init();

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadFromStorage();
    } catch (e) {
      // SharedPreferences might fail on some platforms, continue with in-memory
      print('Storage init warning: $e');
    }
    
    _initDefaultQuestions();
    _initialized = true;
  }

  Future<void> _loadFromStorage() async {
    if (_prefs == null) return;
    
    // Load entries from private SharedPreferences
    final entriesJson = _prefs!.getStringList(_entriesKey) ?? [];
    for (final json in entriesJson) {
      try {
        _entries.add(DiaryEntry.fromMap(jsonDecode(json)));
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    // Load chat messages
    final chatJson = _prefs!.getStringList(_chatKey) ?? [];
    for (final json in chatJson) {
      try {
        _chatMessages.add(ChatMessage.fromMap(jsonDecode(json)));
      } catch (e) {
        // Skip invalid messages
      }
    }
    
    // Load mood data
    final moodJson = _prefs!.getStringList(_moodKey) ?? [];
    for (final json in moodJson) {
      try {
        _moodData.add(MoodData.fromMap(jsonDecode(json)));
      } catch (e) {
        // Skip invalid data
      }
    }
  }

  void _initDefaultQuestions() {
    if (_reflectionQuestions.isNotEmpty) return;
    
    _reflectionQuestions.addAll([
      {'question': 'What made you smile today?', 'category': 'gratitude', 'moodTarget': null},
      {'question': 'What are you grateful for today?', 'category': 'gratitude', 'moodTarget': null},
      {'question': 'What was the highlight of your day?', 'category': 'reflection', 'moodTarget': null},
      {'question': 'What challenged you today and how did you handle it?', 'category': 'growth', 'moodTarget': 'stressed'},
      {'question': 'What could make tomorrow better?', 'category': 'planning', 'moodTarget': 'sad'},
      {'question': 'What did you learn about yourself today?', 'category': 'self-awareness', 'moodTarget': null},
      {'question': 'Who made a positive impact on your day?', 'category': 'connection', 'moodTarget': null},
      {'question': 'What would you do differently if you could relive today?', 'category': 'reflection', 'moodTarget': null},
      {'question': 'What are you looking forward to?', 'category': 'hope', 'moodTarget': 'sad'},
      {'question': 'How did you take care of yourself today?', 'category': 'self-care', 'moodTarget': 'stressed'},
      {'question': 'What made today stressful and how can you address it?', 'category': 'problem-solving', 'moodTarget': 'stressed'},
      {'question': 'What emotions dominated your day and why?', 'category': 'emotional-awareness', 'moodTarget': null},
      {'question': 'What accomplishment, however small, are you proud of today?', 'category': 'achievement', 'moodTarget': 'sad'},
      {'question': 'What brought you peace or calm today?', 'category': 'mindfulness', 'moodTarget': 'anxious'},
      {'question': 'How did you connect with others today?', 'category': 'connection', 'moodTarget': null},
    ]);
  }

  Future<void> _saveEntries() async {
    if (_prefs == null) return;
    try {
      final jsonList = _entries.map((e) => jsonEncode(e.toMap())).toList();
      await _prefs!.setStringList(_entriesKey, jsonList);
    } catch (e) {
      print('Save entries error: $e');
    }
  }

  Future<void> _saveChatMessages() async {
    if (_prefs == null) return;
    try {
      final jsonList = _chatMessages.map((m) => jsonEncode(m.toMap())).toList();
      await _prefs!.setStringList(_chatKey, jsonList);
    } catch (e) {
      print('Save chat error: $e');
    }
  }

  Future<void> _saveMoodData() async {
    if (_prefs == null) return;
    try {
      final jsonList = _moodData.map((m) => jsonEncode(m.toMap())).toList();
      await _prefs!.setStringList(_moodKey, jsonList);
    } catch (e) {
      print('Save mood error: $e');
    }
  }

  // ============ DIARY ENTRY OPERATIONS ============

  Future<String> insertEntry(DiaryEntry entry) async {
    _entries.insert(0, entry);
    await _saveEntries();
    return entry.id;
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      await _saveEntries();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();
  }

  Future<DiaryEntry?> getEntry(String id) async {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<DiaryEntry>> getAllEntries({int? limit, int? offset}) async {
    var entries = List<DiaryEntry>.from(_entries);
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (offset != null && offset < entries.length) {
      entries = entries.sublist(offset);
    }
    if (limit != null && entries.length > limit) {
      entries = entries.sublist(0, limit);
    }
    return entries;
  }

  Future<List<DiaryEntry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    return _entries.where((e) => 
      (e.createdAt.isAfter(start) || e.createdAt.isAtSameMomentAs(start)) && 
      (e.createdAt.isBefore(end) || e.createdAt.isAtSameMomentAs(end))
    ).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<DiaryEntry>> getEntriesByMood(String mood) async {
    return _entries.where((e) => e.mood == mood).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<DiaryEntry>> searchEntries(String query) async {
    final lowerQuery = query.toLowerCase();
    return _entries.where((e) =>
      e.title.toLowerCase().contains(lowerQuery) ||
      e.content.toLowerCase().contains(lowerQuery) ||
      e.tags.any((t) => t.toLowerCase().contains(lowerQuery))
    ).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<DiaryEntry>> getFavoriteEntries() async {
    return _entries.where((e) => e.isFavorite).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(isFavorite: isFavorite);
      await _saveEntries();
    }
  }

  Future<DiaryEntry?> getTodayEntry() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    try {
      return _entries.firstWhere((e) =>
        (e.createdAt.isAfter(today) || e.createdAt.isAtSameMomentAs(today)) && 
        e.createdAt.isBefore(tomorrow)
      );
    } catch (e) {
      return null;
    }
  }

  // ============ CHAT OPERATIONS ============

  Future<void> insertChatMessage(ChatMessage message) async {
    _chatMessages.add(message);
    await _saveChatMessages();
  }

  Future<List<ChatMessage>> getChatHistory({int limit = 50}) async {
    var messages = List<ChatMessage>.from(_chatMessages);
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (messages.length > limit) {
      messages = messages.sublist(messages.length - limit);
    }
    return messages;
  }

  Future<void> clearChatHistory() async {
    _chatMessages.clear();
    await _saveChatMessages();
  }

  // ============ MOOD DATA OPERATIONS ============

  Future<void> insertMoodData(MoodData moodData) async {
    _moodData.add(moodData);
    await _saveMoodData();
  }

  Future<List<MoodData>> getMoodDataByRange(DateTime start, DateTime end) async {
    return _moodData.where((m) =>
      (m.date.isAfter(start) || m.date.isAtSameMomentAs(start)) && 
      (m.date.isBefore(end) || m.date.isAtSameMomentAs(end))
    ).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<Map<String, int>> getMoodDistribution(DateTime start, DateTime end) async {
    final moodData = await getMoodDataByRange(start, end);
    final distribution = <String, int>{};
    for (final data in moodData) {
      distribution[data.mood] = (distribution[data.mood] ?? 0) + 1;
    }
    return distribution;
  }

  // ============ REFLECTION QUESTIONS ============

  Future<List<Map<String, dynamic>>> getReflectionQuestions({String? moodTarget}) async {
    if (moodTarget != null) {
      return _reflectionQuestions.where((q) =>
        q['moodTarget'] == null || q['moodTarget'] == moodTarget
      ).toList();
    }
    return _reflectionQuestions;
  }

  Future<String> getRandomReflectionQuestion({String? moodTarget}) async {
    final questions = await getReflectionQuestions(moodTarget: moodTarget);
    if (questions.isEmpty) return "How are you feeling today?";
    questions.shuffle();
    return questions.first['question'] as String;
  }

  // ============ STATISTICS ============

  Future<int> getTotalEntriesCount() async {
    return _entries.length;
  }

  Future<int> getCurrentStreak() async {
    final entries = await getAllEntries();
    if (entries.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final entry in entries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );

      if (lastDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final diff = todayDate.difference(entryDate).inDays;
        if (diff > 1) break;
        streak = 1;
        lastDate = entryDate;
      } else {
        final diff = lastDate.difference(entryDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = entryDate;
        } else {
          break;
        }
      }
    }
    return streak;
  }

  Future<void> deleteAllData() async {
    _entries.clear();
    _chatMessages.clear();
    _moodData.clear();
    await _saveEntries();
    await _saveChatMessages();
    await _saveMoodData();
  }

  Future<void> close() async {
    // No-op for in-memory storage
  }
}
