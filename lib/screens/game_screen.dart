import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(home: GameScreen()));
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double facePosition = 0;
  double alphabetSpeed = 0.8;
  int score = 0;
  bool gameOver = false;
  Timer? gameLoopTimer;
  Timer? alphabetTimer;
  int survivalTime = 0;
  bool _isDarkMode = false;
  DateTime _lastUpdate = DateTime.now();

  List<Map<String, dynamic>> alphabetList = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    startGame();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void moveFace(double move) {
    if (gameOver) return; // Prevent movement after game over
    setState(() {
      facePosition += move;
      facePosition = facePosition.clamp(-0.9, 0.9);
    });
  }

  void updateGame() {
    if (gameOver) return;

    final DateTime now = DateTime.now();
    final Duration deltaTime = now.difference(_lastUpdate);
    _lastUpdate = now;

    // Convert deltaTime to seconds for more precise movement
    final double dt = deltaTime.inMicroseconds / 1000000;

    setState(() {
      final Size screenSize = MediaQuery.of(context).size;
      final double screenHeight = screenSize.height;

      // Calculate precise dimensions
      final double pixelToNormX = 1 / screenSize.width * 2;  // Convert pixels to -1 to 1 range
      final double pixelToNormY = 1 / screenSize.height;     // Convert pixels to 0 to 1 range

      // Box dimensions (60x60 pixels)
      final double boxWidth = 60 * pixelToNormX;
      final double boxHeight = 60 * pixelToNormY;

      // Letter dimensions (30x30 pixels)
      final double letterWidth = 30 * pixelToNormX;
      final double letterHeight = 30 * pixelToNormY;

      // Box boundaries with pixel-perfect conversion
      final double boxTop = 0.8;  // 80% from top
      final double boxBottom = boxTop + boxHeight;
      final double boxLeft = facePosition - (boxWidth / 2);
      final double boxRight = facePosition + (boxWidth / 2);

      bool collisionDetected = false;

      for (int i = 0; i < alphabetList.length; i++) {
        // Update position using delta time for smooth movement
        alphabetList[i]['y'] += alphabetSpeed * dt;

        // Letter boundaries with proper scaling
        final double letterLeft = alphabetList[i]['x'] - (letterWidth / 2);
        final double letterRight = alphabetList[i]['x'] + (letterWidth / 2);
        final double letterTop = alphabetList[i]['y'];
        final double letterBottom = letterTop + letterHeight;

        // Add small tolerance to prevent false collisions (2 pixels worth of space)
        final double tolerance = 2 * pixelToNormY;

        // Check for actual overlap with tolerance
        bool hasHorizontalOverlap = letterRight > (boxLeft + tolerance) &&
            letterLeft < (boxRight - tolerance);
        bool hasVerticalOverlap = letterBottom > (boxTop + tolerance) &&
            letterTop < (boxBottom - tolerance);

        if (hasHorizontalOverlap && hasVerticalOverlap) {
          collisionDetected = true;
          break;
        }
      }

      if (collisionDetected) {
        handleGameOver();
      } else {
        // Update score and handle alphabet removal
        alphabetList.removeWhere((alphabet) {
          if (alphabet['y'] > 1.0) {
            score++;

            // Smoother difficulty progression
            if (score % 5 == 0) {
              // Logarithmic speed increase for better game balance
              alphabetSpeed += 0.05 * (1.0 - (alphabetSpeed / 5.0));
              alphabetSpeed = min(alphabetSpeed, 5.0);
            }
            return true;
          }
          return false;
        });

        // Update survival time based on actual elapsed time
        survivalTime += (dt * 1000).round();
      }
    });
  }

  void handleGameOver() {
    gameOver = true;
    // Ensure timers are properly cleaned up
    gameLoopTimer?.cancel();
    gameLoopTimer = null;
    alphabetTimer?.cancel();
    alphabetTimer = null;

    // Optional: Save high score or other game stats here
  }

  void createAlphabets() {
    alphabetTimer = Timer.periodic(Duration(milliseconds: 700), (timer) {
      if (gameOver) return;
      setState(() {
        int numAlphabets = 1;

        // Increase difficulty based on score with lower thresholds
        if (score >= 100) {
          // Higher chance for more letters (up to 4)
          double rand = Random().nextDouble();
          if (rand < 0.6) {
            numAlphabets = 4;
          } else if (rand < 0.9) {
            numAlphabets = 3;
          } else {
            numAlphabets = 2;
          }
        } else if (score >= 30) {
          // More frequent 2-letter spawns
          numAlphabets = (Random().nextDouble() < 0.6) ? 2 : 1;
        }

        // Wider and more varied spawn positions
        List<double> spawnOffsets = [-0.4, -0.3, -0.2, -0.1, 0.0, 0.1, 0.2, 0.3, 0.4];
        List<double> selectedOffsets = [];

        // Ensure unique positions to prevent overlap
        while (selectedOffsets.length < numAlphabets) {
          double offset = spawnOffsets[Random().nextInt(spawnOffsets.length)];
          double xPosition = (facePosition + offset).clamp(-0.9, 0.9);
          if (!selectedOffsets.contains(xPosition)) {
            selectedOffsets.add(xPosition);
          }
        }

        // Add alphabets with mixed characters (A-Z, a-z, 0-9)
        for (double xPosition in selectedOffsets) {
          int randVal = Random().nextInt(62); // 26*2 letters + 10 digits
          String char;
          if (randVal < 26) {
            char = String.fromCharCode(65 + randVal); // A-Z
          } else if (randVal < 52) {
            char = String.fromCharCode(97 + (randVal - 26)); // a-z
          } else {
            char = String.fromCharCode(48 + (randVal - 52)); // 0-9
          }

          alphabetList.add({
            'x': xPosition,
            'y': 0.0,
            'char': char,
          });
        }
      });
    });
  }

  void startGame() {
    _lastUpdate = DateTime.now();
    setState(() {
      score = 0;
      survivalTime = 0;
      gameOver = false;
      facePosition = 0;
      alphabetSpeed = 0.8;
      alphabetList.clear();
    });

    createAlphabets();

    // Use a more precise timer interval for smoother gameplay
    gameLoopTimer = Timer.periodic(
        const Duration(microseconds: 16667), // Approximately 60 FPS
            (timer) => updateGame()
    );
  }

  void restartGame() {
    startGame();
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    alphabetTimer?.cancel();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isDarkMode ? Colors.black : Colors.white;
    Color textColor = _isDarkMode ? Colors.white : Colors.black;
    Color faceColor = _isDarkMode ? Colors.white : Colors.black;
    Color alphabetColor = _isDarkMode ? Colors.white : Colors.black;
    Color buttonColor = _isDarkMode ? Colors.green : Colors.blue;

    return Focus(
      autofocus: true, // Ensure it captures keyboard input
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
            moveFace(-0.1); // Move left
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
            moveFace(0.1); // Move right
          }
        }
        return KeyEventResult.handled;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          centerTitle: true,
          title: Center(
            child: Text(
              "SCORE: $score",
              style: TextStyle(fontFamily: 'PressStart2P', fontSize: 25, color: textColor),
            ),
          ),
        ),
        body: Center(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(color: backgroundColor),
              ),
              Positioned(
                bottom: 50,
                left: MediaQuery.of(context).size.width * (facePosition + 1) / 2 - 35,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: faceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '-_-',
                      style: TextStyle(fontFamily: 'PressStart2P', fontSize: 15, color: backgroundColor),
                    ),
                  ),
                ),
              ),
              for (var alphabet in alphabetList)
                Positioned(
                  top: alphabet['y'] * MediaQuery.of(context).size.height,
                  left: MediaQuery.of(context).size.width * (alphabet['x'] + 1) / 2 - 15,
                  child: Text(
                    alphabet['char'],
                    style: TextStyle(fontFamily: 'PressStart2P', fontSize: 30, color: alphabetColor),
                  ),
                ),
              if (gameOver)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Game Over",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'PressStart2P', fontSize: 35, color: textColor),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: restartGame,
                        child: Text("Restart", style: TextStyle(fontFamily: 'PressStart2P', fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onPanUpdate: (details) {
                  moveFace(details.delta.dx / 200);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}