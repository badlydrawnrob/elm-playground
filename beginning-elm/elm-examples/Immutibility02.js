var multiplier = 2;
var scores = [316,320,370,337,318,314];

var multiplier = 3

function doubleScores(scores) {
  for (var i = 0; i < scores.length; i++) {
    scores[i] = scores[i] * multiplier;
  }

  return scores;
}
