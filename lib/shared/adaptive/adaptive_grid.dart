import 'dart:math' as math;

/// 统一的自适应网格策略，避免各处重复写计算逻辑。
class AdaptiveGrid {
  const AdaptiveGrid._();

  /// 根据可用宽度计算列数，默认适配移动/平板/桌面三档。
  ///
  /// [minCount] 和 [maxCount] 控制列数上下限，便于在特殊场景（如小组件）收紧范围。
  static int crossAxisCount(
    double width, {
    int minCount = 2,
    int maxCount = 6,
    double itemExtent = 72,
    double gap = 12,
  }) {
    final effectiveWidth = math.max<double>(width, itemExtent + gap);
    final count = (effectiveWidth / (itemExtent + gap)).floor();
    return count.clamp(minCount, maxCount);
  }
}
