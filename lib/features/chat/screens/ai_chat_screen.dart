import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/ai_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  List<Map<String, String>> _conversationHistory = [];
  bool _isLoading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _addWelcomeMessage();
  }

  Future<void> _loadChatHistory() async {
    try {
      final messages = await DatabaseService.instance.getChatHistory(limit: 20);
      setState(() {
        _messages.addAll(messages);
        // Rebuild conversation history for AI context
        for (final msg in messages) {
          _conversationHistory.add({
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.content,
          });
        }
      });
      _scrollToBottom();
    } catch (e) {
      // Ignore
    }
  }

  void _addWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatMessage.ai(
        content: "Hi there! 👋 I'm Susu, your AI diary companion. I'm here to listen, support, and help you reflect on your day.\n\nFeel free to share what's on your mind, ask for advice, or just chat. Everything here stays private. How are you feeling today?",
        type: MessageType.encouragement,
      );
      setState(() {
        _messages.add(welcomeMessage);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage.user(content: text);
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Save user message
    await DatabaseService.instance.insertChatMessage(userMessage);

    // Add to conversation history
    _conversationHistory.add({
      'role': 'user',
      'content': text,
    });

    // Get AI response
    try {
      final response = await AIService.instance.chat(text, _conversationHistory);
      
      final aiMessage = ChatMessage.ai(content: response);
      
      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });
      
      // Save AI message
      await DatabaseService.instance.insertChatMessage(aiMessage);
      
      // Add to conversation history
      _conversationHistory.add({
        'role': 'assistant',
        'content': response,
      });
      
      // Keep conversation history manageable
      if (_conversationHistory.length > 20) {
        _conversationHistory = _conversationHistory.sublist(_conversationHistory.length - 20);
      }
      
      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);
      
      final errorMessage = ChatMessage.ai(
        content: "I'm having trouble connecting right now. Please try again in a moment.",
      );
      setState(() {
        _messages.add(errorMessage);
      });
    }
  }

  Future<void> _clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text('This will delete all chat history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.clearChatHistory();
      setState(() {
        _messages.clear();
        _conversationHistory.clear();
      });
      _addWelcomeMessage();
    }
  }

  void _insertQuickPrompt(String prompt) {
    _messageController.text = prompt;
    _sendMessage(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Susu AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Your diary companion',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your conversations are private and stored locally on your device.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2, end: 0),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  showTimestamp: _shouldShowTimestamp(index),
                ).animate().fadeIn(duration: 300.ms).slideX(
                      begin: message.isUser ? 0.2 : -0.2,
                      end: 0,
                    );
              },
            ),
          ),

          // Quick prompts
          if (_messages.length <= 2)
            _buildQuickPrompts().animate().fadeIn(delay: 300.ms),

          // Input area
          ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            isEnabled: !_isTyping,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade500.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      'How can I manage stress better?',
      'I want to reflect on my day',
      'Help me feel more grateful',
      'I need some motivation',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try asking:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prompts.map((prompt) {
              return GestureDetector(
                onTap: () => _insertQuickPrompt(prompt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    prompt,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;
    
    final current = _messages[index];
    final previous = _messages[index - 1];
    
    // Show timestamp if more than 5 minutes apart
    return current.timestamp.difference(previous.timestamp).inMinutes > 5;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
