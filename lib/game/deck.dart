import 'dart:math';
import '../models/card_model.dart';

class Deck {
  final List<PlayingCard> _cards = [];
  final Random _random;

  Deck({Random? random}) : _random = random ?? Random() {
    reset();
  }

  /// Initialize or reset the deck to a full, shuffled 52-card set.
  void reset() {
    _cards.clear();
    for (final suit in CardSuit.values) {
      for (final rank in CardRank.values) {
        _cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    shuffle();
  }

  /// Shuffle the remaining cards in the deck using Fisher-Yates shuffle.
  void shuffle() {
    for (var i = _cards.length - 1; i > 0; i--) {
      final n = _random.nextInt(i + 1);
      final temp = _cards[i];
      _cards[i] = _cards[n];
      _cards[n] = temp;
    }
  }

  /// Draws the top card from the deck.
  /// Throws [StateError] if the deck is empty.
  PlayingCard draw() {
    if (_cards.isEmpty) {
      throw StateError('Cannot draw from an empty deck.');
    }
    return _cards.removeLast();
  }

  /// Returns true if no cards remain.
  bool get isEmpty => _cards.isEmpty;

  /// Returns true if at least one card remains.
  bool get isNotEmpty => _cards.isNotEmpty;

  /// Number of cards remaining in the deck.
  int get remainingCards => _cards.length;

  /// Unmodifiable view of remaining cards for inspection/testing.
  List<PlayingCard> get cards => List.unmodifiable(_cards);
}
