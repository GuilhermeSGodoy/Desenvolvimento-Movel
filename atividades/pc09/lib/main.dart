import 'package:flutter/material.dart';

void main() {
  runApp(const BasketballScoreApp());
}

class BasketballScoreApp extends StatelessWidget {
  const BasketballScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScorePage(),
    );
  }
}

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  int team1Score = 0;
  int team2Score = 0;
  int lastScore = 0;
  bool isLastTeam1 = true;
  bool canUndo = false;

  void updateScore(int score, bool isTeam1) {
    setState(() {
      lastScore = score;
      if (isTeam1) {
        team1Score += score;
        isLastTeam1 = true;
      } else {
        team2Score += score;
        isLastTeam1 = false;
      }
      canUndo = true;
    });
  }

  void undoLastScore() {
    setState(() {
      if (isLastTeam1) {
        team1Score -= lastScore;
      } else {
        team2Score -= lastScore;
      }
      canUndo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basquete - Pontuação'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Time A: $team1Score',
                    style: const TextStyle(fontSize: 24),
                  ),
                  ElevatedButton(
                    onPressed: () => updateScore(1, true),
                    child: const Text('Lance Livre'),
                  ),
                  ElevatedButton(
                    onPressed: () => updateScore(2, true),
                    child: const Text('2 Pontos'),
                  ),
                  ElevatedButton(
                    onPressed: () => updateScore(3, true),
                    child: const Text('3 Pontos'),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Time B: $team2Score',
                    style: const TextStyle(fontSize: 24),
                  ),
                  ElevatedButton(
                    onPressed: () => updateScore(1, false),
                    child: const Text('Lance Livre'),
                  ),
                  ElevatedButton(
                    onPressed: () => updateScore(2, false),
                    child: const Text('2 Pontos'),
                  ),
                  ElevatedButton(
                    onPressed: () => updateScore(3, false),
                    child: const Text('3 Pontos'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: canUndo ? undoLastScore : null,
            child: const Text('Voltar Lance'),
          ),
        ],
      ),
    );
  }
}
