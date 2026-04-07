import 'emotion_type.dart';

class DiaryEntryEntity {
  final int? id;
  final String content;
  final EmotionType emotion;
  final int emotionIntensity; // 1–10
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiaryEntryEntity({
    this.id,
    required this.content,
    required this.emotion,
    required this.emotionIntensity,
    required this.createdAt,
    required this.updatedAt,
  });

  DiaryEntryEntity copyWith({
    int? id,
    String? content,
    EmotionType? emotion,
    int? emotionIntensity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntryEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      emotion: emotion ?? this.emotion,
      emotionIntensity: emotionIntensity ?? this.emotionIntensity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
