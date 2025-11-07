import 'dart:math';

import 'package:flutter/material.dart';

class DotMatrixClock extends StatelessWidget {
  const DotMatrixClock({
    super.key,
    required this.time,
    this.minColumns = 20,
    this.minRows = 12,
    this.dotSize = 6,
    this.gap = 2,
  });

  final DateTime time;
  final int minColumns;
  final int minRows;
  final double dotSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final formatted = _formatTime(time);
    final patterns = formatted.split('').map(_digitPattern).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final pixelPerDot = dotSize + gap;
        final columns = max(
          minColumns,
          (constraints.maxWidth / pixelPerDot).floor(),
        );
        final rows = max(
          minRows,
          (constraints.maxHeight / pixelPerDot).floor(),
        );

        return GridView.builder(
          itemCount: columns * rows,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ columns;
            final col = index % columns;
            final isLit = _isDotLit(
              row: row,
              column: col,
              rows: rows,
              columns: columns,
              patterns: patterns,
            );

            return AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLit
                    ? const Color(0xFFFFCA63)
                    : Colors.black.withValues(alpha: 0.35),
                boxShadow: isLit
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFFFFCA63,
                          ).withValues(alpha: 0.65),
                          blurRadius: 8,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static List<List<int>> _digitPattern(String digit) {
    return _patterns[digit] ?? _patterns['0']!;
  }

  bool _isDotLit({
    required int row,
    required int column,
    required int rows,
    required int columns,
    required List<List<List<int>>> patterns,
  }) {
    if (patterns.isEmpty) return false;

    final totalDigitWidth = patterns.fold<int>(
      -1,
      (sum, pattern) => sum + pattern.first.length + 1,
    );
    final scale = max(1, min(4, (columns / max(totalDigitWidth, 1)).floor()));
    final scaledWidth = totalDigitWidth * scale;
    final startColumn = ((columns - scaledWidth) / 2).floor();
    const digitHeight = 5;
    final scaledHeight = digitHeight * scale;
    final startRow = ((rows - scaledHeight) / 2).floor();

    if (row < startRow || row >= startRow + scaledHeight) return false;
    if (column < startColumn || column >= startColumn + scaledWidth) {
      return false;
    }

    final digitRow = ((row - startRow) / scale).floor();
    var currentColumn = startColumn;

    for (final pattern in patterns) {
      final digitWidth = pattern.first.length;
      final scaledDigitWidth = digitWidth * scale;
      if (column >= currentColumn &&
          column < currentColumn + scaledDigitWidth) {
        final digitCol = ((column - currentColumn) / scale).floor();
        return pattern[digitRow][digitCol] == 1;
      }
      currentColumn += scaledDigitWidth + scale;
    }

    return false;
  }
}

const _patterns = <String, List<List<int>>>{
  '0': [
    [1, 1, 1],
    [1, 0, 1],
    [1, 0, 1],
    [1, 0, 1],
    [1, 1, 1],
  ],
  '1': [
    [0, 1, 0],
    [1, 1, 0],
    [0, 1, 0],
    [0, 1, 0],
    [1, 1, 1],
  ],
  '2': [
    [1, 1, 1],
    [0, 0, 1],
    [1, 1, 1],
    [1, 0, 0],
    [1, 1, 1],
  ],
  '3': [
    [1, 1, 1],
    [0, 0, 1],
    [1, 1, 1],
    [0, 0, 1],
    [1, 1, 1],
  ],
  '4': [
    [1, 0, 1],
    [1, 0, 1],
    [1, 1, 1],
    [0, 0, 1],
    [0, 0, 1],
  ],
  '5': [
    [1, 1, 1],
    [1, 0, 0],
    [1, 1, 1],
    [0, 0, 1],
    [1, 1, 1],
  ],
  '6': [
    [1, 1, 1],
    [1, 0, 0],
    [1, 1, 1],
    [1, 0, 1],
    [1, 1, 1],
  ],
  '7': [
    [1, 1, 1],
    [0, 0, 1],
    [0, 0, 1],
    [0, 0, 1],
    [0, 0, 1],
  ],
  '8': [
    [1, 1, 1],
    [1, 0, 1],
    [1, 1, 1],
    [1, 0, 1],
    [1, 1, 1],
  ],
  '9': [
    [1, 1, 1],
    [1, 0, 1],
    [1, 1, 1],
    [0, 0, 1],
    [1, 1, 1],
  ],
  ':': [
    [0, 0, 0],
    [0, 1, 0],
    [0, 0, 0],
    [0, 1, 0],
    [0, 0, 0],
  ],
};
