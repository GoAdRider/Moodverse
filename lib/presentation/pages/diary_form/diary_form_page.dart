import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/diary_entry_entity.dart';
import '../../../domain/entities/emotion_type.dart';
import '../../providers/diary_providers.dart';
import 'widgets/emotion_selector_widget.dart';
import 'widgets/intensity_slider_widget.dart';

/// Used for both creating and editing a diary entry.
/// Pass [existing] to enter edit mode.
class DiaryFormPage extends ConsumerStatefulWidget {
  const DiaryFormPage({super.key, this.existing});

  final DiaryEntryEntity? existing;

  @override
  ConsumerState<DiaryFormPage> createState() => _DiaryFormPageState();
}

class _DiaryFormPageState extends ConsumerState<DiaryFormPage> {
  late final TextEditingController _contentController;
  late EmotionType _emotion;
  late int _intensity;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _contentController =
        TextEditingController(text: widget.existing?.content ?? '');
    _emotion = widget.existing?.emotion ?? EmotionType.neutral;
    _intensity = widget.existing?.emotionIntensity ?? 5;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('diary.content_required'.tr())),
      );
      return;
    }

    final notifier = ref.read(diaryMutationProvider.notifier);

    if (_isEditing) {
      await notifier.update(
        widget.existing!.copyWith(
          content: content,
          emotion: _emotion,
          emotionIntensity: _intensity,
        ),
      );
    } else {
      await notifier.create(
        content: content,
        emotion: _emotion,
        intensity: _intensity,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(diaryMutationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'diary.edit_title'.tr() : 'diary.new_title'.tr(),
        ),
        actions: [
          if (mutation.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: Text(
                'common.save'.tr(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Emotion selector ─────────────────────────────────────────
            EmotionSelectorWidget(
              selected: _emotion,
              onChanged: (e) => setState(() => _emotion = e),
            ),
            const SizedBox(height: 24),

            // ── Intensity slider ─────────────────────────────────────────
            IntensitySliderWidget(
              value: _intensity,
              onChanged: (v) => setState(() => _intensity = v),
            ),
            const SizedBox(height: 24),

            // ── Content text field ───────────────────────────────────────
            Text(
              'diary.content_label'.tr(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 8,
              minLines: 5,
              decoration: InputDecoration(
                hintText: 'diary.content_hint'.tr(),
                alignLabelWithHint: true,
              ),
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 32),

            // ── Submit button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mutation.isLoading ? null : _submit,
                child: Text(
                  _isEditing
                      ? 'diary.update_btn'.tr()
                      : 'diary.save_btn'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
