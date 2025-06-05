// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart' hide Badge;
import 'package:airpur/services/material.dart';      // <— là où your QuizContent, Badge, etc. sont définis
import 'package:airpur/services/quiz_manager.dart'; // <— là où getQuestions, getRandomTip, getBadges,etc.
import 'package:intl/intl.dart'; // pour formatter la date si besoin

import '../models/quiz_models.dart'; // <— contient Question, QuestionType, QuizAnswer

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

  // ** Liste pour stocker les réponses de l’utilisateur **
  late final List<QuizAnswer?> _answers;

  // Pour le champ texte / numeric / decimal
  final TextEditingController _textController = TextEditingController();

  // Pour le type date, on stockera localement la date sélectionnée
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _quizId = widget.quizId;
    _title = widget.title;
    final List<Question> questions = _quizManager.getQuestions(_quizId);
    // On initialise la liste de réponses à la même longueur que les questions, 
    // avec des valeurs null (remplies lorsqu’on valide)
    _answers = List<QuizAnswer?>.filled(questions.length, null, growable: false);

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // On vide le controller texte et la date chaque fois qu’on change de page
      _textController.clear();
      _selectedDate = null;
    }
  }

  // Ouvre un date picker et stocke dans _selectedDate
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
    final List<Question> questions = _quizManager.getQuestions(_quizId);
    final int totalPages = questions.length + 1; // +1 pour la page récapitulative

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalPages,
        itemBuilder: (context, pageIndex) {
          // Si on est sur une question (pas la page récapitulative)
          if (pageIndex < questions.length) {
            final Question currentQ = questions[pageIndex];

            // On remet à zéro le TextEditingController si on revient “en arrière”
            // (ici on suppose qu’on ne fait jamais de “retour en arrière”,
            // mais si vous ajoutez un bouton précédent, pensez à clear le controller
            // et ré-initialiser _selectedDate avec la valeur déjà entrée, si existante.)

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Affiche “Question X / N”
                  Text(
                    'Question ${pageIndex + 1} / ${questions.length}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  // Le texte de la question
                  Text(
                    currentQ.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // ** SWITCH SUR LE TYPE DE LA QUESTION **
                  if (currentQ.type == QuestionType.choixUnique)
                  // === Choix Unique ===
                    ...currentQ.options.map((optionTexte) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            // Stocke la réponse “optionTexte” dans _answers
                            _answers[pageIndex] = QuizAnswer(
                              questionId: currentQ.id,
                              valeur: optionTexte,
                            );
                            _goToNextPage();
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
                              // Si l’utilisateur n’a rien saisi, on peut empêcher le passage
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
                              _goToNextPage();
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
                                // Vous pouvez ajouter ici un parse pour vérifier que c’est vraiment un nombre
                                _answers[pageIndex] = QuizAnswer(
                                  questionId: currentQ.id,
                                  valeur: answerNum,
                                );
                                _goToNextPage();
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
                                  _goToNextPage();
                                },
                                child: Text('Suivant'),
                              ),
                            ],
                          ),
                        )

                      else
                      // === Autres types non gérés (sécuritaire) ===
                        Center(child: Text('Type de question non géré')),
                ],
              ),
            );
          }

          // *** PAGE RÉCAPITULATIVE (dernière page) ***
          // pageIndex == questions.length
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

                  // On peut afficher ici les réponses collectées
                  Text(
                    'Vos réponses :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(questions.length, (index) {
                    final q = questions[index];
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
                    final String randomTip = _quizManager.getRandomTip(_quizId) ?? '';
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
                    final List<Badge> badges = _quizManager.getBadges(_quizId) ?? [];
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
                        // Quand l'utilisateur clique sur “Terminer le quiz”,
                        // on renvoie `true` pour signaler que le quiz est complété
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
    );
  }
}
