import 'package:flutter/material.dart';
import 'package:sound_box/features/home/widgets/breathing_light_icon.dart';
import 'package:sound_box/features/home/widgets/breathingIcon/breathing_svg_icon.dart';

/// 方形操作按钮，支持纯图标或图标+文字，点击后独立开启/关闭动画，仍共享同一动画值。
class HomeSquareButton extends StatelessWidget {
  const HomeSquareButton({
    super.key,
    this.svgAsset,
    this.icon,
    this.label,
    this.onTap,
    this.breathingProgress,
    this.iconColor,
    this.isBreathing = false,
    this.onBreathingChanged,
  });

  final IconData? icon;
  final String? svgAsset;
  final String? label;
  final VoidCallback? onTap;

  /// 共享的颜色动画，保证首页所有按钮的动画值一致。
  final Animation<double>? breathingProgress;

  /// 图标基准颜色，默认根据是否有文字判定黑/白。
  final Color? iconColor;

  /// 当前按钮是否处于呼吸动画状态。
  final bool isBreathing;

  /// 呼吸动画状态变更回调（模仿 FM 按钮的开/关）。
  final ValueChanged<bool>? onBreathingChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isIconOnly = (label == null) || label!.isEmpty;
    final Color resolvedIconColor =
        iconColor ?? (isIconOnly ? Colors.black : Colors.white);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          decoration: _outerDecoration(),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: _innerDecoration(),
            child: Center(
              child: isIconOnly
                  ? _buildIcon(resolvedIconColor)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIcon(resolvedIconColor, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          label!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color iconColor, {double size = 24}) {
    final shouldAnimate = isBreathing && breathingProgress != null;
    if (svgAsset != null) {
      final staticColor = Colors.white24;
      return BreathingSvgIcon(
        asset: svgAsset!,
        color: shouldAnimate ? iconColor : staticColor,
        size: size,
        isBreathing: shouldAnimate,
        progress: breathingProgress,
      );
    }
    if (icon == null) return const SizedBox.shrink();
    if (!shouldAnimate) {
      return Icon(icon, color: Colors.white24, size: size);
    }
    return BreathingLightIcon(
      icon: icon!,
      color: iconColor,
      size: size,
      animate: true,
      sharedProgress: breathingProgress,
    );
  }

  void _handleTap() {
    onBreathingChanged?.call(!isBreathing);
    onTap?.call();
  }

  /// 外层暗色渐变，强调立体边框。
  BoxDecoration _outerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2E3548), Color(0xFF171C28)],
      ),
      border: Border.all(color: Colors.black.withValues(alpha: 0.55), width: 2),
      boxShadow: const [
        BoxShadow(
          color: Colors.black54,
          offset: Offset(0, 10),
          blurRadius: 18,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Color(0x3329394D),
          offset: Offset(-2, -2),
          blurRadius: 8,
        ),
      ],
    );
  }

  /// 内层柔和渐变，便于后续按平台调整亮度。
  BoxDecoration _innerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF232838), Color(0xFF171C28)],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
    );
  }
}
