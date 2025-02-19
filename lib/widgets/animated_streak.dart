import 'package:flutter/material.dart';

class AnimatedStreakText extends StatefulWidget {
  @override
  _AnimatedStreakTextState createState() => _AnimatedStreakTextState();
}

class _AnimatedStreakTextState extends State<AnimatedStreakText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true); // Efekt pulsowania

    _opacityAnimation =
        Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Wycentrowanie tekstu
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [Colors.red, Colors.orange, Colors.yellow],
                stops: [0.2, 0.5, 0.8],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn, // Nakładanie koloru na tekst
            child: Opacity(
              opacity: _opacityAnimation.value, // Efekt pulsowania
              child: Text(
                "🔥 Streak 🔥",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
