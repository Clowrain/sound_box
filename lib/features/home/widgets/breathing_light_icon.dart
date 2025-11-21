import 'package:flutter/material.dart';

class BreathingLightIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  BreathingLightIcon({required this.icon, required this.color});

  @override
  _BreathingLightIconState createState() => _BreathingLightIconState();
}

class _BreathingLightIconState extends State<BreathingLightIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();

    // Create an AnimationController and set its duration
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4), // Set to 4 seconds for quick effect
    )..repeat(reverse: true); // Use the `repeat()` method to make it loop

    // Set up the color animation
    _animation =
        ColorTween(
          begin: widget.color.withOpacity(0.2), // Start with lower opacity
          end: widget.color.withOpacity(1), // End with full opacity
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut, // Smooth transition
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Icon(widget.icon, color: _animation.value);
      },
    );
  }
}
