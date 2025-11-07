import 'package:flutter/material.dart';

class TimerSheetResult {
  const TimerSheetResult._({this.minutes, this.isCancel = false});

  final int? minutes;
  final bool isCancel;

  factory TimerSheetResult.minutes(int value) =>
      TimerSheetResult._(minutes: value);

  factory TimerSheetResult.cancel() =>
      const TimerSheetResult._(minutes: null, isCancel: true);
}

class TimerSheet extends StatelessWidget {
  const TimerSheet({super.key, this.activeMinutes});

  final int? activeMinutes;

  static Future<TimerSheetResult?> show(
    BuildContext context, {
    int? activeMinutes,
  }) {
    return showModalBottomSheet<TimerSheetResult>(
      context: context,
      backgroundColor: const Color(0xFF090D14),
      barrierColor: Colors.black54,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => TimerSheet(activeMinutes: activeMinutes),
    );
  }

  @override
  Widget build(BuildContext context) {
    const timerOptions = [5, 10, 15, 30, 45, 60, 90, 120];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Text('设置定时器', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            itemCount: timerOptions.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final minutes = timerOptions[index];
              final isActive = minutes == activeMinutes;
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                  backgroundColor: isActive
                      ? Colors.white.withValues(alpha: 0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(TimerSheetResult.minutes(minutes));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$minutes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '分钟',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),
          if (activeMinutes != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop(TimerSheetResult.cancel());
              },
              icon: const Icon(Icons.close),
              label: const Text('取消定时器'),
            ),
          ],
        ],
      ),
    );
  }
}
