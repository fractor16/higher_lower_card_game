import 'package:flutter_test/flutter_test.dart';
import 'package:higher_lower_card_game/game/deck.dart';
import 'package:higher_lower_card_game/game/higher_lower_controller.dart';
import 'package:higher_lower_card_game/models/card_model.dart';
import 'package:higher_lower_card_game/models/game_state.dart';

/// Test deck that yields cards in a predefined order.
class MockDeck extends Deck {
  final List<PlayingCard> customCards;
  int _index = 0;

  MockDeck(this.customCards);

  @override
  void reset() {
    _index = 0;
  }

  @override
  PlayingCard draw() {
    if (_index >= customCards.length) {
      throw StateError('No more cards in mock deck');
    }
    return customCards[_index++];
  }

  @override
  int get remainingCards => customCards.length - _index;

  @override
  bool get isEmpty => _index >= customCards.length;

  @override
  bool get isNotEmpty => !isEmpty;
}

void main() {
  group('HigherLowerController Tests', () {
    test('Initial game state deals one card and sets proper values', () {
      final controller = HigherLowerController();
      expect(controller.currentCard, isNotNull);
      expect(controller.previousCard, isNull);
      expect(controller.score, 0);
      expect(controller.currentStreak, 0);
      expect(controller.bestStreak, 0);
      expect(controller.cardsPlayed, 1);
      expect(controller.remainingCards, 51);
      expect(controller.status, GameStatus.playing);
      expect(controller.isGameOver, isFalse);
      expect(controller.canPredict, isTrue);
    });

    test('Higher prediction succeeds when next card is higher', () {
      final mockCards = [
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.five), // 5
        const PlayingCard(suit: CardSuit.spades, rank: CardRank.nine), // 9
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.jack),  // 11 (spare)
      ];
      final controller = HigherLowerController(deck: MockDeck(mockCards));
      expect(controller.currentCard?.value, 5);

      final result = controller.predict(Prediction.higher);
      expect(result, PredictionResult.correct);
      expect(controller.score, 10);
      expect(controller.currentStreak, 1);
      expect(controller.bestStreak, 1);
      expect(controller.status, GameStatus.playing);
      expect(controller.currentCard?.value, 9);
      expect(controller.previousCard?.value, 5);
    });

    test('Higher prediction fails and triggers Game Over when next card is lower', () {
      final mockCards = [
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.jack), // 11
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.four),  // 4
        const PlayingCard(suit: CardSuit.spades, rank: CardRank.two),  // 2 (spare)
      ];
      final controller = HigherLowerController(deck: MockDeck(mockCards));

      final result = controller.predict(Prediction.higher);
      expect(result, PredictionResult.wrong);
      expect(controller.score, 0);
      expect(controller.currentStreak, 0);
      expect(controller.status, GameStatus.gameOver);
      expect(controller.gameOverReason, GameOverReason.wrongGuess);
      expect(controller.isGameOver, isTrue);
      expect(controller.canPredict, isFalse);
    });

    test('Lower prediction succeeds when next card is lower', () {
      final mockCards = [
        const PlayingCard(suit: CardSuit.diamonds, rank: CardRank.king), // 13
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.three),  // 3
        const PlayingCard(suit: CardSuit.spades, rank: CardRank.two),   // 2 (spare)
      ];
      final controller = HigherLowerController(deck: MockDeck(mockCards));

      final result = controller.predict(Prediction.lower);
      expect(result, PredictionResult.correct);
      expect(controller.score, 10);
      expect(controller.currentStreak, 1);
      expect(controller.status, GameStatus.playing);
    });

    test('Tie rule preserves streak and awards push points', () {
      final mockCards = [
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.seven),
        const PlayingCard(suit: CardSuit.diamonds, rank: CardRank.seven),
        const PlayingCard(suit: CardSuit.spades, rank: CardRank.ace), // spare
      ];
      final controller = HigherLowerController(deck: MockDeck(mockCards));

      final result = controller.predict(Prediction.higher);
      expect(result, PredictionResult.tie);
      expect(controller.score, 5);
      expect(controller.currentStreak, 0); // streak wasn't broken by a loss
      expect(controller.status, GameStatus.playing);
    });

    test('Streak multiplier increments score exponentially', () {
      final mockCards = [
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.two),
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.three), // Streak 1: +10 (total 10)
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.four),  // Streak 2: +10 (total 20)
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.five),  // Streak 3: +15 (total 35)
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.six),   // Streak 4: +15 (total 50)
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.seven), // Streak 5: +20 (total 70)
        const PlayingCard(suit: CardSuit.clubs, rank: CardRank.eight), // spare
      ];
      final controller = HigherLowerController(deck: MockDeck(mockCards));

      for (var i = 0; i < 5; i++) {
        controller.finishAnimation();
        controller.predict(Prediction.higher);
      }

      expect(controller.currentStreak, 5);
      expect(controller.bestStreak, 5);
      expect(controller.score, 70);
    });

    test('Deck exhaustion triggers GameStatus.deckExhausted with victory reason', () {
      final mockCards = [
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.two),
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.three),
      ];
      final controller = HigherLowerController(deck: MockDeck(mockCards));
      final result = controller.predict(Prediction.higher);

      expect(result, PredictionResult.correct);
      expect(controller.status, GameStatus.deckExhausted);
      expect(controller.gameOverReason, GameOverReason.deckCompleted);
      expect(controller.isGameOver, isTrue);
      expect(controller.remainingCards, 0);
    });

    test('Rapid input lockout: cannot predict while processing animation', () {
      final mockCards = [
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.two),
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.three),
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.four),
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.five),
      ];
      final controller = HigherLowerController(deck: MockDeck(mockCards));

      controller.predict(Prediction.higher);
      expect(controller.isProcessing, isTrue);
      expect(controller.canPredict, isFalse);

      // Attempting second prediction while locked should return null
      final secondTry = controller.predict(Prediction.higher);
      expect(secondTry, isNull);
      expect(controller.cardsPlayed, 2); // Still 2, didn't draw third

      // After animation completes, can predict again
      controller.finishAnimation();
      expect(controller.isProcessing, isFalse);
      expect(controller.canPredict, isTrue);

      final thirdTry = controller.predict(Prediction.higher);
      expect(thirdTry, PredictionResult.correct);
      expect(controller.cardsPlayed, 3);
    });

    test('Restarting game resets score and cards but preserves best streak', () {
      final mockCards = [
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.two),
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.three),
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.four),
      ];
      final controller = HigherLowerController(deck: MockDeck(mockCards));
      controller.predict(Prediction.higher);
      controller.finishAnimation();
      controller.predict(Prediction.higher);
      expect(controller.bestStreak, 2);
      expect(controller.score, 20);

      controller.startNewGame();
      expect(controller.score, 0);
      expect(controller.currentStreak, 0);
      expect(controller.bestStreak, 2); // Retained!
      expect(controller.status, GameStatus.playing);
    });
  });
}
