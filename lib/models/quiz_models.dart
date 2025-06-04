enum QuestionType { texte, numeric, decimal, date, choixUnique /* etc. */ }

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final String? hint;
  final List<String> options;
  final int correctIndex;
  // … autres champs si besoin (liste d’options, etc.) …

  Question({
    required this.id,
    required this.text,
    this.type = QuestionType.texte,
    this.hint,
    required this.options,
    this.correctIndex = -1,
  });
}

// Pour stocker la réponse :
class QuizAnswer {
  final String questionId;
  final String valeur;
  // On stocke tout en string, mais pour date/num, on fera le parsing après.

  QuizAnswer({
    required this.questionId,
    required this.valeur,
  });
  
  
}
