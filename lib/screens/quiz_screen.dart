// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart' hide Badge;
import 'package:airpur/services/material.dart';
import 'package:airpur/services/quiz_manager.dart';

import '../models/quiz_models.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizManager _quizManager = QuizManager();
  late final PageController _pageController;
  final String _quizId = 'quiz1';

  /// Liste qui stockera toutes les réponses sous forme de QuizAnswer(questionId, valeur)
  final List<QuizAnswer> _answers = [];

  /// Un TextEditingController par question à saisie libre (numeric, decimal ou date).
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // On initialise un TextEditingController pour chaque question à saisie libre
    final questions = _quizManager.getQuestions(_quizId);
    for (var q in questions) {
      if (q.type == QuestionType.numeric ||
          q.type == QuestionType.decimal ||
          q.type == QuestionType.date) {
        _controllers[q.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Met à jour (ou ajoute) une réponse à la liste _answers
  void _storeAnswer(String questionId, String valeur) {
    final existingIndex =
    _answers.indexWhere((ans) => ans.questionId == questionId);
    if (existingIndex >= 0) {
      _answers[existingIndex] = QuizAnswer(
        questionId: questionId,
        valeur: valeur,
      );
    } else {
      _answers.add(QuizAnswer(
        questionId: questionId,
        valeur: valeur,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Question> questions = _quizManager.getQuestions(_quizId);
    final int totalPages = questions.length + 1; // +1 pour la page récap

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Profilage')),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalPages,
        itemBuilder: (context, pageIndex) {
          // Si on est sur une question...
          if (pageIndex < questions.length) {
            final Question currentQ = questions[pageIndex];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${pageIndex + 1} / ${questions.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQ.text,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Si la question a des options (choix unique) :
                  if (currentQ.options.isNotEmpty) ...[
                    ...List.generate(
                      currentQ.options.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            // On stocke la réponse choisie (l’étiquette du bouton)
                            _storeAnswer(
                              currentQ.id,
                              currentQ.options[index],
                            );
                            _goToNextPage();
                          },
                          child: Text(currentQ.options[index]),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Sinon, c’est une question à saisie libre : numeric, decimal ou date
                    if (currentQ.type == QuestionType.numeric ||
                        currentQ.type == QuestionType.decimal) ...[
                      TextFormField(
                        controller: _controllers[currentQ.id],
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: currentQ.type == QuestionType.decimal,
                        ),
                        decoration: InputDecoration(
                          labelText: currentQ.text,
                          hintText: currentQ.hint,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          _storeAnswer(currentQ.id, val);
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Optionnel : valider que le champ n’est pas vide
                          _goToNextPage();
                        },
                        child: const Text('Suivant'),
                      ),
                    ] else if (currentQ.type == QuestionType.date) ...[
                      TextFormField(
                        controller: _controllers[currentQ.id],
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: currentQ.text,
                          hintText: currentQ.hint ?? 'JJ/MM/AAAA',
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime now = DateTime.now();
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(1900),
                            lastDate: now,
                            locale: const Locale('fr', 'FR'),
                          );
                          if (picked != null) {
                            final formatted =
                                '${picked.day.toString().padLeft(2, '0')}/'
                                '${picked.month.toString().padLeft(2, '0')}/'
                                '${picked.year}';
                            _controllers[currentQ.id]!.text = formatted;
                            _storeAnswer(currentQ.id, formatted);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _goToNextPage();
                        },
                        child: const Text('Suivant'),
                      ),
                    ],
                  ],

                  const Spacer(),
                ],
              ),
            );
          }

          // … sinon, page récapitulative du Quiz 1 …
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Récapitulatif Quiz Profilage',
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String randomTip =
                    _quizManager.getRandomTip(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conseil à retenir :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          randomTip,
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final Infographic? info =
                    _quizManager.getInfographicById(_quizId, 'i1');
                    if (info == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Infographie : ${info.title}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Image.asset(info.assetPath),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String dailyChallenge =
                    _quizManager.getDailyChallenge(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Défi du jour :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dailyChallenge,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final Badge? badge =
                    _quizManager.awardBadge(_quizId, 'b1');
                    if (badge == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Félicitations, vous débloquez le badge :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(badge.assetPath, height: 48),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                badge.title,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => Quiz2Screen()),
                      );
                    },
                    child: const Text('Passer au Quiz 2'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== Quiz 2 ====================

class Quiz2Screen extends StatefulWidget {
  @override
  _Quiz2ScreenState createState() => _Quiz2ScreenState();
}

class _Quiz2ScreenState extends State<Quiz2Screen> {
  final QuizManager _quizManager = QuizManager();
  late final PageController _pageController;
  final String _quizId = 'quiz2';

  final List<QuizAnswer> _answers = [];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final questions = _quizManager.getQuestions(_quizId);
    for (var q in questions) {
      if (q.type == QuestionType.numeric ||
          q.type == QuestionType.decimal ||
          q.type == QuestionType.date) {
        _controllers[q.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _storeAnswer(String questionId, String valeur) {
    final existingIndex =
    _answers.indexWhere((ans) => ans.questionId == questionId);
    if (existingIndex >= 0) {
      _answers[existingIndex] = QuizAnswer(
        questionId: questionId,
        valeur: valeur,
      );
    } else {
      _answers.add(QuizAnswer(
        questionId: questionId,
        valeur: valeur,
      ));
    }
  }

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Question> questions = _quizManager.getQuestions(_quizId);
    final int totalPages = questions.length + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz 2 - Quel fumeur es-tu ?')),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalPages,
        itemBuilder: (context, pageIndex) {
          if (pageIndex < questions.length) {
            final Question currentQ = questions[pageIndex];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${pageIndex + 1} / ${questions.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQ.text,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  if (currentQ.options.isNotEmpty) ...[
                    ...List.generate(
                      currentQ.options.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            _storeAnswer(
                              currentQ.id,
                              currentQ.options[index],
                            );
                            _goToNextPage();
                          },
                          child: Text(currentQ.options[index]),
                        ),
                      ),
                    ),
                  ] else ...[
                    if (currentQ.type == QuestionType.numeric ||
                        currentQ.type == QuestionType.decimal) ...[
                      TextFormField(
                        controller: _controllers[currentQ.id],
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: currentQ.type == QuestionType.decimal,
                        ),
                        decoration: InputDecoration(
                          labelText: currentQ.text,
                          hintText: currentQ.hint,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          _storeAnswer(currentQ.id, val);
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _goToNextPage();
                        },
                        child: const Text('Suivant'),
                      ),
                    ] else if (currentQ.type == QuestionType.date) ...[
                      TextFormField(
                        controller: _controllers[currentQ.id],
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: currentQ.text,
                          hintText: currentQ.hint ?? 'JJ/MM/AAAA',
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime now = DateTime.now();
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(1900),
                            lastDate: now,
                            locale: const Locale('fr', 'FR'),
                          );
                          if (picked != null) {
                            final formatted =
                                '${picked.day.toString().padLeft(2, '0')}/'
                                '${picked.month.toString().padLeft(2, '0')}/'
                                '${picked.year}';
                            _controllers[currentQ.id]!.text = formatted;
                            _storeAnswer(currentQ.id, formatted);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _goToNextPage();
                        },
                        child: const Text('Suivant'),
                      ),
                    ],
                  ],

                  const Spacer(),
                ],
              ),
            );
          }

          // Récapitulatif Quiz 2
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Récapitulatif Quiz 2',
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String randomTip =
                    _quizManager.getRandomTip(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conseil :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          randomTip,
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final Infographic? info =
                    _quizManager.getInfographicById(_quizId, 'i21');
                    if (info == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Infographie : ${info.title}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Image.asset(info.assetPath),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String dailyChallenge =
                    _quizManager.getDailyChallenge(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Défi "1er souffle" :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dailyChallenge,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final Badge? badge =
                    _quizManager.awardBadge(_quizId, 'b21');
                    if (badge == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nouveau badge :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(badge.assetPath, height: 48),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                badge.title,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => Quiz3Screen()),
                      );
                    },
                    child: const Text('Passer au Quiz 3'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== Quiz 3 ====================

class Quiz3Screen extends StatefulWidget {
  @override
  _Quiz3ScreenState createState() => _Quiz3ScreenState();
}

class _Quiz3ScreenState extends State<Quiz3Screen> {
  final QuizManager _quizManager = QuizManager();
  late final PageController _pageController;
  final String _quizId = 'quiz3';

  final List<QuizAnswer> _answers = [];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final questions = _quizManager.getQuestions(_quizId);
    for (var q in questions) {
      if (q.type == QuestionType.numeric ||
          q.type == QuestionType.decimal ||
          q.type == QuestionType.date) {
        _controllers[q.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _storeAnswer(String questionId, String valeur) {
    final existingIndex =
    _answers.indexWhere((ans) => ans.questionId == questionId);
    if (existingIndex >= 0) {
      _answers[existingIndex] = QuizAnswer(
        questionId: questionId,
        valeur: valeur,
      );
    } else {
      _answers.add(QuizAnswer(
        questionId: questionId,
        valeur: valeur,
      ));
    }
  }

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Question> questions = _quizManager.getQuestions(_quizId);
    final int totalPages = questions.length + 1;

    return Scaffold(
      appBar:
      AppBar(title: const Text('Quiz 3 - Qu\'est-ce qui te motive ?')),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalPages,
        itemBuilder: (context, pageIndex) {
          if (pageIndex < questions.length) {
            final Question currentQ = questions[pageIndex];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${pageIndex + 1} / ${questions.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQ.text,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  if (currentQ.options.isNotEmpty) ...[
                    ...List.generate(
                      currentQ.options.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            _storeAnswer(
                              currentQ.id,
                              currentQ.options[index],
                            );
                            _goToNextPage();
                          },
                          child: Text(currentQ.options[index]),
                        ),
                      ),
                    ),
                  ] else ...[
                    if (currentQ.type == QuestionType.numeric ||
                        currentQ.type == QuestionType.decimal) ...[
                      TextFormField(
                        controller: _controllers[currentQ.id],
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: currentQ.type == QuestionType.decimal,
                        ),
                        decoration: InputDecoration(
                          labelText: currentQ.text,
                          hintText: currentQ.hint,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          _storeAnswer(currentQ.id, val);
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _goToNextPage();
                        },
                        child: const Text('Suivant'),
                      ),
                    ] else if (currentQ.type == QuestionType.date) ...[
                      TextFormField(
                        controller: _controllers[currentQ.id],
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: currentQ.text,
                          hintText: currentQ.hint ?? 'JJ/MM/AAAA',
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime now = DateTime.now();
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(1900),
                            lastDate: now,
                            locale: const Locale('fr', 'FR'),
                          );
                          if (picked != null) {
                            final formatted =
                                '${picked.day.toString().padLeft(2, '0')}/'
                                '${picked.month.toString().padLeft(2, '0')}/'
                                '${picked.year}';
                            _controllers[currentQ.id]!.text = formatted;
                            _storeAnswer(currentQ.id, formatted);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _goToNextPage();
                        },
                        child: const Text('Suivant'),
                      ),
                    ],
                  ],

                  const Spacer(),
                ],
              ),
            );
          }

          // Récapitulatif Quiz 3
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Récapitulatif Quiz 3',
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String randomTip =
                    _quizManager.getRandomTip(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conseil :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          randomTip,
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    // On peut choisir d’afficher i31 ou i32 selon le profil. Ici, on prend i31 en exemple.
                    final Infographic? info =
                    _quizManager.getInfographicById(_quizId, 'i31');
                    if (info == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Infographie : ${info.title}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Image.asset(info.assetPath),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String dailyChallenge =
                    _quizManager.getDailyChallenge(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Défi "1er jour clean" :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dailyChallenge,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final Badge? badge =
                    _quizManager.awardBadge(_quizId, 'b31');
                    if (badge == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nouveau badge :',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(badge.assetPath, height: 48),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                badge.title,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
