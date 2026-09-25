enum Prediction {
  higher,
  lower;

  String get label => this == Prediction.higher ? 'HIGHER' : 'LOWER';
}

enum PredictionResult {
  correct,
  wrong,
  tie;

  bool get isSuccess => this == PredictionResult.correct || this == PredictionResult.tie;
}

enum GameStatus {
  ready,
  playing,
  gameOver,
  deckExhausted,
}

enum GameOverReason {
  wrongGuess,
  deckCompleted,
}
