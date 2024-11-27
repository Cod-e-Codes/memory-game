import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFFCE4EC), // Light Pink background for fun
        fontFamily: 'ComicNeue', // Playful font
      ),
      home: const DifficultyMenuScreen(),
    );
  }
}

class AnimatedGrid extends StatefulWidget {
  const AnimatedGrid({super.key});

  @override
  AnimatedGridState createState() => AnimatedGridState();
}

class AnimatedGridState extends State<AnimatedGrid> {
  static const int gridSize = 3;
  static const int animationDuration = 500; // in milliseconds
  List<Color> cellColors = [];
  List<Color> availableColors = [
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initialize the grid with default color (e.g., light pink).
    cellColors = List<Color>.filled(gridSize * gridSize, Colors.amberAccent);

    // Set up a timer to change the colors periodically.
    _timer = Timer.periodic(const Duration(milliseconds: animationDuration), (timer) {
      setState(() {
        // Randomly select a cell and assign a random color to it.
        final randomIndex = timer.tick % cellColors.length;
        final randomColor = availableColors[timer.tick % availableColors.length];
        cellColors[randomIndex] = randomColor;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridSize * gridSize,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: animationDuration),
              decoration: BoxDecoration(
                color: cellColors[index],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Text(
                  '',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class DifficultyMenuScreen extends StatelessWidget {
  const DifficultyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Difficulty',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'ComicNeue', // Playful font
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent, // Playful and vibrant
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedGrid(),
            const SizedBox(height: 40),
            _buildDifficultyButton(
                context, 'Easy', Colors.greenAccent, Colors.blueAccent),
            const SizedBox(height: 20),
            _buildDifficultyButton(
                context, 'Hard', Colors.redAccent, Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String difficulty,
      Color startColor, Color endColor) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12, horizontal: 36)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(30.0), // Rounded corners for modern look
          ),
        ),
        elevation: WidgetStateProperty.all(0), // No extra elevation
        backgroundColor: WidgetStateProperty.all(
            Colors.transparent), // Transparent to show gradient
      ),
      onPressed: () {
        // Navigate to the game screen with the selected difficulty
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryGame(difficulty: difficulty),
          ),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
          ),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // Subtle shadow color
              spreadRadius: 0, // No spreading
              blurRadius: 8, // Softer blur
              offset: const Offset(0, 4), // More natural offset
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
          alignment: Alignment.center,
          child: Text(
            difficulty,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class MemoryGame extends StatefulWidget {
  final String difficulty;

  const MemoryGame({super.key, required this.difficulty});

  @override
  MemoryGameState createState() => MemoryGameState();
}

class MemoryGameState extends State<MemoryGame> {
  List<String> easyData = ["🍎", "🍌", "🍇", "🍉", "🍎", "🍌", "🍇", "🍉"];
  List<String> hardData = [
    "🍎", "🍌", "🍇", "🍉", "🍍", "🥭", "🍓", "🍑",
    "🍎", "🍌", "🍇", "🍉", "🍍", "🥭", "🍓", "🍑"
  ];

  int gridSize = 4;
  List<String> data = [];
  List<GlobalKey<FlipCardState>> cardKeys = [];
  List<bool> cardMatched = [];
  int score = 0;
  int? firstCardIndex;
  int? secondCardIndex;
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    if (widget.difficulty == 'Easy') {
      data = easyData;
      gridSize = 4;
    } else {
      data = hardData;
      gridSize = 4;
    }
    resetGame();
  }

  void resetGame() {
    setState(() {
      data.shuffle();
      cardKeys =
          List.generate(data.length, (index) => GlobalKey<FlipCardState>());
      cardMatched = List.filled(data.length, false);
      score = 0;
      firstCardIndex = null;
      secondCardIndex = null;
    });
  }

  void checkMatch() {
    if (firstCardIndex != null && secondCardIndex != null) {
      if (data[firstCardIndex!] == data[secondCardIndex!]) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            cardMatched[firstCardIndex!] = true;
            cardMatched[secondCardIndex!] = true;
            score++;
            firstCardIndex = null;
            secondCardIndex = null;

            if (cardMatched.every((matched) => matched)) {
              if (score > bestScore) {
                bestScore = score;
              }
              showWinDialog();
            }
          });
        });
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          cardKeys[firstCardIndex!].currentState?.toggleCard();
          cardKeys[secondCardIndex!].currentState?.toggleCard();
          setState(() {
            firstCardIndex = null;
            secondCardIndex = null;
          });
        });
      }
    }
  }

  void handleCardFlip(int index) {
    if (!cardMatched[index]) {
      if (firstCardIndex == null) {
        setState(() {
          firstCardIndex = index;
        });
      } else if (secondCardIndex == null && index != firstCardIndex) {
        setState(() {
          secondCardIndex = index;
        });
        checkMatch();
      }
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20.0), // Rounded corners for dialog
          ),
          backgroundColor: Colors.deepPurpleAccent, // Match app color theme
          title: const Center(
            child: Text(
              "You Win!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'ComicNeue', // Matching playful font
              ),
            ),
          ),
          content: Text(
            "Congratulations! You've matched all the cards.\nBest Score: $bestScore",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white70,
              fontFamily: 'ComicNeue',
            ),
          ),
          actionsAlignment:
          MainAxisAlignment.center, // Center the action buttons
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.orangeAccent, // Playful button color
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12.0), // Rounded corners for button
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text(
                "Start New Game",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ComicNeue', // Matching font
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Memory Game - ${widget.difficulty}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'ComicNeue', // Playful font
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Score: $score',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (!cardMatched[index]) {
                  handleCardFlip(index);
                  cardKeys[index].currentState?.toggleCard();
                }
              },
              child: FlipCard(
                key: cardKeys[index],
                flipOnTouch: false,
                front: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "?",
                      style: TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                back: cardMatched[index]
                    ? const SizedBox.shrink()
                    : Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      data[index],
                      style: const TextStyle(
                          fontSize: 32.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
