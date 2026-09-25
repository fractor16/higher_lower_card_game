import 'package:flutter/material.dart';
import '../game/higher_lower_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card_view.dart';
import '../widgets/prediction_controls.dart';
import '../widgets/result_overlay.dart';
import '../widgets/score_header.dart';
import 'game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  final HigherLowerController? controller;

  const GameScreen({super.key, this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final HigherLowerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HigherLowerController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0C241B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.gold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppTheme.gold),
            SizedBox(width: 8),
            Text(
              'How to Play',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _RuleItem(
                title: 'Goal',
                description:
                    'Predict if the next card will be HIGHER or LOWER in rank than the current card.',
              ),
              _RuleItem(
                title: 'Card Ranks',
                description:
                    '2 (Lowest) up to King (13), with Ace being Highest (14).',
              ),
              _RuleItem(
                title: 'Equal Rank Ties (Push)',
                description:
                    'If both cards have identical rank, it is a PUSH. Your streak is saved and you earn +5 bonus points!',
              ),
              _RuleItem(
                title: 'Scoring & Streaks',
                description:
                    '• Base guess: +10 pts\n• Streak 3+: 1.5x multiplier (+15 pts)\n• Streak 5+: 2.0x multiplier (+20 pts)',
              ),
              _RuleItem(
                title: 'Victory',
                description:
                    'Clear all 52 cards without breaking your streak to conquer the deck!',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'GOT IT',
              style: TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  AppTheme.backgroundRadial,
                  AppTheme.backgroundTop,
                  AppTheme.backgroundBottom,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Main Game Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Dynamically size the card based on available screen space
                      final availableHeight = constraints.maxHeight;
                      final availableWidth = constraints.maxWidth;
                      final isNarrow = availableWidth < 420;
                      final cardWidth = (availableWidth * 0.42)
                          .clamp(140.0, availableHeight > 700 ? 210.0 : 170.0);

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isNarrow ? 12.0 : 20.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top Header
                                ScoreHeader(
                                  score: _controller.score,
                                  currentStreak: _controller.currentStreak,
                                  bestStreak: _controller.bestStreak,
                                  remainingCards: _controller.remainingCards,
                                  onReset: _controller.startNewGame,
                                  onHelp: _showRulesDialog,
                                ),

                                // Result Banner
                                ResultOverlay(
                                  result: _controller.lastResult,
                                  prediction: _controller.lastPrediction,
                                  currentStreak: _controller.currentStreak,
                                  multiplier: _controller.streakMultiplier,
                                ),

                                // Card Arena
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      physics: const ClampingScrollPhysics(),
                                      child: AnimatedCardView(
                                        cardWidth: cardWidth,
                                        currentCard: _controller.currentCard,
                                        previousCard: _controller.previousCard,
                                        lastResult: _controller.lastResult,
                                        isProcessing: _controller.isProcessing,
                                        onAnimationComplete: _controller.finishAnimation,
                                      ),
                                    ),
                                  ),
                                ),

                                // Controls
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                                  child: PredictionControls(
                                    isEnabled: _controller.canPredict,
                                    onPredict: (prediction) {
                                      _controller.predict(prediction);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Game Over Modal Overlay
                  if (_controller.isGameOver)
                    Container(
                      color: Colors.black.withValues(alpha: 0.75),
                      child: Center(
                        child: GameOverDialog(
                          finalScore: _controller.score,
                          finalStreak: _controller.currentStreak,
                          bestStreak: _controller.bestStreak,
                          cardsPlayed: _controller.cardsPlayed,
                          reason: _controller.gameOverReason,
                          onPlayAgain: _controller.startNewGame,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String title;
  final String description;

  const _RuleItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
