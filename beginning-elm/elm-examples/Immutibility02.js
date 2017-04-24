var multiplier = 2;
var scores = [316,320,370,337,318,314];

// This mutates `multiplier` to 3:
var multiplier = 3

function doubleScores(scores) {
  for (var i = 0; i < scores.length; i++) {
    scores[i] = scores[i] * multiplier;
  }

  return scores;
}

function scoresLessThan320(scores) {
  return scores.filter(isLessThan320)
}

function isLessThan320(score) {
  return score < 320;
}

// The correct way to handle this in JS

var multiplierCorrect = 2;
var scoresCorrect = [316,320,370,337,318,314];

function doubleScoresCorrect(scores) {
  // Store the results in a new List
  var newScores = [];

  for (var i = 0; i < scores.length; i++) {
    // Append to new list, no mutation
    newScores[i] = scores[i] * multiplierCorrect;
  }

  return newScores;
}
