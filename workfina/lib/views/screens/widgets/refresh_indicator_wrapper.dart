import 'package:flutter/material.dart';
import 'dart:math' as math;

class RefreshIndicatorWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollPhysics? physics;

  const RefreshIndicatorWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      strokeWidth: 2.5,
      displacement: 50,
      child: child,
    );
  }
}

class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    _controller.repeat();
    
    try {
      await widget.onRefresh();
    } finally {
      _controller.stop();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: Colors.transparent,
      color: Colors.transparent,
      strokeWidth: 0,
      displacement: 50,
      // Custom indicator builder
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      edgeOffset: 0,
      child: widget.child,
    );
  }
}

class TealCircularIndicator extends StatefulWidget {
  final double size;
  
  const TealCircularIndicator({
    super.key,
    this.size = 24.0,
  });

  @override
  State<TealCircularIndicator> createState() => _TealCircularIndicatorState();
}

class _TealCircularIndicatorState extends State<TealCircularIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: TealCircularPainter(
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class TealCircularPainter extends CustomPainter {
  final double progress;
  
  TealCircularPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    
    // Background circle (light teal)
    final backgroundPaint = Paint()
      ..color = const Color(0xFF4DD0E1).withOpacity(0.2)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc (teal)
    final progressPaint = Paint()
      ..color = const Color(0xFF00ACC1)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final startAngle = -math.pi / 2 + (progress * 2 * math.pi);
    const sweepAngle = math.pi * 1.5; // 3/4 of a circle
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}