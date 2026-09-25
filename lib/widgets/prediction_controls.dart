import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';

class PredictionControls extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<Prediction> onPredict;

  const PredictionControls({
    super.key,
    required this.isEnabled,
    required this.onPredict,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // HIGHER Button
          Expanded(
            child: _PredictionButton(
              key: const ValueKey('btn_higher'),
              label: 'HIGHER',
              subtitle: 'Next card > Current',
              icon: Icons.arrow_upward_rounded,
              gradientColors: const [
                AppTheme.higherGreen,
                AppTheme.higherGreenDark,
              ],
              glowColor: AppTheme.higherGlow,
              isEnabled: isEnabled,
              onPressed: () => onPredict(Prediction.higher),
            ),
          ),
          const SizedBox(width: 16),

          // LOWER Button
          Expanded(
            child: _PredictionButton(
              key: const ValueKey('btn_lower'),
              label: 'LOWER',
              subtitle: 'Next card < Current',
              icon: Icons.arrow_downward_rounded,
              gradientColors: const [
                AppTheme.lowerRed,
                AppTheme.lowerRedDark,
              ],
              glowColor: AppTheme.lowerGlow,
              isEnabled: isEnabled,
              onPressed: () => onPredict(Prediction.lower),
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _PredictionButton({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  State<_PredictionButton> createState() => _PredictionButtonState();
}

class _PredictionButtonState extends State<_PredictionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.isEnabled) {
      _pressController.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.isEnabled) {
      _pressController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled) {
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1.0 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: enabled
                    ? widget.gradientColors
                    : [Colors.grey.shade700, Colors.grey.shade800],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: widget.glowColor,
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
              border: Border.all(
                color: enabled ? Colors.white30 : Colors.white10,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
