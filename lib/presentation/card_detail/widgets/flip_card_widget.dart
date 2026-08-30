import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/haptics_provider.dart';

/// A hand-rolled 3D perspective flip between [front] and [back]. Swap
/// happens at the halfway point of the rotation so each face is only ever
/// shown right-reading (the back is pre-mirrored so it isn't shown
/// backwards while rotating past 90 degrees).
class FlipCardWidget extends ConsumerStatefulWidget {
  const FlipCardWidget({super.key, required this.front, required this.back});

  final Widget front;
  final Widget back;

  @override
  ConsumerState<FlipCardWidget> createState() => FlipCardWidgetState();
}

class FlipCardWidgetState extends ConsumerState<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get isShowingFront => _controller.value < 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    ref.read(hapticsServiceProvider).lightImpact();
    if (isShowingFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final showFront = angle < math.pi / 2;

          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          if (showFront) {
            return Transform(
              alignment: Alignment.center,
              transform: transform,
              child: widget.front,
            );
          }

          final backTransform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle - math.pi);
          return Transform(
            alignment: Alignment.center,
            transform: backTransform,
            child: widget.back,
          );
        },
      ),
    );
  }
}
