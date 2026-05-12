import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';

/// Primary CTA button that renders the purple→pink→blue gradient.
/// Matches: bg-gradient-to-r from-purple-600 via-pink-500 to-blue-500
/// Height: h-14 (56px)
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height,
    this.width,
    this.borderRadius,
    this.gradient,
    this.padding,
    this.disabled = false,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double? height;
  final double? width;
  final double? borderRadius;
  final LinearGradient? gradient;
  final EdgeInsetsGeometry? padding;
  final bool disabled;
  final bool isLoading;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.02,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppColors.primaryGradient;
    final isDisabled = widget.disabled || widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Container(
            height: widget.height ?? 56.h,
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppRadius.xl2,
              ),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Padding(
              padding: widget.padding ??
                  EdgeInsets.symmetric(horizontal: AppSpacing.base.w),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 24.r,
                        width: 24.r,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience text-only gradient button
class GradientTextButton extends StatelessWidget {
  const GradientTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height,
    this.disabled = false,
    this.isLoading = false,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? height;
  final bool disabled;
  final bool isLoading;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: onPressed,
      height: height,
      disabled: disabled,
      isLoading: isLoading,
      child: Text(
        label,
        style: AppTextStyles.button.copyWith(
          fontSize: fontSize,
        ),
      ),
    );
  }
}
