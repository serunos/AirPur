// lib/screens/tictactoe_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({Key? key}) : super(key: key);

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  // '' (vide), 'X' = joueur humain, 'O' = IA
  List<String> _board = List.generate(9, (_) => '');
  bool _isHumanTurn = true;         // true = tour de X (humain), false = tour de O (IA)
  String _gameMessage = '';
  int _aiMovesCount = 0;            // Compte le nombre de coups joués par l’IA
  final Random _random = Random();  // Pour choisir aléatoirement parmi les deux meilleures options

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  void _resetBoard() {
    setState(() {
      _board = List.generate(9, (_) => '');
      _isHumanTurn = true;
      _gameMessage = '';
      _aiMovesCount = 0;
    });
  }

  void _handleTap(int index) {
    // Si la case n'est pas vide, si la partie est finie, ou si ce n'est pas le tour de l'humain, on ignore
    if (_board[index] != '' || _gameMessage.isNotEmpty || !_isHumanTurn) return;

    setState(() {
      _board[index] = 'X';
      _isHumanTurn = false;
      _checkWinner();
    });

    // Si personne n'a gagné, on laisse un petit délai puis on lance l'IA
    if (_gameMessage.isEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _aiMove();
      });
    }
  }

  void _aiMove() {
    // L'IA choisit son coup :
    int bestIndex = _getBestMove(_board);

    setState(() {
      _board[bestIndex] = 'O';
      _aiMovesCount += 1;    // Incrémenter le compteur de coups IA
      _isHumanTurn = true;
      _checkWinner();
    });
  }

  void _checkWinner() {
    const List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      final a = pattern[0], b = pattern[1], c = pattern[2];
      if (_board[a] != '' &&
          _board[a] == _board[b] &&
          _board[a] == _board[c]) {
        setState(() {
          if (_board[a] == 'X') {
            _gameMessage = 'Vous avez gagné !';
          } else {
            _gameMessage = 'L’IA a gagné !';
          }
        });
        return;
      }
    }

    // Si toutes les cases sont remplies sans gagnant → match nul
    if (!_board.contains('')) {
      setState(() {
        _gameMessage = 'Match nul !';
      });
    }
  }

  /// Renvoie l'indice du meilleur coup pour l'IA (O).
  /// Pendant les deux premiers coups de l'IA (_aiMovesCount < 2), 
  /// on récolte les deux meilleurs scores et on en choisit un au hasard.
  int _getBestMove(List<String> boardState) {
    const double epsilon = 0.15; // 15% de chance de jouer un coup aléatoire
    List<int> emptyCells = [];
    for (int i = 0; i < 9; i++) {
      if (boardState[i] == '') emptyCells.add(i);
    }

    // 1) Avec probabilité ε → on choisit un index aléatoire parmi les cases libres
    if (emptyCells.isNotEmpty && _random.nextDouble() < epsilon) {
      return emptyCells[_random.nextInt(emptyCells.length)];
    }

    // 2) Sinon, on joue optimal via Minimax (comme avant)
    int bestScore = -1000;
    int move = emptyCells.first; // initialisation
    for (int i in emptyCells) {
      boardState[i] = 'O';
      int score = _minimax(boardState, false);
      boardState[i] = '';
      if (score > bestScore) {
        bestScore = score;
        move = i;
      }
    }
    return move;
  }

  /// Minimax : retourne le score pour la position actuelle (avec joueur courant)
  /// +1 si l’IA (O) gagne, -1 si l’humain (X) gagne, 0 sinon.
  int _minimax(List<String> boardState, bool isAiTurn) {
    final winner = _evaluateBoard(boardState);
    if (winner != 0) return winner;

    // Si aucune case libre → match nul
    if (!boardState.contains('')) return 0;

    if (isAiTurn) {
      int maxEval = -1000;
      for (int i = 0; i < 9; i++) {
        if (boardState[i] == '') {
          boardState[i] = 'O';
          int eval = _minimax(boardState, false);
          boardState[i] = '';
          maxEval = eval > maxEval ? eval : maxEval;
        }
      }
      return maxEval;
    } else {
      int minEval = 1000;
      for (int i = 0; i < 9; i++) {
        if (boardState[i] == '') {
          boardState[i] = 'X';
          int eval = _minimax(boardState, true);
          boardState[i] = '';
          minEval = eval < minEval ? eval : minEval;
        }
      }
      return minEval;
    }
  }

  /// Évalue immédiatement si l'une des combinaisons gagnantes est remplie
  /// Retourne +1 si O gagne, -1 si X gagne, 0 sinon.
  int _evaluateBoard(List<String> b) {
    const List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      final a = pattern[0], b1 = pattern[1], c = pattern[2];
      if (b[a] != '' && b[a] == b[b1] && b[a] == b[c]) {
        if (b[a] == 'O') return 1;
        if (b[a] == 'X') return -1;
      }
    }
    return 0;
  }

  Widget _buildCell(int index) {
    return GestureDetector(
      onTap: () => _handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
        ),
        child: Center(
          child: Text(
            _board[index],
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _board[index] == 'X'
                  ? Colors.blue
                  : (_board[index] == 'O' ? Colors.red : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Si partie terminée, affiche message + bouton Recommencer
          if (_gameMessage.isNotEmpty) ...[
            Text(
              _gameMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetBoard,
              child: const Text('Recommencer'),
            ),
            const SizedBox(height: 32),
          ] else ...[
            // Sinon, affiche le tour en cours (humain ou IA)
            Text(
              _isHumanTurn ? 'Votre tour (X)' : 'Tour de l’IA (O)…',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
          ],

          // Grille 3×3
          AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 9,
              itemBuilder: (_, index) => _buildCell(index),
            ),
          ),
        ],
      ),
    );
  }
}
