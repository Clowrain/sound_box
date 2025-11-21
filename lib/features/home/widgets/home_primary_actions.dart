import 'package:flutter/material.dart';
import 'package:sound_box/features/home/widgets/home_square_button.dart';

/// 首页主要操作区，包括“音效”和“设置”入口按钮。
class HomePrimaryActions extends StatelessWidget {
  const HomePrimaryActions({
    super.key,
    required this.onSoundTap,
    this.onSettingsTap,
  });

  /// “音效”按钮点击回调。
  final VoidCallback onSoundTap;

  /// “设置”按钮回调，未指定时与音效入口保持一致。
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HomeSquareButton(
            label: '音效',
            icon: Icons.graphic_eq,
            onTap: onSoundTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HomeSquareButton(
            label: '设置',
            icon: Icons.settings_outlined,
            onTap: onSettingsTap ?? onSoundTap,
          ),
        ),
      ],
    );
  }
}
