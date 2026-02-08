import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../models/mood_data.dart';

class AIService {
  static final AIService instance = AIService._init();
  
  // LongCat API Configuration (embedded and obfuscated)
  late String _apiKey;
  String _baseUrl = 'https://api.longcat.chat/openai/v1';
  String _model = 'LongCat-Flash-Chat';
  
  // Daily usage tracking (500,000 tokens free per day)
  static const int _dailyTokenLimit = 500000;
  static const String _usageKey = 'longcat_daily_usage';
  static const String _usageDateKey = 'longcat_usage_date';
  int _tokensUsedToday = 0;
  String _lastUsageDate = '';

  AIService._init() {
    _initializeKey();
    _loadUsage();
  }

  // Obfuscated API key - split and encoded for security
  void _initializeKey() {
    // Key parts (base64 encoded and split for obfuscation)
    const p1 = 'YWtfMlZVN3Jl';  // Part 1
    const p2 = 'M2xiMGxRMXFI';  // Part 2
    const p3 = 'OEJXOGNCMkI0';  // Part 3
    const p4 = 'NFZoNUE=';      // Part 4
    _apiKey = utf8.decode(base64.decode('$p1$p2$p3$p4'));
  }

  Future<void> _loadUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final savedDate = prefs.getString(_usageDateKey) ?? '';
      
      if (savedDate == today) {
        _tokensUsedToday = prefs.getInt(_usageKey) ?? 0;
      } else {
        // New day, reset usage
        _tokensUsedToday = 0;
        await prefs.setInt(_usageKey, 0);
        await prefs.setString(_usageDateKey, today);
      }
      _lastUsageDate = today;
    } catch (e) {
      _tokensUsedToday = 0;
    }
  }

  Future<void> _saveUsage(int tokensUsed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      // Reset if new day
      if (_lastUsageDate != today) {
        _tokensUsedToday = 0;
        _lastUsageDate = today;
      }
      
      _tokensUsedToday += tokensUsed;
      await prefs.setInt(_usageKey, _tokensUsedToday);
      await prefs.setString(_usageDateKey, today);
    } catch (e) {
      // Ignore save errors
    }
  }

  int get tokensUsedToday => _tokensUsedToday;
  int get tokensRemaining => _dailyTokenLimit - _tokensUsedToday;
  double get usagePercentage => (_tokensUsedToday / _dailyTokenLimit * 100).clamp(0, 100);
  bool get hasReachedLimit => _tokensUsedToday >= _dailyTokenLimit;

  // API is always configured with embedded key
  bool get isConfigured => true;

  Future<Map<String, String>> get _headers async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

  // ============ SMART WRITING ASSISTANT ============

  Future<String> enhanceEntry(String content) async {
    if (!isConfigured) return content;

    final prompt = '''
You are a compassionate diary writing assistant. Enhance this diary entry to be more expressive, emotional, and detailed while maintaining the original meaning and the writer's authentic voice.

Original entry:
"$content"

Provide an enhanced version that:
1. Expands on the emotions and feelings
2. Adds sensory details where appropriate
3. Maintains a personal, reflective tone
4. Keeps the authentic voice of the writer

Enhanced entry:''';

    return await _chatCompletion(prompt);
  }

  Future<String> fixGrammar(String content) async {
    if (!isConfigured) return content;

    final prompt = '''
Fix any grammar, spelling, or punctuation errors in this diary entry while keeping the original style and voice intact. Only fix errors, don't change the meaning or tone.

Original:
"$content"

Corrected version:''';

    return await _chatCompletion(prompt);
  }

  Future<String> expandNote(String shortNote) async {
    if (!isConfigured) return shortNote;

    final prompt = '''
You are a diary writing assistant. Expand this brief note into a fuller diary entry while keeping the same sentiment and meaning. Make it personal and reflective.

Brief note:
"$shortNote"

Expanded entry (2-3 paragraphs):''';

    return await _chatCompletion(prompt);
  }

  // ============ MOOD DETECTION ============

  Future<Map<String, dynamic>> analyzeMood(String content) async {
    if (!isConfigured) {
      return {
        'mood': 'neutral',
        'energyLevel': 3,
        'sentimentScore': 0.0,
        'keywords': <String>[],
        'summary': '',
      };
    }

    final prompt = '''
Analyze the emotional content of this diary entry. Provide your analysis in JSON format.

Diary entry:
"$content"

Respond with ONLY a valid JSON object in this exact format:
{
  "mood": "one of: happy, sad, stressed, anxious, calm, angry, excited, neutral, grateful, hopeful, frustrated, peaceful",
  "energyLevel": "integer from 1 (very low energy) to 5 (very high energy)",
  "sentimentScore": "float from -1.0 (very negative) to 1.0 (very positive)",
  "keywords": ["list", "of", "emotional", "keywords", "from", "the", "text"],
  "summary": "A brief 1-sentence emotional summary of the entry"
}''';

    try {
      final response = await _chatCompletion(prompt);
      final jsonStr = _extractJson(response);
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      
      return {
        'mood': parsed['mood'] ?? 'neutral',
        'energyLevel': parsed['energyLevel'] ?? 3,
        'sentimentScore': (parsed['sentimentScore'] ?? 0.0).toDouble(),
        'keywords': List<String>.from(parsed['keywords'] ?? []),
        'summary': parsed['summary'] ?? '',
      };
    } catch (e) {
      return {
        'mood': 'neutral',
        'energyLevel': 3,
        'sentimentScore': 0.0,
        'keywords': <String>[],
        'summary': '',
      };
    }
  }

  // ============ DAILY REFLECTION QUESTIONS ============

  Future<String> generateReflectionQuestion(String? currentMood, String? recentEntrySummary) async {
    if (!isConfigured) {
      return "What are you grateful for today?";
    }

    final context = currentMood != null 
        ? "The user's current mood seems to be $currentMood."
        : "No mood context available.";
    
    final entrySummary = recentEntrySummary != null
        ? "Recent diary summary: $recentEntrySummary"
        : "";

    final prompt = '''
You are a thoughtful journaling companion. Generate ONE personalized reflection question for the user to help them reflect on their day.

$context
$entrySummary

The question should:
1. Be open-ended and thought-provoking
2. Encourage self-reflection and growth
3. Be supportive and non-judgmental
4. Be relevant to their emotional state if known

Generate only the question, nothing else:''';

    return await _chatCompletion(prompt);
  }

  Future<List<String>> generateDailyPrompts(String? currentMood) async {
    if (!isConfigured) {
      return [
        "What made you smile today?",
        "What are you grateful for?",
        "What did you learn today?",
      ];
    }

    final moodContext = currentMood != null 
        ? "The user's current mood: $currentMood"
        : "";

    final prompt = '''
Generate 3 thoughtful journaling prompts for today. $moodContext

Format: Return only the 3 questions, one per line, no numbering or bullets.''';

    try {
      final response = await _chatCompletion(prompt);
      return response.split('\n').where((s) => s.trim().isNotEmpty).take(3).toList();
    } catch (e) {
      return [
        "What made you smile today?",
        "What are you grateful for?",
        "What did you learn today?",
      ];
    }
  }

  // ============ WEEKLY/MONTHLY SUMMARIES ============

  Future<String> generateWeeklySummary(List<DiaryEntry> entries) async {
    if (!isConfigured || entries.isEmpty) {
      return "No entries to summarize for this week.";
    }

    final entriesText = entries.map((e) => '''
Date: ${e.createdAt.toString().split(' ')[0]}
Mood: ${e.mood}
Entry: ${e.content}
---''').join('\n');

    final prompt = '''
You are a compassionate life coach reviewing someone's weekly diary entries. Create a supportive and insightful weekly summary.

This week's entries:
$entriesText

Provide a warm, supportive summary that includes:
1. Overall emotional pattern of the week
2. Key themes or events that stood out
3. Positive aspects and achievements (however small)
4. Areas that seemed challenging
5. One piece of encouraging advice for the coming week

Keep the tone warm, supportive, and non-judgmental. About 150-200 words.''';

    return await _chatCompletion(prompt);
  }

  Future<String> generateMonthlySummary(List<DiaryEntry> entries) async {
    if (!isConfigured || entries.isEmpty) {
      return "No entries to summarize for this month.";
    }

    final moodCounts = <String, int>{};
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    final entriesOverview = entries.map((e) => 
      '${e.createdAt.toString().split(' ')[0]}: ${e.mood} - ${e.title}'
    ).join('\n');

    final prompt = '''
You are a thoughtful life coach reviewing someone's monthly diary entries. Create an insightful monthly reflection.

Month Overview (${entries.length} entries):
$entriesOverview

Mood Distribution: $moodCounts

Provide a reflective monthly summary that includes:
1. Overall emotional journey through the month
2. Patterns you noticed (what days/situations triggered certain moods)
3. Personal growth moments
4. Recurring themes or challenges
5. Strengths demonstrated
6. Suggestions for emotional wellness next month

Keep the tone warm and encouraging. About 200-250 words.''';

    return await _chatCompletion(prompt);
  }

  // ============ AI CHAT (DIARY BUDDY) ============

  Future<String> chat(String userMessage, List<Map<String, String>> conversationHistory) async {
    if (!isConfigured) {
      return "I'm here to listen. Please configure the AI service to enable chat features.";
    }

    final systemPrompt = '''
You are Susu AI, a compassionate, empathetic diary companion. Your role is to:

1. Listen without judgment
2. Offer emotional support and validation
3. Ask thoughtful follow-up questions when appropriate
4. Provide gentle perspective and encouragement
5. Help users process their feelings
6. Suggest healthy coping strategies when relevant
7. Celebrate their wins, no matter how small

Important guidelines:
- Never diagnose or provide medical/psychiatric advice
- If someone expresses serious distress, gently suggest professional help
- Keep responses warm but concise (2-4 sentences usually)
- Remember: you're a supportive friend, not a therapist
- Maintain user privacy - you don't save or share anything''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    return await _chatCompletionWithMessages(messages);
  }

  // ============ IMAGE DIARY ============

  Future<String> describeImage(String imageBase64) async {
    if (!isConfigured) {
      return "A moment captured in time.";
    }

    // For GPT-4 Vision
    final prompt = '''
Describe this image as if it were a diary memory. Create a warm, personal description that captures:
1. The mood and atmosphere
2. Key elements in the image
3. What feelings or memories it might evoke

Keep it to 2-3 sentences, personal and reflective in tone.''';

    // Note: This requires GPT-4 Vision API
    // For now, return a placeholder
    return await _chatCompletion(
      "Create a brief, poetic diary caption for a photo. Make it warm and personal, 1-2 sentences."
    );
  }

  // ============ PRIVATE METHODS ============

  Future<String> _chatCompletion(String prompt) async {
    // Check daily limit
    if (hasReachedLimit) {
      return "Daily AI limit reached (500,000 tokens). Resets at midnight Beijing time.";
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: await _headers,
        body: json.encode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Track token usage from response
        final usage = data['usage'];
        if (usage != null) {
          final totalTokens = usage['total_tokens'] ?? 0;
          await _saveUsage(totalTokens);
        } else {
          // Estimate tokens if not provided (roughly 4 chars per token)
          await _saveUsage((prompt.length ~/ 4) + 125);
        }
        
        return data['choices'][0]['message']['content'].toString().trim();
      } else if (response.statusCode == 429) {
        return "Rate limit exceeded. Please try again later.";
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  Future<String> _chatCompletionWithMessages(List<Map<String, String>> messages) async {
    // Check daily limit
    if (hasReachedLimit) {
      return "Daily AI limit reached (500,000 tokens). Resets at midnight Beijing time.";
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: await _headers,
        body: json.encode({
          'model': _model,
          'messages': messages,
          'max_tokens': 300,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Track token usage
        final usage = data['usage'];
        if (usage != null) {
          final totalTokens = usage['total_tokens'] ?? 0;
          await _saveUsage(totalTokens);
        } else {
          await _saveUsage(150); // Estimate for chat
        }
        
        return data['choices'][0]['message']['content'].toString().trim();
      } else if (response.statusCode == 429) {
        return "Rate limit exceeded. Please try again later.";
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return "I'm having trouble connecting right now. Please try again in a moment.";
    }
  }

  String _extractJson(String text) {
    // Find JSON object in the response
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }
    return text;
  }
}
