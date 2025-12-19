import 'dart:ui';

/// 单个按钮的配置（SVG 路径 + 呼吸颜色）
class BreathingIconConfig {
  /// 唯一 key，用于控制，例如 "moon" / "sun"
  final String keyId;

  /// SVG 地址 (与 iconData 二选一)
  final String? svgAsset;

  /// 呼吸颜色
  final Color breatheColor;

  final double? iconSize;
  final double? buttonSize;

  /// 点击回调
  final VoidCallback? onTap;

  const BreathingIconConfig({
    required this.keyId,
    this.svgAsset,
    required this.breatheColor,
    this.iconSize,
    this.buttonSize,
    this.onTap,
  }) : assert(svgAsset != null, 'Must provide either iconData or svgAsset');
}
