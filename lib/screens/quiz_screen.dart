// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart' hide Badge;
import 'package:intl/intl.dart';
import '../models/quiz_models.dart';
import 'package:airpur/services/material.dart';
import 'package:airpur/services/quiz_manager.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String title;

  QuizScreen({required this.quizId, required this.title});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizManager _quizManager = QuizManager();
  late final PageController _pageController;
  late final String _quizId;
  late final String _title;

  // Liste des questions
  late final List<Question> _questions;

  // Réponses collectées pour chaque question (initialement à null)
  late List<QuizAnswer?> _answers;

  // Pour le champ texte / numérique / date
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;

  // Indique si on a trouvé des réponses déjà sauvegardées
  bool _alreadyCompleted = false;

  @override
  void initState() {
    super.initState();
    _quizId = widget.quizId;
    _title = widget.title;

    // 1) Charge la liste de questions (synchrone)
    _questions = _quizManager.getQuestions(_quizId);

    // 2) Initialise la liste de réponses à la taille du quiz
    _answers = List<QuizAnswer?>.filled(_questions.length, null, growable: false);

    // 3) Créé le PageController (par défaut à la page 0)
    _pageController = PageController();

    // 4) Lance la vérification asynchrone pour charger d’éventuelles réponses existantes
    _loadSavedAnswers();
  }

  /// Charge et applique les réponses sauvegardées si elles existent.
  Future<void> _loadSavedAnswers() async {
    final bool hasSaved = await _quizManager.hasSavedAnswers(_quizId);

    if (hasSaved) {
      final List<QuizAnswer?> saved = await _quizManager.getSavedAnswers(_quizId);

      // Si la longueur correspond exactement, on les utilise telles quelles
      if (saved.length == _questions.length) {
        _answers = List<QuizAnswer?>.from(saved);
      } else {
        // Sinon, on recale question par question
        final temp = List<QuizAnswer?>.filled(_questions.length, null, growable: false);
        for (int i = 0; i < saved.length && i < _questions.length; i++) {
          temp[i] = saved[i];
        }
        _answers = temp;
      }

      // On marque qu’on doit afficher directement le récap
      setState(() {
        _alreadyCompleted = true;
      });

      // Après la frame en cours, on force le PageController à la page de récap
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_questions.length);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// Passe à la page suivante (et vide le TextController + la date sélectionnée).
  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _textController.clear();
      _selectedDate = null;
    }
  }

  /// Ouvre un sélecteur de date et stocke dans _selectedDate.
  Future<void> _pickDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = _questions.length + 1; // +1 pour le récapitulatif

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalPages,
        itemBuilder: (context, pageIndex) {
          // --- MÉCANISME DE SAUT VERS LA PAGE RÉCAP ---
          // Si on est dans la plage des questions (pageIndex < nombre de questions)
          // ET que _alreadyCompleted est false → affichage d’une question.
          // Sinon (pageIndex == nombreDeQuestions, ou _alreadyCompleted == true),
          // on affiche le récap.

          if (pageIndex < _questions.length && !_alreadyCompleted) {
            final Question currentQ = _questions[pageIndex];

            // Rendu pour chaque type de question :
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Affiche “Question X / N”
                  Text(
                    'Question ${pageIndex + 1} / ${_questions.length}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  // Texte de la question
                  Text(
                    currentQ.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // --- SWITCH SUR LE TYPE DE QUESTION ---
                  if (currentQ.type == QuestionType.choixUnique)
                  // === Choix Unique ===
                    ...currentQ.options.map((optionTexte) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            // Stocke la réponse
                            _answers[pageIndex] = QuizAnswer(
                              questionId: currentQ.id,
                              valeur: optionTexte,
                            );

                            // Si c’est la DERNIÈRE question, on sauve tout avant d’avancer
                            if (pageIndex == _questions.length - 1) {
                              _saveAndGoToRecap();
                            } else {
                              _goToNextPage();
                            }
                          },
                          child: Text(optionTexte),
                        ),
                      );
                    }).toList()

                  else if (currentQ.type == QuestionType.texte)
                  // === Champ Texte ===
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _textController,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: currentQ.hint ?? 'Votre réponse',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              final String answerText = _textController.text.trim();
                              if (answerText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Veuillez saisir une réponse')),
                                );
                                return;
                              }
                              _answers[pageIndex] = QuizAnswer(
                                questionId: currentQ.id,
                                valeur: answerText,
                              );

                              if (pageIndex == _questions.length - 1) {
                                _saveAndGoToRecap();
                              } else {
                                _goToNextPage();
                              }
                            },
                            child: Text('Suivant'),
                          ),
                        ],
                      ),
                    )

                  else if (currentQ.type == QuestionType.numeric ||
                        currentQ.type == QuestionType.decimal)
                    // === Champ Numérique / Décimal ===
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _textController,
                              maxLines: 1,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: (currentQ.type == QuestionType.decimal),
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: currentQ.hint ?? 'Entrez un nombre',
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                final String answerNum = _textController.text.trim();
                                if (answerNum.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Veuillez saisir un nombre')),
                                  );
                                  return;
                                }
                                _answers[pageIndex] = QuizAnswer(
                                  questionId: currentQ.id,
                                  valeur: answerNum,
                                );

                                if (pageIndex == _questions.length - 1) {
                                  _saveAndGoToRecap();
                                } else {
                                  _goToNextPage();
                                }
                              },
                              child: Text('Suivant'),
                            ),
                          ],
                        ),
                      )

                    else if (currentQ.type == QuestionType.date)
                      // === Sélecteur de Date ===
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  await _pickDate(context);
                                },
                                child: Text(
                                  _selectedDate == null
                                      ? (currentQ.hint ?? 'Sélectionnez une date')
                                      : DateFormat.yMMMMd().format(_selectedDate!),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_selectedDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Veuillez sélectionner une date')),
                                    );
                                    return;
                                  }
                                  _answers[pageIndex] = QuizAnswer(
                                    questionId: currentQ.id,
                                    valeur: DateFormat('yyyy-MM-dd').format(_selectedDate!),
                                  );

                                  if (pageIndex == _questions.length - 1) {
                                    _saveAndGoToRecap();
                                  } else {
                                    _goToNextPage();
                                  }
                                },
                                child: Text('Suivant'),
                              ),
                            ],
                          ),
                        )

                      else
                      // === Autres types non gérés ===
                        Center(child: Text('Type de question non géré')),
                ],
              ),
            );
          }

          // --- PAGE RÉCAPITULATIF ---
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Récapitulatif : $_title',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Affiche les réponses
                  Text(
                    'Vos réponses :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_questions.length, (index) {
                    final q = _questions[index];
                    final ans = _answers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '- ${q.text}\n   Réponse : ${ans?.valeur ?? "Aucune"}',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  Builder(builder: (_) {
                    final String randomTip = _quizManager.getRandomTip(_quizId);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conseil à retenir :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          randomTip,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),
                  Builder(builder: (_) {
                    final List<Badge> badges = _quizManager.getBadges(_quizId);
                    if (badges.isEmpty) return SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vos badges :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: badges.map((b) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  b.assetPath,
                                  width: 50,
                                  height: 50,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  b.title,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Retourne à l’écran précédent (avec true)
                        Navigator.of(context).pop(true);
                      },
                      child: Text('Terminer le Quiz'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // --- BOUTON "RECOMMENCER" QUAND LE QUIZ EST DÉJÀ COMPLÉTÉ ---
      floatingActionButton: _alreadyCompleted
          ? FloatingActionButton.extended(
        icon: Icon(Icons.refresh),
        label: Text('Recommencer'),
        onPressed: () async {
          // Efface les réponses sauvegardées puis réinitialise l’état
          await _quizManager.clearSavedAnswers(_quizId);
          setState(() {
            _alreadyCompleted = false;
            _answers = List<QuizAnswer?>.filled(_questions.length, null, growable: false);
          });
          _pageController.jumpToPage(0);
        },
      )
          : null,
    );
  }

  /// Sauvegarde toutes les réponses puis va à la page récap.
  Future<void> _saveAndGoToRecap() async {
    // Filtre les réponses null (au cas où) : on ne sauve que les QuizAnswer non-null
    final toSave = _answers.whereType<QuizAnswer>().toList();
    await _quizManager.saveUserResponses(_quizId, toSave);

    setState(() {
      _alreadyCompleted = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_questions.length);
      }
    });
  }
}
