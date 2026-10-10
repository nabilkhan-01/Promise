import 'package:flutter/material.dart';

/// A customizable IconButton that seamlessly transitions its icon into an
/// indicator (e.g., loading spinner, success checkmark, badge, or custom widget)
/// and optional text label using implicit animations.
class IndicatorIconButton extends StatelessWidget {
  const IndicatorIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.selectedIcon,
    this.label,
    this.indicator,
    this.isSelected = false,
    this.isLoading = false,
    this.showSuccessIndicator = false,
    this.indicatorColor,
    this.style,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = true,
    this.constraints,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOutCubic,
  });

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Default icon to display.
  final Widget icon;

  /// Optional icon to display when [isSelected] is true.
  final Widget? selectedIcon;

  /// Optional label widget or text shown alongside the icon.
  final Widget? label;

  /// Custom indicator widget shown during [isLoading] or state changes.
  /// If null, a stylized [CircularProgressIndicator] is used.
  final Widget? indicator;

  /// Whether the button is in a selected/active state.
  final bool isSelected;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether to show a momentary success checkmark indicator.
  final bool showSuccessIndicator;

  /// Custom color for the default progress indicator.
  final Color? indicatorColor;

  /// Button styling override matching standard [IconButton.style].
  final ButtonStyle? style;

  /// Text tooltip for accessibility and desktop/web hover.
  final String? tooltip;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Whether this control will attempt to default focus itself.
  final bool autofocus;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  final bool enableFeedback;

  /// Optional sizing constraints.
  final BoxConstraints? constraints;

  /// Custom padding for the button.
  final EdgeInsetsGeometry? padding;

  /// Duration for the state transition animations.
  final Duration animationDuration;

  /// Curve for the state transition animations.
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget currentContent;
    Key contentKey;

    if (isLoading) {
      contentKey = const ValueKey('loading');
      currentContent = _buildLoadingIndicator(theme);
    } else if (showSuccessIndicator) {
      contentKey = const ValueKey('success');
      currentContent = _buildSuccessIndicator(theme);
    } else if (isSelected && selectedIcon != null) {
      contentKey = const ValueKey('selected');
      currentContent = selectedIcon!;
    } else {
      contentKey = const ValueKey('normal');
      currentContent = icon;
    }

    final animatedIcon = AnimatedSwitcher(
      duration: animationDuration,
      switchInCurve: animationCurve,
      switchOutCurve: animationCurve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: contentKey,
        child: currentContent,
      ),
    );

    Widget buttonChild;
    if (label != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          animatedIcon,
          const SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: animationDuration,
            curve: animationCurve,
            style: theme.textTheme.labelLarge!.copyWith(
              color: _getTextColor(theme),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            child: label!,
          ),
        ],
      );
    } else {
      buttonChild = animatedIcon;
    }

    return IconButton(
      onPressed: (isLoading || showSuccessIndicator) ? null : onPressed,
      isSelected: isSelected,
      style: style,
      tooltip: tooltip,
      focusNode: focusNode,
      autofocus: autofocus,
      enableFeedback: enableFeedback,
      constraints: constraints,
      padding: padding,
      icon: buttonChild,
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    if (indicator != null) return indicator!;

    final effectiveColor =
        indicatorColor ??
        (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary);

    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }

  Widget _buildSuccessIndicator(ThemeData theme) {
    final effectiveColor = indicatorColor ?? Colors.green.shade600;

    return Icon(
      Icons.check_circle,
      size: 20,
      color: effectiveColor,
    );
  }

  Color? _getTextColor(ThemeData theme) {
    if (onPressed == null && !isLoading && !showSuccessIndicator) {
      return theme.colorScheme.onSurface.withValues(alpha: 0.38);
    }
    if (isSelected) {
      return theme.colorScheme.primary;
    }
    return theme.colorScheme.onSurface;
  }
}
