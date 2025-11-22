import 'package:flutter/material.dart';
import 'package:sound_box/features/home/widgets/home_square_button.dart';

/// 首页主要操作区，包括“音效”和“设置”入口按钮。
class HomePrimaryActions extends StatelessWidget {
  const HomePrimaryActions({
    super.key,
    required this.onSoundTap,
    this.onSettingsTap,
    required this.breathingProgress,
    required this.activeBreathingIds,
    required this.onBreathingChanged,
  });

  /// “音效”按钮点击回调。
  final VoidCallback onSoundTap;

  /// “设置”按钮回调，未指定时与音效入口保持一致。
  final VoidCallback? onSettingsTap;
  final Animation<double>? breathingProgress;
  final Set<String> activeBreathingIds;
  final void Function(String id, bool active) onBreathingChanged;

  static const String _soundButtonId = 'primary_sound';
  static const String _settingsButtonId = 'primary_settings';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HomeSquareButton(
            label: '音效',
            icon: Icons.graphic_eq,
            onTap: onSoundTap,
            breathingProgress: breathingProgress,
            isBreathing: activeBreathingIds.contains(_soundButtonId),
            onBreathingChanged: (active) =>
                onBreathingChanged(_soundButtonId, active),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HomeSquareButton(
            label: '设置',
            icon: Icons.settings_outlined,
            onTap: onSettingsTap ?? onSoundTap,
            breathingProgress: breathingProgress,
            isBreathing: activeBreathingIds.contains(_settingsButtonId),
            onBreathingChanged: (active) =>
                onBreathingChanged(_settingsButtonId, active),
          ),
        ),
      ],
    );
  }
}
