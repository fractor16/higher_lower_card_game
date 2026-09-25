import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../theme/app_theme.dart';

/// Renders an authentic, visually stunning playing card (front or back).
class PlayingCardWidget extends StatelessWidget {
  final PlayingCard? card;
  final bool showBack;
  final double width;
  final double? height;
  final bool isHighlighted;

  const PlayingCardWidget({
    super.key,
    this.card,
    this.showBack = false,
    this.width = 200,
    this.height,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = height ?? (width * 1.42); // standard 2.5 x 3.5 card ratio
    final borderRadius = BorderRadius.circular(width * 0.08);

    return Container(
      width: width,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? AppTheme.gold.withValues(alpha: 0.6)
                : AppTheme.cardShadow,
            blurRadius: isHighlighted ? 20 : 16,
            spreadRadius: isHighlighted ? 3 : 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: showBack || card == null
            ? _buildCardBack(width, cardHeight)
            : _buildCardFront(context, card!, width, cardHeight),
      ),
    );
  }

  Widget _buildCardFront(
      BuildContext context, PlayingCard card, double w, double h) {
    final textColor = card.color;
    final fontSizeCorner = w * 0.13;
    final suitSizeCorner = w * 0.11;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardFront,
        border: Border.all(
          color: isHighlighted ? AppTheme.gold : AppTheme.cardBorder,
          width: isHighlighted ? 2.5 : 1.2,
        ),
      ),
      child: Stack(
        children: [
          // Subtle inner filigree border
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(w * 0.04),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w * 0.05),
                  border: Border.all(
                    color: card.suit.isRed
                        ? const Color(0x18E53935)
                        : const Color(0x181E293B),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

          // Top Left Pip
          Positioned(
            top: h * 0.035,
            left: w * 0.055,
            child: _CornerPip(
              label: card.label,
              suitSymbol: card.suitSymbol,
              color: textColor,
              fontSize: fontSizeCorner,
              suitSize: suitSizeCorner,
            ),
          ),

          // Bottom Right Pip (Rotated 180 degrees)
          Positioned(
            bottom: h * 0.035,
            right: w * 0.055,
            child: Transform.rotate(
              angle: math.pi,
              child: _CornerPip(
                label: card.label,
                suitSymbol: card.suitSymbol,
                color: textColor,
                fontSize: fontSizeCorner,
                suitSize: suitSizeCorner,
              ),
            ),
          ),

          // Center Card Art
          Center(
            child: _buildCenterArt(card, w, h),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterArt(PlayingCard card, double w, double h) {
    if (card.rank == CardRank.ace) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.suitSymbol,
            style: TextStyle(
              fontSize: w * 0.40,
              color: card.color,
              height: 1,
              shadows: [
                Shadow(
                  color: card.color.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.01),
          Text(
            'ACE',
            style: TextStyle(
              fontSize: w * 0.09,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: card.color.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
    }

    if (card.rank == CardRank.jack ||
        card.rank == CardRank.queen ||
        card.rank == CardRank.king) {
      // Elegant court card badge
      return Container(
        width: w * 0.58,
        height: h * 0.46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(w * 0.06),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.suit.isRed
                ? [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)]
                : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
          ),
          border: Border.all(
            color: AppTheme.goldDark.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              card.rank == CardRank.king
                  ? Icons.military_tech_rounded
                  : (card.rank == CardRank.queen
                      ? Icons.workspace_premium_rounded
                      : Icons.shield_rounded),
              size: w * 0.20,
              color: AppTheme.goldDark,
            ),
            SizedBox(height: h * 0.01),
            Text(
              card.label,
              style: TextStyle(
                fontSize: w * 0.16,
                fontWeight: FontWeight.w900,
                color: card.color,
                height: 1,
              ),
            ),
            Text(
              card.suitSymbol,
              style: TextStyle(
                fontSize: w * 0.12,
                color: card.color,
                height: 1.1,
              ),
            ),
          ],
        ),
      );
    }

    // Number cards
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          card.suitSymbol,
          style: TextStyle(
            fontSize: w * 0.30,
            color: card.color,
            height: 1,
          ),
        ),
        Text(
          card.label,
          style: TextStyle(
            fontSize: w * 0.18,
            fontWeight: FontWeight.bold,
            color: card.color,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack(double w, double h) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackBase,
        border: Border.all(color: Colors.white, width: w * 0.035),
      ),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(w * 0.04),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(w * 0.04),
            border: Border.all(color: AppTheme.cardBackAccent, width: 2),
            gradient: const RadialGradient(
              colors: [
                Color(0xFF2C5282),
                Color(0xFF1A365D),
                Color(0xFF0F172A),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _CardBackPatternPainter(),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(w * 0.08),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: AppTheme.gold, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Icon(
                  Icons.casino_rounded,
                  color: AppTheme.gold,
                  size: w * 0.20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerPip extends StatelessWidget {
  final String label;
  final String suitSymbol;
  final Color color;
  final double fontSize;
  final double suitSize;

  const _CornerPip({
    required this.label,
    required this.suitSymbol,
    required this.color,
    required this.fontSize,
    required this.suitSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        Text(
          suitSymbol,
          style: TextStyle(
            color: color,
            fontSize: suitSize,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _CardBackPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.cardBackAccent.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const step = 16.0;
    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(i + size.height, 0),
        Offset(i, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
