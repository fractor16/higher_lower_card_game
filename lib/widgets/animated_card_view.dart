import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/game_state.dart';
import 'playing_card_widget.dart';
import '../theme/app_theme.dart';

class AnimatedCardView extends StatefulWidget {
  final PlayingCard? currentCard;
  final PlayingCard? previousCard;
  final PredictionResult? lastResult;
  final bool isProcessing;
  final VoidCallback onAnimationComplete;
  final double cardWidth;

  const AnimatedCardView({
    super.key,
    required this.currentCard,
    required this.previousCard,
    required this.lastResult,
    required this.isProcessing,
    required this.onAnimationComplete,
    this.cardWidth = 220,
  });

  @override
  State<AnimatedCardView> createState() => _AnimatedCardViewState();
}

class _AnimatedCardViewState extends State<AnimatedCardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;

  PlayingCard? _revealedCard;
  PlayingCard? _displayedPreviousCard;

  @override
  void initState() {
    super.initState();
    _revealedCard = widget.currentCard;
    _displayedPreviousCard = widget.previousCard;

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 50),
    ]).animate(_flipController);

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When a new card is drawn
    if (widget.currentCard != oldWidget.currentCard && widget.currentCard != null) {
      _displayedPreviousCard = oldWidget.currentCard;
      _revealedCard = widget.currentCard;
      _flipController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.cardWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Comparison Arena: Previous Card slot + Main Card
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Previous card mini-slot
            if (_displayedPreviousCard != null) ...[
              _buildPreviousCardSlot(width * 0.45),
              SizedBox(width: width * 0.08),
              _buildVsIndicator(),
              SizedBox(width: width * 0.08),
            ],

            // Main Active Card (with 3D Flip)
            _buildMainCardArea(width),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviousCardSlot(double slotWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.glassSurfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: const Text(
            'PREVIOUS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: 0.85,
          child: PlayingCardWidget(
            card: _displayedPreviousCard,
            width: slotWidth,
            showBack: false,
          ),
        ),
      ],
    );
  }

  Widget _buildVsIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.glassSurfaceDark,
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        size: 18,
        color: AppTheme.gold,
      ),
    );
  }

  Widget _buildMainCardArea(double width) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
          ),
          child: const Text(
            'CURRENT CARD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.gold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final value = _flipAnimation.value;
            // Angle rotates from 0 to 180 degrees (pi)
            final angle = value * math.pi;
            final isBack = angle > (math.pi / 2);

            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateY(angle),
                child: isBack
                    // When past 90 degrees, show the revealed front card (rotated back so it's not mirrored)
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: PlayingCardWidget(
                          card: _revealedCard,
                          width: width,
                          showBack: false,
                          isHighlighted: true,
                        ),
                      )
                    // First half: show the card back or previous state
                    : PlayingCardWidget(
                        card: _displayedPreviousCard ?? _revealedCard,
                        width: width,
                        showBack: _displayedPreviousCard != null,
                        isHighlighted: false,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
