import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';

class ResultOverlay extends StatelessWidget {
  final PredictionResult? result;
  final Prediction? prediction;
  final int currentStreak;
  final double multiplier;

  const ResultOverlay({
    super.key,
    required this.result,
    required this.prediction,
    required this.currentStreak,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Container(
        height: 52,
        alignment: Alignment.center,
        child: const Text(
          'Choose HIGHER or LOWER for the next card',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    Color bgColor;
    Color borderColor;
    IconData icon;
    String title;
    String subtitle;

    switch (result!) {
      case PredictionResult.correct:
        bgColor = AppTheme.correctGreen.withValues(alpha: 0.2);
        borderColor = AppTheme.correctGreen;
        icon = Icons.check_circle_rounded;
        title = 'CORRECT PREDICTION!';
        final pts = (10 * multiplier).round();
        subtitle = multiplier > 1.0
            ? '+$pts PTS (${multiplier}x Multiplier!) • Streak: $currentStreak 🔥'
            : '+$pts PTS • Streak: $currentStreak';
        break;

      case PredictionResult.wrong:
        bgColor = AppTheme.wrongRed.withValues(alpha: 0.2);
        borderColor = AppTheme.wrongRed;
        icon = Icons.cancel_rounded;
        title = 'WRONG PREDICTION!';
        subtitle = 'The card was not ${prediction?.label ?? 'as predicted'}. Game Over!';
        break;

      case PredictionResult.tie:
        bgColor = AppTheme.tieAmber.withValues(alpha: 0.2);
        borderColor = AppTheme.tieAmber;
        icon = Icons.handshake_rounded;
        title = 'EQUAL RANK TIE!';
        subtitle = 'PUSH! Streak protected & +5 PTS awarded!';
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: borderColor, size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: borderColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
