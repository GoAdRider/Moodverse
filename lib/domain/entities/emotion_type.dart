import 'package:flutter/material.dart';

enum EmotionType {
  happy,
  sad,
  angry,
  anxious,
  neutral,
  excited,
  tired,
  grateful;

  String get emoji {
    switch (this) {
      case EmotionType.happy:
        return '😊';
      case EmotionType.sad:
        return '😢';
      case EmotionType.angry:
        return '😠';
      case EmotionType.anxious:
        return '😰';
      case EmotionType.neutral:
        return '😐';
      case EmotionType.excited:
        return '🤩';
      case EmotionType.tired:
        return '😴';
      case EmotionType.grateful:
        return '🙏';
    }
  }

  Color get color {
    switch (this) {
      case EmotionType.happy:
        return const Color(0xFFFFD700);
      case EmotionType.sad:
        return const Color(0xFF6495ED);
      case EmotionType.angry:
        return const Color(0xFFFF4500);
      case EmotionType.anxious:
        return const Color(0xFFDA70D6);
      case EmotionType.neutral:
        return const Color(0xFF90A4AE);
      case EmotionType.excited:
        return const Color(0xFFFF6347);
      case EmotionType.tired:
        return const Color(0xFF708090);
      case EmotionType.grateful:
        return const Color(0xFF98FB98);
    }
  }

  /// Translation key used with easy_localization
  String get translationKey => 'emotion.$name';

  static EmotionType fromString(String value) {
    return EmotionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EmotionType.neutral,
    );
  }
}
