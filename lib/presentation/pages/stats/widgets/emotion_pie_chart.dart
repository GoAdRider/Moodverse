import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/emotion_type.dart';

class EmotionPieChart extends StatefulWidget {
  const EmotionPieChart({super.key, required this.counts});

  final Map<EmotionType, int> counts;

  @override
  State<EmotionPieChart> createState() => _EmotionPieChartState();
}

class _EmotionPieChartState extends State<EmotionPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.counts.isEmpty) {
      return Center(child: Text('stats.no_data'.tr()));
    }

    final total = widget.counts.values.fold(0, (a, b) => a + b);
    final sections = _buildSections(total);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex =
                          response!.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.counts.entries.map((e) {
            final pct = (e.value / total * 100).toStringAsFixed(1);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: e.key.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${e.key.emoji} ${e.key.translationKey.tr()} $pct%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(int total) {
    final entries = widget.counts.entries.toList();
    return List.generate(entries.length, (i) {
      final e = entries[i];
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;
      final pct = e.value / total * 100;

      return PieChartSectionData(
        color: e.key.color,
        value: e.value.toDouble(),
        title: '${pct.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    });
  }
}
