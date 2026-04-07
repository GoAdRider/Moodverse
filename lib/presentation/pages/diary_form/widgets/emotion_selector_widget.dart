import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/emotion_type.dart';

class EmotionSelectorWidget extends StatelessWidget {
  const EmotionSelectorWidget({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final EmotionType selected;
  final ValueChanged<EmotionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'diary.emotion_label'.tr(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: EmotionType.values
              .map((emotion) => _EmotionChip(
                    emotion: emotion,
                    isSelected: emotion == selected,
                    onTap: () => onChanged(emotion),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({
    required this.emotion,
    required this.isSelected,
    required this.onTap,
  });

  final EmotionType emotion;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = emotion.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emotion.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              emotion.translationKey.tr(),
              style: TextStyle(
                color: isSelected ? color : AppColors.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
