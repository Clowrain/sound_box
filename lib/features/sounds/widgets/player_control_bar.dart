import 'package:flutter/material.dart';

class PlayerControlBar extends StatelessWidget {
  const PlayerControlBar({
    super.key,
    required this.visible,
    required this.isAnyPlaying,
    required this.timerActive,
    required this.remainingTime,
    required this.onPlayAll,
    required this.onPauseAll,
    required this.onTimerPressed,
  });

  final bool visible;
  final bool isAnyPlaying;
  final bool timerActive;
  final Duration? remainingTime;
  final VoidCallback onPlayAll;
  final VoidCallback onPauseAll;
  final VoidCallback onTimerPressed;

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final buttonIcon = isAnyPlaying
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFF04070F), Color(0xBB050918), Color(0x00050918)],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (remainingTime != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(_formatRemaining(remainingTime!)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimerButton(active: timerActive, onPressed: onTimerPressed),
                const SizedBox(width: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    minimumSize: const Size(72, 72),
                  ),
                  onPressed: isAnyPlaying ? onPauseAll : onPlayAll,
                  child: Icon(buttonIcon, size: 32),
                ),
                const SizedBox(width: 64),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 28,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white.withValues(alpha: 0.12),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white),
          if (active)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
