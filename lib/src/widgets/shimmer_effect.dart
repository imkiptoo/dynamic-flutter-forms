import 'package:flutter/material.dart';

/// A widget that displays a shimmer effect for loading placeholders.
class Shimmer extends StatefulWidget {
  /// The child widget to display the shimmer effect on.
  final Widget child;

  /// The base color of the shimmer effect.
  final Color baseColor;

  /// The highlight color of the shimmer effect.
  final Color highlightColor;

  /// The duration of the shimmer animation.
  final Duration duration;

  /// Whether to enable the shimmer effect.
  final bool enabled;

  /// Creates a [Shimmer] widget.
  ///
  /// [child] is the widget to display the shimmer effect on.
  /// [baseColor] is the base color of the shimmer effect.
  /// [highlightColor] is the highlight color of the shimmer effect.
  /// [duration] is the duration of the shimmer animation.
  /// [enabled] determines whether the shimmer effect is enabled.
  const Shimmer({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFFEBEBF4),
    this.highlightColor = const Color(0xFFF4F4F4),
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  }) : super(key: key);

  @override
  _ShimmerState createState() => _ShimmerState();

  /// Creates a widget that applies the shimmer effect to its child.
  static ShimmerBuilder builder({
    required BuildContext context,
    required Widget child,
    Color baseColor = const Color(0xFFEBEBF4),
    Color highlightColor = const Color(0xFFF4F4F4),
    Duration duration = const Duration(milliseconds: 1500),
    bool enabled = true,
  }) {
    return ShimmerBuilder(
      child: child,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      enabled: enabled,
    );
  }
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value, 0.0),
              end: Alignment(_animation.value + 1.0, 0.0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: child!,
        );
      },
    );
  }
}

/// A widget that builds a shimmer effect.
class ShimmerBuilder extends StatelessWidget {
  /// The child widget to display the shimmer effect on.
  final Widget child;

  /// The base color of the shimmer effect.
  final Color baseColor;

  /// The highlight color of the shimmer effect.
  final Color highlightColor;

  /// The duration of the shimmer animation.
  final Duration duration;

  /// Whether to enable the shimmer effect.
  final bool enabled;

  /// Creates a [ShimmerBuilder] widget.
  const ShimmerBuilder({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFFEBEBF4),
    this.highlightColor = const Color(0xFFF4F4F4),
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      enabled: enabled,
      child: child,
    );
  }
}