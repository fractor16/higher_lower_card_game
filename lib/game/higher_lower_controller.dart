import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import '../models/game_state.dart';
import 'deck.dart';

class HigherLowerController extends ChangeNotifier {
  final Deck _deck;
  
  PlayingCard? _currentCard;
  PlayingCard? _previousCard;
  int _score = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _cardsPlayed = 0;
  GameStatus _status = GameStatus.ready;
  GameOverReason? _gameOverReason;
  Prediction? _lastPrediction;
  PredictionResult? _lastResult;
  bool _isProcessing = false;
  final List<PlayingCard> _history = [];

  HigherLowerController({Deck? deck}) : _deck = deck ?? Deck() {
    startNewGame();
  }

  // Getters
  Deck get deck => _deck;
  PlayingCard? get currentCard => _currentCard;
  PlayingCard? get previousCard => _previousCard;
  int get score => _score;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get cardsPlayed => _cardsPlayed;
  int get remainingCards => _deck.remainingCards;
  GameStatus get status => _status;
  GameOverReason? get gameOverReason => _gameOverReason;
  Prediction? get lastPrediction => _lastPrediction;
  PredictionResult? get lastResult => _lastResult;
  bool get isProcessing => _isProcessing;
  bool get isGameOver => _status == GameStatus.gameOver || _status == GameStatus.deckExhausted;
  List<PlayingCard> get history => List.unmodifiable(_history);

  bool get canPredict =>
      _status == GameStatus.playing &&
      !_isProcessing &&
      _deck.isNotEmpty &&
      _currentCard != null;

  /// Starts or restarts a game, shuffling the deck and dealing the first card.
  void startNewGame() {
    _deck.reset();
    _score = 0;
    _currentStreak = 0;
    _cardsPlayed = 1;
    _previousCard = null;
    _lastPrediction = null;
    _lastResult = null;
    _gameOverReason = null;
    _isProcessing = false;
    _history.clear();

    _currentCard = _deck.draw();
    _history.add(_currentCard!);
    _status = GameStatus.playing;
    notifyListeners();
  }

  /// Calculates score multiplier based on streak.
  double get streakMultiplier {
    if (_currentStreak >= 5) return 2.0;
    if (_currentStreak >= 3) return 1.5;
    return 1.0;
  }

  /// Predicts whether the next card is higher or lower.
  /// Returns the outcome [PredictionResult], or null if prediction could not be made.
  PredictionResult? predict(Prediction prediction) {
    if (!canPredict) return null;

    _isProcessing = true;
    _lastPrediction = prediction;

    final nextCard = _deck.draw();
    _cardsPlayed++;
    _previousCard = _currentCard;
    _currentCard = nextCard;
    _history.add(nextCard);

    final comparison = nextCard.compareTo(_previousCard!);

    if (comparison == 0) {
      // Tie / Push Rule: Streak is preserved, award +5 push points.
      _lastResult = PredictionResult.tie;
      _score += 5;
    } else {
      final actualDirection = comparison > 0 ? Prediction.higher : Prediction.lower;
      if (prediction == actualDirection) {
        _lastResult = PredictionResult.correct;
        _currentStreak++;
        if (_currentStreak > _bestStreak) {
          _bestStreak = _currentStreak;
        }
        final pointsWon = (10 * streakMultiplier).round();
        _score += pointsWon;
      } else {
        _lastResult = PredictionResult.wrong;
        _currentStreak = 0;
        _status = GameStatus.gameOver;
        _gameOverReason = GameOverReason.wrongGuess;
      }
    }

    if (_deck.isEmpty && _status != GameStatus.gameOver) {
      _status = GameStatus.deckExhausted;
      _gameOverReason = GameOverReason.deckCompleted;
    }

    notifyListeners();
    return _lastResult;
  }

  /// Call this when the UI animation finishes to re-enable user predictions.
  void finishAnimation() {
    if (_isProcessing) {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Sets the processing flag (e.g. for custom animation control).
  void setProcessing(bool processing) {
    if (_isProcessing != processing) {
      _isProcessing = processing;
      notifyListeners();
    }
  }
}
