import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? relatedEntryId;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.relatedEntryId,
    this.type = MessageType.text,
  });

  factory ChatMessage.user({
    required String content,
    String? relatedEntryId,
    MessageType type = MessageType.text,
  }) {
    return ChatMessage(
      id: const Uuid().v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      relatedEntryId: relatedEntryId,
      type: type,
    );
  }

  factory ChatMessage.ai({
    required String content,
    String? relatedEntryId,
    MessageType type = MessageType.text,
  }) {
    return ChatMessage(
      id: const Uuid().v4(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      relatedEntryId: relatedEntryId,
      type: type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'relatedEntryId': relatedEntryId,
      'type': type.name,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      content: map['content'] as String,
      isUser: (map['isUser'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      relatedEntryId: map['relatedEntryId'] as String?,
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
    );
  }

  @override
  List<Object?> get props => [id, content, isUser, timestamp, relatedEntryId, type];
}

enum MessageType {
  text,
  reflection,
  suggestion,
  encouragement,
  question,
}
