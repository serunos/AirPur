// lib/services/quiz_manager.dart

import 'material.dart';

/// Classe principale qui gère dynamiquement plusieurs quizzes
class QuizManager {
  /// Retourne la liste complète des questions pour le quiz identifié par [quizId].
  /// Si l’ID n’existe pas, retourne une liste vide.
  List<Question> getQuestions(String quizId) {
    final content = allQuizzes[quizId];
    if (content == null) return [];
    return List.unmodifiable(content.questions);
  }

  /// Retourne un conseil court & concret au hasard pour le quiz [quizId].
  /// Si l’ID n’existe pas ou qu’il n’y a pas de tips, retourne une chaîne vide.
  String getRandomTip(String quizId) {
    final content = allQuizzes[quizId];
    if (content == null || content.tips.isEmpty) return '';
    content.tips.shuffle();
    return content.tips.first;
  }

  /// Recherche une infographie par [infographicId] au sein du quiz [quizId].
  /// Retourne null si le quiz ou l’infographie n’existent pas.
  Infographic? getInfographicById(String quizId, String infographicId) {
    final content = allQuizzes[quizId];
    if (content == null) return null;
    try {
      return content.infographics
          .firstWhere((info) => info.id == infographicId);
    } catch (_) {
      return null;
    }
  }

  /// Retourne le défi du jour pour le quiz [quizId].
  /// Si [index] est fourni et valide, renvoie ce défi précis.
  /// Sinon, renvoie un défi aléatoire. Si l’ID est invalide, retourne une chaîne vide.
  String getDailyChallenge(String quizId, {int? index}) {
    final content = allQuizzes[quizId];
    if (content == null || content.challenges.isEmpty) return '';
    if (index != null &&
        index >= 0 &&
        index < content.challenges.length) {
      return content.challenges[index];
    }
    content.challenges.shuffle();
    return content.challenges.first;
  }

  /// Retourne la liste des badges disponibles pour le quiz [quizId].
  /// Si l’ID n’existe pas, retourne une liste vide.
  List<Badge> getAllBadges(String quizId) {
    final content = allQuizzes[quizId];
    if (content == null) return [];
    return List.unmodifiable(content.badges);
  }

  /// Attribue un badge ([badgeId]) à l’utilisateur pour le quiz [quizId].
  /// Retourne le badge si trouvé, sinon null.
  Badge? awardBadge(String quizId, String badgeId) {
    final content = allQuizzes[quizId];
    if (content == null) return null;
    try {
      return content.badges.firstWhere((b) => b.id == badgeId);
    } catch (_) {
      return null;
    }
  }

// Vous pouvez ajouter d’autres méthodes si besoin,
// par exemple pour gérer les réponses de l’utilisateur :
// - saveUserResponses(String quizId, Map<String, String> answers)
// - calculateScore(String quizId, Map<String, int> userAnswers)
// - logChallengeCompletion(String quizId, String challengeId)
}
