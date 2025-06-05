// lib/services/quiz_manager.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';
import 'material.dart';

/// Classe principale qui gère dynamiquement plusieurs quizzes,
/// avec persistance des réponses dans SharedPreferences.
class QuizManager {
  /// Préfixe de clé pour sauvegarder les réponses d’un quiz dans SharedPreferences.
  static const String _prefsKeyPrefix = 'quiz_answers_';

  /// Retourne la liste complète des questions pour le quiz identifié par [quizId].
  /// Si l’ID n’existe pas, retourne une liste vide.
  List<Question> getQuestions(String quizId) {
    final content = allQuizzes[quizId];
    if (content == null) return [];
    return List.unmodifiable(content.questions);
  }

  /// Enregistre les réponses [reponses] de l’utilisateur pour le quiz [quizId]
  /// dans SharedPreferences, sous forme de JSON.
  Future<void> saveUserResponses(String quizId, List<QuizAnswer> reponses) async {
    final prefs = await SharedPreferences.getInstance();

    // On convertit la liste de QuizAnswer en List<Map<String, String>>
    final List<Map<String, String>> mapped = reponses
        .map((ans) => {'questionId': ans.questionId, 'valeur': ans.valeur})
        .toList();

    // On encode en JSON
    final String jsonString = jsonEncode(mapped);

    // On stocke sous la clé 'quiz_answers_<quizId>'
    await prefs.setString('$_prefsKeyPrefix$quizId', jsonString);
  }

  /// Vérifie si des réponses ont déjà été enregistrées pour [quizId].
  /// Retourne true si la clé existe dans SharedPreferences et contient une liste non vide.
  Future<bool> hasSavedAnswers(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('$_prefsKeyPrefix$quizId')) return false;

    final String? jsonString = prefs.getString('$_prefsKeyPrefix$quizId');
    if (jsonString == null || jsonString.isEmpty) return false;

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Récupère la liste des réponses sauvegardées pour [quizId] depuis SharedPreferences.
  /// Si aucune réponse n’est trouvée, retourne une liste vide.
  Future<List<QuizAnswer?>> getSavedAnswers(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('$_prefsKeyPrefix$quizId');
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      // Reconstruit chaque QuizAnswer à partir du Map
      return decoded.map<QuizAnswer?>((item) {
        if (item is Map<String, dynamic>) {
          final qId = item['questionId'] as String?;
          final val = item['valeur'] as String?;
          if (qId != null && val != null) {
            return QuizAnswer(questionId: qId, valeur: val);
          }
        }
        return null;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Efface toutes les réponses enregistrées pour le quiz [quizId] dans SharedPreferences.
  Future<void> clearSavedAnswers(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsKeyPrefix$quizId');
  }

  /// Méthode existante pour enregistrer les réponses spécifiques au quiz de tabac.
  /// Si vous souhaitez combiner avec SharedPreferences, appelez saveUserResponses séparément.
  Future<void> enregistrerReponses(List<QuizAnswer> reponses) async {
    // On cherche dans `reponses` la réponse q2 (cigarettes par jour).
    final answerCigsParJour = reponses.firstWhere(
          (ans) => ans.questionId == 'q2',
      orElse: () => QuizAnswer(questionId: 'q2', valeur: "0"),
    ).valeur;

    final cigsParJour = int.tryParse(answerCigsParJour) ?? 0;
    final double prixPaquet = 13;
    // On considère qu’un paquet contient 20 cigarettes par défaut.

    // Exécution d’une action spécifique (exemple d’enregistrement dans une autre table)
    // await DBHelper().insertHabitudeTabac(
    //   cigsParJour: cigsParJour,
    //   prixParPaquet: prixPaquet,
    //   dateArret: DateTime.now(),
    // );
  }

  /// Retourne un conseil court & concret au hasard pour le quiz [quizId].
  /// Si l’ID n’existe pas ou qu’il n’y a pas de tips, retourne une chaîne vide.
  String getRandomTip(String quizId) {
    final content = allQuizzes[quizId];
    if (content == null || content.tips.isEmpty) return '';
    content.tips.shuffle();
    return content.tips.first;
  }

  /// Récupère la liste de badges acquis pour le quiz [quizId].
  /// Si l’ID n’existe pas, retourne une liste vide (ne jamais retourner null).
  List<Badge> getBadges(String quizId) {
    final content = allQuizzes[quizId];
    if (content == null) return <Badge>[];
    return content.badges;
  }

  /// Recherche une infographie par [infographicId] au sein du quiz [quizId].
  /// Retourne null si le quiz ou l’infographie n’existent pas.
  Infographic? getInfographicById(String quizId, String infographicId) {
    final content = allQuizzes[quizId];
    if (content == null) return null;
    try {
      return content.infographics.firstWhere((info) => info.id == infographicId);
    } catch (_) {
      return null;
    }
  }

  /// Retourne la liste de tous les IDs de quiz disponibles.
  List<String> getAllQuizIds() {
    return List.unmodifiable(allQuizzes.keys);
  }

  /// Retourne le défi du jour pour le quiz [quizId].
  /// Si [index] est fourni et valide, renvoie ce défi précis.
  /// Sinon, renvoie un défi aléatoire. Si l’ID est invalide, retourne une chaîne vide.
  String getDailyChallenge(String quizId, {int? index}) {
    final content = allQuizzes[quizId];
    if (content == null || content.challenges.isEmpty) return '';
    if (index != null && index >= 0 && index < content.challenges.length) {
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
}
