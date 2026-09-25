import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';

class GameOverDialog extends StatelessWidget {
  final int finalScore;
  final int finalStreak;
  final int bestStreak;
  final int cardsPlayed;
  final GameOverReason? reason;
  final VoidCallback onPlayAgain;

  const GameOverDialog({
    super.key,
    required this.finalScore,
    required this.finalStreak,
    required this.bestStreak,
    required this.cardsPlayed,
    required this.reason,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final isVictory = reason == GameOverReason.deckCompleted;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF0C241B),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isVictory ? AppTheme.gold : AppTheme.wrongRed,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isVictory
                  ? AppTheme.gold.withValues(alpha: 0.35)
                  : AppTheme.wrongRed.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isVictory
                      ? AppTheme.gold.withValues(alpha: 0.2)
                      : AppTheme.wrongRed.withValues(alpha: 0.2),
                  border: Border.all(
                    color: isVictory ? AppTheme.gold : AppTheme.wrongRed,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isVictory ? Icons.emoji_events_rounded : Icons.heart_broken_rounded,
                  size: 44,
                  color: isVictory ? AppTheme.gold : AppTheme.wrongRed,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isVictory ? 'DECK COMPLETED!' : 'GAME OVER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: isVictory ? AppTheme.gold : Colors.white,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle Reason
              Text(
                isVictory
                    ? 'Incredible! You navigated all 52 cards!'
                    : 'A wrong prediction broke your streak.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),

              // Stats Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      label: 'Final Score',
                      value: '$finalScore PTS',
                      valueColor: AppTheme.gold,
                      icon: Icons.stars_rounded,
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    _buildStatRow(
                      label: 'Best Streak',
                      value: '$bestStreak Cards',
                      valueColor: AppTheme.goldLight,
                      icon: Icons.local_fire_department_rounded,
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    _buildStatRow(
                      label: 'Cards Played',
                      value: '$cardsPlayed / 52',
                      valueColor: Colors.lightBlueAccent,
                      icon: Icons.style_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PLAY AGAIN Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('btn_play_again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: AppTheme.gold.withValues(alpha: 0.5),
                  ),
                  onPressed: onPlayAgain,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.replay_rounded, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'PLAY AGAIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.white60),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
