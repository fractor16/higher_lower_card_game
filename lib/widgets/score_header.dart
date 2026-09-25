import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScoreHeader extends StatelessWidget {
  final int score;
  final int currentStreak;
  final int bestStreak;
  final int remainingCards;
  final VoidCallback onReset;
  final VoidCallback? onHelp;

  const ScoreHeader({
    super.key,
    required this.score,
    required this.currentStreak,
    required this.bestStreak,
    required this.remainingCards,
    required this.onReset,
    this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.glassSurfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.style_rounded,
                      color: AppTheme.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'HIGHER OR LOWER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (onHelp != null)
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, size: 20),
                      color: Colors.white70,
                      tooltip: 'Game Rules',
                      onPressed: onHelp,
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    color: AppTheme.gold,
                    tooltip: 'Restart Deck',
                    onPressed: onReset,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Stats Chips Row
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(
                label: 'SCORE',
                value: '$score',
                icon: Icons.stars_rounded,
                color: AppTheme.gold,
              ),
              _buildStatChip(
                label: 'STREAK',
                value: '$currentStreak',
                icon: Icons.local_fire_department_rounded,
                color: currentStreak >= 3 ? Colors.orangeAccent : Colors.white70,
                isPulsing: currentStreak >= 3,
              ),
              _buildStatChip(
                label: 'BEST',
                value: '$bestStreak',
                icon: Icons.emoji_events_rounded,
                color: AppTheme.goldLight,
              ),
              _buildStatChip(
                label: 'CARDS LEFT',
                value: '$remainingCards',
                icon: Icons.layers_rounded,
                color: remainingCards <= 5 ? Colors.redAccent : Colors.lightBlueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isPulsing = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.glassSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPulsing ? color : AppTheme.glassBorder,
          width: isPulsing ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Colors.white60,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
