import 'package:flutter/material.dart';

enum CardSuit {
  hearts,
  diamonds,
  clubs,
  spades;

  String get symbol {
    switch (this) {
      case CardSuit.hearts:
        return '♥';
      case CardSuit.diamonds:
        return '♦';
      case CardSuit.clubs:
        return '♣';
      case CardSuit.spades:
        return '♠';
    }
  }

  String get displayName {
    switch (this) {
      case CardSuit.hearts:
        return 'Hearts';
      case CardSuit.diamonds:
        return 'Diamonds';
      case CardSuit.clubs:
        return 'Clubs';
      case CardSuit.spades:
        return 'Spades';
    }
  }

  Color get color {
    switch (this) {
      case CardSuit.hearts:
      case CardSuit.diamonds:
        return const Color(0xFFE53935); // Crimson Red
      case CardSuit.clubs:
      case CardSuit.spades:
        return const Color(0xFF1E293B); // Deep Slate
    }
  }

  bool get isRed => this == CardSuit.hearts || this == CardSuit.diamonds;
}

enum CardRank {
  two(2, '2', 'Two'),
  three(3, '3', 'Three'),
  four(4, '4', 'Four'),
  five(5, '5', 'Five'),
  six(6, '6', 'Six'),
  seven(7, '7', 'Seven'),
  eight(8, '8', 'Eight'),
  nine(9, '9', 'Nine'),
  ten(10, '10', 'Ten'),
  jack(11, 'J', 'Jack'),
  queen(12, 'Q', 'Queen'),
  king(13, 'K', 'King'),
  ace(14, 'A', 'Ace');

  const CardRank(this.value, this.label, this.displayName);

  final int value;
  final String label;
  final String displayName;
}

@immutable
class PlayingCard implements Comparable<PlayingCard> {
  final CardSuit suit;
  final CardRank rank;

  const PlayingCard({
    required this.suit,
    required this.rank,
  });

  int get value => rank.value;
  String get label => rank.label;
  String get suitSymbol => suit.symbol;
  Color get color => suit.color;
  String get name => '${rank.displayName} of ${suit.displayName}';
  String get shortCode => '$label$suitSymbol';

  @override
  int compareTo(PlayingCard other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  @override
  String toString() => '$name ($value)';
}
