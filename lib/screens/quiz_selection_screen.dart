import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airpur/services/quiz_manager.dart';
import 'package:airpur/screens/quiz_screen.dart';
import 'package:flutter/cupertino.dart';

class QuizSelectionScreen extends StatefulWidget {
  @override
  _QuizSelectionScreenState createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  final QuizManager _quizManager = QuizManager();
  late Future<Set<String>> _completedQuizzesFuture;

  @override
  void initState() {
    super.initState();
    // Au démarrage, on charge l’ensemble des quiz déjà complétés
    _completedQuizzesFuture = _loadCompletedQuizIds();
  }

  // Charge depuis SharedPreferences le set des quiz terminés
  Future<Set<String>> _loadCompletedQuizIds() async {
    final prefs = await SharedPreferences.getInstance();
    // On stocke la liste sous forme de List<String> sous la clé "completedQuizzes"
    final List<String>? list = prefs.getStringList('completedQuizzes');
    if (list == null) return <String>{};
    return list.toSet();
  }

  // Enregistre en local qu’un [quizId] est terminé (à appeler depuis QuizScreen)
  static Future<void> markQuizAsCompleted(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList('completedQuizzes') ?? <String>[];
    if (!current.contains(quizId)) {
      current.add(quizId);
      await prefs.setStringList('completedQuizzes', current);
    }
  }

  @override
  Widget build(BuildContext context) {
    // On récupère d’abord la liste de tous les IDs de quiz
    final List<String> allQuizIds = _quizManager.getAllQuizIds();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sélection des Quizzes'),
      ),
      body: FutureBuilder<Set<String>>(
        future: _completedQuizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // En attendant le chargement
            return Center(child: CircularProgressIndicator());
          }
          final completedSet = snapshot.data ?? <String>{};

          return ListView.builder(
            itemCount: allQuizIds.length,
            itemBuilder: (context, index) {
              final quizId = allQuizIds[index];
              // Ici, on peut “humaniser” le titre du quiz.
              // Exemple simple : si vous avez un map quizTitles dans QuizManager, appelez _quizManager.getQuizTitle(quizId).
              String displayTitle = quizId; // par défaut on affiche l’ID
              switch (quizId) {
                case 'quiz1':
                  displayTitle = 'Profil Utilisateur';
                  break;
                case 'quiz2':
                  displayTitle = 'Connaissances Santé';
                  break;
                case 'quiz3':
                  displayTitle = 'Motivation & Attitude';
                  break;
              // Ajoutez autant de cas que nécessaire pour “humaniser” le titre.
              }

              final bool isDone = completedSet.contains(quizId);

              return ListTile(
                title: Text(displayTitle),
                  trailing: isDone
                        ? Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            color: Colors.green, // ou la couleur de votre choix
                            size: 30,            // ajustez la taille si besoin
                          )
                    : null,
                onTap: () async {
                  // Dès qu’on tape, on lance le QuizScreen en passant quizId
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(quizId: quizId, title: displayTitle),
                    ),
                  );
                  // Si le quiz a renvoyé “terminé” (true), on enregistre et on raffraîchit la liste
                  if (result == true) {
                    await markQuizAsCompleted(quizId);
                    setState(() {
                      _completedQuizzesFuture = _loadCompletedQuizIds();
                    });
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
