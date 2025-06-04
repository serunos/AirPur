// lib/services/material.dart



import '../models/quiz_models.dart';

/// Modèle pour un badge délivré à l'utilisateur
class Badge {
  final String id;
  final String title;
  final String description;
  final String assetPath;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
  });
}

/// Représentation d'une infographie (peut être une URL, un asset local, etc.)
class Infographic {
  final String id;
  final String title;
  final String assetPath;

  Infographic({
    required this.id,
    required this.title,
    required this.assetPath,
  });
}

/// Conteneur générique pour tout le contenu d’un quiz
class QuizContent {
  final List<Question> questions;
  final List<String> tips;
  final List<Infographic> infographics;
  final List<String> challenges;
  final List<Badge> badges;

  QuizContent({
    required this.questions,
    required this.tips,
    required this.infographics,
    required this.challenges,
    required this.badges,
  });
}

/// Données pour Quiz #1 : « Profiling de l’utilisateur »
final QuizContent quiz1Content = QuizContent(
  questions: [
    Question(
      id: 'q1',
      text: 'Depuis combien de temps fumez-vous ?',
      options: ['< 1 an', '1–5 ans', '5–10 ans', '> 10 ans'],
    ),
    Question(
      id: 'q2',
      text: "Avant d’arrêter, combien de cigarettes fumiez-vous par jour ?",
      type: QuestionType.numeric,
      hint: "Entrez un nombre entier, ex : 15", 
      options: [],
    ),
    Question(
      id: 'q3',
      text: 'Avez-vous déjà essayé d\'arrêter ?',
      options: ['Oui, plusieurs fois', 'Oui, une fois', 'Non'],
    ),
  ],
  tips: [
    'Buvez un verre d’eau quand l’envie de fumer arrive.',
    'Mâchez un chewing-gum sans sucre pour occuper vos mains.',
    'Respirez profondément pendant 1 minute pour calmer le stress.',
    'Planifiez une courte promenade lorsque vous ressentez l’envie.',
  ],
  infographics: [
    Infographic(
      id: 'i1',
      title: 'Bienfaits après 24h sans cigarette',
      assetPath: 'assets/infographics/benefits_24h.png',
    ),
    Infographic(
      id: 'i2',
      title: 'Evolution de la santé pulmonaire',
      assetPath: 'assets/infographics/lung_health.png',
    ),
  ],
  challenges: [
    'Appeler un proche pour partager votre objectif d’arrêt.',
    'Noter dans un carnet vos trois principales motivations pour arrêter.',
    'Boire au moins 1,5 L d’eau au cours de la journée.',
    'Marcher 15 minutes dès que vous ressentez une envie de fumer.',
  ],
  badges: [
    Badge(
      id: 'b1',
      title: 'Premier Pas',
      description: 'Vous avez complété le Quizz de profiling.',
      assetPath: 'assets/badges/first_step.png',
    ),
    Badge(
      id: 'b2',
      title: '1 Jour Sans Cigarette',
      description: 'Vous avez tenu 24 heures sans fumer.',
      assetPath: 'assets/badges/one_day.png',
    ),
    Badge(
      id: 'b3',
      title: 'Défi Relevé',
      description: 'Vous avez rempli votre défi du jour.',
      assetPath: 'assets/badges/daily_challenge.png',
    ),
  ],
);

/// Données pour Quiz #2 : « Quel fumeur es-tu ? »
final QuizContent quiz2Content = QuizContent(
  questions: [
    Question(
      id: 'q21',
      text: 'Quand ressentez-vous le besoin de fumer le plus souvent ?',
      options: ['Au réveil', 'Après les repas', 'En faisant une pause au travail', 'Lors d’un moment de stress'],
    ),
    Question(
      id: 'q22',
      text: 'Quelle est votre principale motivation pour allumer une cigarette ?',
      options: ['Pour me détendre', 'Pour socialiser', 'Par habitude', 'Pour gérer mon stress'],
    ),
    Question(
      id: 'q23',
      text: 'Combien de temps après votre réveil fumez-vous votre première cigarette ?',
      options: ['Dans l’heure qui suit', 'Plus de 2 heures après', 'Juste avant de me lever', 'Je n’ai pas d’horaire fixe'],
    ),
    Question(
      id: 'q24',
      text: 'À quel point vous sentez-vous dépendant de la cigarette ?',
      options: ['Très dépendant', 'Assez dépendant', 'Un peu dépendant', 'Pas du tout dépendant'],
    ),
  ],
  tips: [
    'Respire profondément : inspirez en comptant jusqu’à 4, expirez jusqu’à 6.',
  ],
  infographics: [
    Infographic(
      id: 'i21',
      title: 'Les bienfaits de l\'arrêt',
      assetPath: 'assets/infographics/benefits_quit.png',
    ),
  ],
  challenges: [
    'Remplacer une cigarette par une autre activité (respiration, mini-jeu).',
  ],
  badges: [
    Badge(
      id: 'b21',
      title: 'Un bon départ',
      description: 'Vous avez complété le quiz « Quel fumeur es-tu ? »',
      assetPath: 'assets/badges/good_start.png',
    ),
  ],
);

/// Données pour Quiz #3 : « Qu’est-ce qui te motive ? »
final QuizContent quiz3Content = QuizContent(
  questions: [
    Question(
      id: 'q31',
      text: 'Qu’est-ce qui vous motive le plus à arrêter de fumer ?',
      options: ['Améliorer ma santé', 'Économiser de l’argent', 'Protéger ma famille', 'Améliorer mon apparence'],
    ),
    Question(
      id: 'q32',
      text: 'Quel bénéfice attendez-vous en priorité si vous arrêtez ?',
      options: ['Meilleur souffle', 'Moindre fatigue', 'Peau plus nette', 'Plus grande endurance'],
    ),
    Question(
      id: 'q33',
      text: 'À quel point l’économie financière est-elle importante pour vous ?',
      options: ['Primordiale', 'Assez importante', 'Un peu importante', 'Pas importante'],
    ),
    Question(
      id: 'q34',
      text: 'Quel frein pensez-vous avoir pour tenir sans fumer ?',
      options: ['Manque de motivation', 'Stress émotionnel', 'Crainte de reprendre du poids', 'Pression sociale'],
    ),
  ],
  tips: [
    'Pourquoi veux-tu arrêter ? Écris-le. Quand ça devient dur, relis-le.',
  ],
  infographics: [
    Infographic(
      id: 'i31',
      title: 'Tes économies !',
      assetPath: 'assets/infographics/savings.png',
    ),
    Infographic(
      id: 'i32',
      title: 'Ta santé',
      assetPath: 'assets/infographics/health.png',
    ),
  ],
  challenges: [
    'Tenir 24 h sans fumer (point avant/après avec l’utilisateur).',
  ],
  badges: [
    Badge(
      id: 'b31',
      title: 'Clean streak x1',
      description: 'Vous avez tenu votre premier jour « clean ».',
      assetPath: 'assets/badges/clean_streak_1.png',
    ),
  ],
);

/// Mappe globale rassemblant tous les quizzes disponibles
/// La clé est l’ID du quiz (« quiz1 », « quiz2 », « quiz3 », etc.)
final Map<String, QuizContent> allQuizzes = {
  'quiz1': quiz1Content,
  'quiz2': quiz2Content,
  'quiz3': quiz3Content,
};
