import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sound_box/features/home/widgets/dot_matrix_clock.dart';

/// 首页大屏区域，包裹点阵时钟并统一样式。
class HomeDisplaySurface extends StatelessWidget {
  const HomeDisplaySurface({
    super.key,
    required this.nowListenable,
    this.minRows = 14,
    this.minColumns = 20,
  });

  /// 外部以 `ValueListenable` 输入时间，避免整页刷新。
  final ValueListenable<DateTime> nowListenable;
  final int minRows;
  final int minColumns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.35),
          width: 4,
        ),
        color: const Color(0xFF2D3344),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
          BoxShadow(color: Color(0x3310111A), blurRadius: 40, spreadRadius: 8),
        ],
      ),
      child: RepaintBoundary(
        // 时钟以局部重绘，避免拖慢其他控件。
        child: ValueListenableBuilder<DateTime>(
          valueListenable: nowListenable,
          builder: (_, now, __) {
            return DotMatrixClock(
              time: now,
              minRows: minRows,
              minColumns: minColumns,
            );
          },
        ),
      ),
    );
  }
}
