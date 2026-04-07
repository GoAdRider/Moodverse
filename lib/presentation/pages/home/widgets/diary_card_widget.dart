import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../domain/entities/diary_entry_entity.dart';
import '../../../providers/diary_providers.dart';
import '../../diary_form/diary_form_page.dart';

class DiaryCardWidget extends ConsumerWidget {
  const DiaryCardWidget({super.key, required this.entry});

  final DiaryEntryEntity entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotion = entry.emotion;
    final locale = context.locale.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openEdit(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────────────
              Row(
                children: [
                  // Emotion badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: emotion.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emotion.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          emotion.translationKey.tr(),
                          style: TextStyle(
                            color: emotion.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Intensity indicator
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.circle,
                        size: 8,
                        color: i < (entry.emotionIntensity / 2).ceil()
                            ? emotion.color
                            : AppColors.divider,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Overflow menu
                  _OverflowMenu(entry: entry),
                ],
              ),
              const SizedBox(height: 10),

              // ── Content preview ────────────────────────────────────────
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),

              // ── Timestamp ──────────────────────────────────────────────
              Text(
                entry.createdAt.toDisplayDateTime(locale),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DiaryFormPage(existing: entry),
      ),
    );
  }
}

class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu({required this.entry});

  final DiaryEntryEntity entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_Action>(
      icon: const Icon(Icons.more_vert,
          size: 18, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) async {
        switch (action) {
          case _Action.edit:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DiaryFormPage(existing: entry),
              ),
            );
          case _Action.delete:
            _confirmDelete(context, ref);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _Action.edit,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 8),
              Text('common.edit'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: _Action.delete,
          child: Row(
            children: [
              const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.error),
              const SizedBox(width: 8),
              Text('common.delete'.tr(),
                  style: const TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('diary.delete_title'.tr()),
        content: Text('diary.delete_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && entry.id != null) {
      await ref.read(diaryMutationProvider.notifier).delete(entry.id!);
    }
  }
}

enum _Action { edit, delete }
