// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart' hide Badge;
import 'package:airpur/services/material.dart';
import 'package:airpur/services/quiz_manager.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizManager _quizManager = QuizManager();
  late final PageController _pageController;
  final String _quizId = 'quiz1';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final List<Question> questions = _quizManager.getQuestions(_quizId);
    final int totalPages = questions.length + 1; // +1 pour la page récapitulative

    return Scaffold(
      appBar: AppBar(title: Text('Quiz Profilage')),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQ.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    currentQ.options.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        onPressed: () {
                          _goToNextPage();
                        },
                        child: Text(currentQ.options[index]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Page récapitulative du Quiz 1
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Récapitulatif Quiz Profilage',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String randomTip = _quizManager.getRandomTip(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conseil à retenir :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          randomTip,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                        Text(
                          'Défi du jour :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dailyChallenge,
                          style: TextStyle(fontSize: 16),
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
                        Text(
                          'Félicitations, vous débloquez le badge :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(badge.assetPath, height: 48),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                badge.title,
                                style: TextStyle(fontSize: 16),
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
                    child: Text('Passer au Quiz 2'),
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

class Quiz2Screen extends StatefulWidget {
  @override
  _Quiz2ScreenState createState() => _Quiz2ScreenState();
}

class _Quiz2ScreenState extends State<Quiz2Screen> {
  final QuizManager _quizManager = QuizManager();
  late final PageController _pageController;
  final String _quizId = 'quiz2';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final List<Question> questions = _quizManager.getQuestions(_quizId);
    final int totalPages = questions.length + 1; // +1 pour la page récapitulative

    return Scaffold(
      appBar: AppBar(title: Text('Quiz 2 - Quel fumeur es-tu ?')),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQ.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    currentQ.options.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        onPressed: () {
                          _goToNextPage();
                        },
                        child: Text(currentQ.options[index]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Page récapitulative du Quiz 2
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Récapitulatif Quiz 2',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String randomTip = _quizManager.getRandomTip(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conseil :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          randomTip,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                        Text(
                          'Défi "1er souffle" :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dailyChallenge,
                          style: TextStyle(fontSize: 16),
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
                        Text(
                          'Nouveau badge :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(badge.assetPath, height: 48),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                badge.title,
                                style: TextStyle(fontSize: 16),
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
                    child: Text('Passer au Quiz 3'),
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

class Quiz3Screen extends StatefulWidget {
  @override
  _Quiz3ScreenState createState() => _Quiz3ScreenState();
}

class _Quiz3ScreenState extends State<Quiz3Screen> {
  final QuizManager _quizManager = QuizManager();
  late final PageController _pageController;
  final String _quizId = 'quiz3';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final List<Question> questions = _quizManager.getQuestions(_quizId);
    final int totalPages = questions.length + 1; // +1 pour récapitulatif

    return Scaffold(
      appBar: AppBar(title: Text('Quiz 3 - Qu\'est-ce qui te motive ?')),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentQ.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    currentQ.options.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        onPressed: () {
                          _goToNextPage();
                        },
                        child: Text(currentQ.options[index]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Page récapitulative du Quiz 3
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Récapitulatif Quiz 3',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  Builder(builder: (_) {
                    final String randomTip = _quizManager.getRandomTip(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conseil :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          randomTip,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                        Text(
                          'Défi "1er jour clean" :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dailyChallenge,
                          style: TextStyle(fontSize: 16),
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
                        Text(
                          'Nouveau badge :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(badge.assetPath, height: 48),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                badge.title,
                                style: TextStyle(fontSize: 16),
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
