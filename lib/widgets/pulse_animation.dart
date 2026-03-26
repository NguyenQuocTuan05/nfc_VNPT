import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PulseAnimation extends StatefulWidget {
  final bool isScanning;
  final Widget child;

  const PulseAnimation({
    super.key,
    required this.isScanning,
    required this.child,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late List<AnimationController> _rippleControllers;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _rippleControllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      );
    });

    if (widget.isScanning) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();

    for (int i = 0; i < _rippleControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 600), () {
        if (mounted) {
          _rippleControllers[i].repeat();
        }
      });
    }
  }

  void _stopAnimations() {
    _pulseController.stop();
    _rotateController.stop();
    for (final controller in _rippleControllers) {
      controller.stop();
    }
  }

  @override
  void didUpdateWidget(covariant PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _startAnimations();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    for (final controller in _rippleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple effects
          ..._rippleControllers.map((controller) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Container(
                  width: 180 + (80 * controller.value),
                  height: 180 + (80 * controller.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBlue
                          .withValues(alpha: (1 - controller.value) * 0.4),
                      width: 2,
                    ),
                  ),
                );
              },
            );
          }),
          // Rotating gradient ring
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * pi,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.0),
                        AppColors.primaryBlue.withValues(alpha: 0.6),
                        AppColors.primaryPurple.withValues(alpha: 0.6),
                        AppColors.accentCyan.withValues(alpha: 0.3),
                        AppColors.primaryBlue.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner dark circle
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.05);
              return Transform.scale(
                scale: widget.isScanning ? scale : 1.0,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkBg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: widget.isScanning ? 0.3 : 0.1),
                        blurRadius: widget.isScanning ? 30 : 10,
                        spreadRadius: widget.isScanning ? 5 : 0,
                      ),
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: widget.isScanning ? 0.2 : 0.05),
                        blurRadius: widget.isScanning ? 40 : 15,
                        spreadRadius: widget.isScanning ? 10 : 0,
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
