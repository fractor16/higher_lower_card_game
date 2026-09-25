import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:higher_lower_card_game/game/deck.dart';
import 'package:higher_lower_card_game/game/higher_lower_controller.dart';
import 'package:higher_lower_card_game/models/card_model.dart';
import 'package:higher_lower_card_game/screens/game_screen.dart';
import 'package:higher_lower_card_game/theme/app_theme.dart';

class PredefinedDeck extends Deck {
  final List<PlayingCard> sequence;
  int _idx = 0;

  PredefinedDeck(this.sequence);

  @override
  void reset() {
    _idx = 0;
  }

  @override
  PlayingCard draw() {
    if (_idx >= sequence.length) {
      throw StateError('Out of cards');
    }
    return sequence[_idx++];
  }

  @override
  int get remainingCards => sequence.length - _idx;

  @override
  bool get isEmpty => _idx >= sequence.length;

  @override
  bool get isNotEmpty => !isEmpty;
}

void main() {
  Widget createTestWidget(HigherLowerController controller) {
    return MaterialApp(
      theme: AppTheme.themeData,
      home: GameScreen(controller: controller),
    );
  }

  testWidgets('GameScreen renders initial state with score and buttons',
      (WidgetTester tester) async {
    final controller = HigherLowerController();
    await tester.pumpWidget(createTestWidget(controller));
    await tester.pumpAndSettle();

    expect(find.text('HIGHER OR LOWER'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('STREAK'), findsOneWidget);
    expect(find.text('HIGHER'), findsOneWidget);
    expect(find.text('LOWER'), findsOneWidget);
    expect(find.byKey(const ValueKey('btn_higher')), findsOneWidget);
    expect(find.byKey(const ValueKey('btn_lower')), findsOneWidget);
  });

  testWidgets('Tapping Higher with higher card updates score and streak',
      (WidgetTester tester) async {
    final sequence = [
      const PlayingCard(suit: CardSuit.hearts, rank: CardRank.four), // initial card
      const PlayingCard(suit: CardSuit.spades, rank: CardRank.ten),  // higher card
      const PlayingCard(suit: CardSuit.clubs, rank: CardRank.ace),   // spare
    ];
    final controller = HigherLowerController(deck: PredefinedDeck(sequence));

    await tester.pumpWidget(createTestWidget(controller));
    await tester.pumpAndSettle();

    expect(controller.score, 0);
    expect(controller.currentStreak, 0);

    // Tap Higher
    await tester.tap(find.byKey(const ValueKey('btn_higher')), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600)); // Finish flip animation

    expect(controller.score, 10);
    expect(controller.currentStreak, 1);
    expect(find.text('CORRECT PREDICTION!'), findsOneWidget);
  });

  testWidgets('Tapping wrong prediction shows Game Over dialog and Play Again resets',
      (WidgetTester tester) async {
    final sequence = [
      const PlayingCard(suit: CardSuit.hearts, rank: CardRank.ten), // initial card
      const PlayingCard(suit: CardSuit.spades, rank: CardRank.three), // lower card
      const PlayingCard(suit: CardSuit.clubs, rank: CardRank.two),   // spare
    ];
    final controller = HigherLowerController(deck: PredefinedDeck(sequence));

    await tester.pumpWidget(createTestWidget(controller));
    await tester.pumpAndSettle();

    // Tap Higher (which is wrong, since next is 3)
    await tester.tap(find.byKey(const ValueKey('btn_higher')), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(controller.isGameOver, isTrue);
    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.byKey(const ValueKey('btn_play_again')), findsOneWidget);

    // Tap Play Again
    await tester.tap(find.byKey(const ValueKey('btn_play_again')));
    await tester.pumpAndSettle();

    expect(controller.isGameOver, isFalse);
    expect(find.text('GAME OVER'), findsNothing);
    expect(controller.score, 0);
  });

  testWidgets('Rules dialog displays when clicking help button',
      (WidgetTester tester) async {
    final controller = HigherLowerController();
    await tester.pumpWidget(createTestWidget(controller));
    await tester.pumpAndSettle();

    final helpBtn = find.byTooltip('Game Rules');
    expect(helpBtn, findsOneWidget);
    await tester.tap(helpBtn);
    await tester.pumpAndSettle();

    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Equal Rank Ties (Push)'), findsOneWidget);

    await tester.tap(find.text('GOT IT'));
    await tester.pumpAndSettle();

    expect(find.text('How to Play'), findsNothing);
  });
}
