import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResourceProgressBar extends StatefulWidget {
  final String resourceName;
  final double currentSupply;
  final double milestoneTarget;
  final Color progressBarColor;
  final String unit;

  const ResourceProgressBar({
    Key? key,
    required this.resourceName,
    required this.currentSupply,
    required this.milestoneTarget,
    required this.progressBarColor,
    this.unit = 'days',
  }) : super(key: key);

  @override
  _ResourceProgressBarState createState() => _ResourceProgressBarState();
}

class _ResourceProgressBarState extends State<ResourceProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800), // Adjusted: 1500ms * 1.2 = 1800ms
      vsync: this,
    );

    final initialProgress = _calculateProgress();

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: initialProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic, // Accelerates/decelerates
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ResourceProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentSupply != oldWidget.currentSupply ||
        widget.milestoneTarget != oldWidget.milestoneTarget) {
      final newProgress = _calculateProgress();
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value, // Animate from current animated value
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  double _calculateProgress() {
    if (widget.milestoneTarget <= 0) {
      return 0.0;
    }
    return math.min(widget.currentSupply / widget.milestoneTarget, 1.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displaySupply = widget.currentSupply.toStringAsFixed(1);
    final displayTarget = widget.milestoneTarget.toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.resourceName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$displaySupply / $displayTarget ${widget.unit}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(_calculateProgress() * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: widget.progressBarColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    minHeight: 12.0,
                    backgroundColor: widget.progressBarColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.progressBarColor),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}