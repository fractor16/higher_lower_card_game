import 'package:flutter_test/flutter_test.dart';
import 'package:higher_lower_card_game/models/card_model.dart';
import 'package:higher_lower_card_game/game/deck.dart';

void main() {
  group('PlayingCard Model Tests', () {
    test('Card has proper attributes and comparison logic', () {
      const kingHearts = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king);
      const aceSpades = PlayingCard(suit: CardSuit.spades, rank: CardRank.ace);
      const twoClubs = PlayingCard(suit: CardSuit.clubs, rank: CardRank.two);
      const kingDiamonds = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.king);

      expect(kingHearts.value, 13);
      expect(aceSpades.value, 14);
      expect(twoClubs.value, 2);

      expect(aceSpades.compareTo(kingHearts), greaterThan(0));
      expect(twoClubs.compareTo(kingHearts), lessThan(0));
      expect(kingHearts.compareTo(kingDiamonds), 0); // Same rank value

      expect(kingHearts == const PlayingCard(suit: CardSuit.hearts, rank: CardRank.king), isTrue);
      expect(kingHearts == kingDiamonds, isFalse); // Different suits
    });
  });

  group('Deck Tests', () {
    test('Deck initializes with exactly 52 cards', () {
      final deck = Deck();
      expect(deck.remainingCards, 52);
    });

    test('Deck has no duplicate cards', () {
      final deck = Deck();
      final seen = <PlayingCard>{};
      while (deck.isNotEmpty) {
        final card = deck.draw();
        expect(seen.contains(card), isFalse, reason: 'Duplicate card found: $card');
        seen.add(card);
      }
      expect(seen.length, 52);
    });

    test('Drawing cards reduces count by 1 and throws when empty', () {
      final deck = Deck();
      expect(deck.remainingCards, 52);
      final c1 = deck.draw();
      expect(c1, isNotNull);
      expect(deck.remainingCards, 51);

      // Draw all remaining
      for (var i = 0; i < 51; i++) {
        deck.draw();
      }
      expect(deck.isEmpty, isTrue);
      expect(deck.remainingCards, 0);

      expect(() => deck.draw(), throwsA(isA<StateError>()));
    });

    test('Reset recreates all 52 cards', () {
      final deck = Deck();
      deck.draw();
      deck.draw();
      expect(deck.remainingCards, 50);

      deck.reset();
      expect(deck.remainingCards, 52);
    });
  });
}
