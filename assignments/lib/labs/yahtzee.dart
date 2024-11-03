import "package:flutter/material.dart";
import 'dart:math';

void main() {
  runApp(Yahtzee());
}

class Yahtzee extends StatelessWidget {
  Yahtzee({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Yahtzee Roller",
      home: YahtzeeState(),
    );
  }
}

class YahtzeeState extends StatefulWidget {
  @override
  State<YahtzeeState> createState() => Home();
}

class Home extends State<YahtzeeState> {
  // initializing random number generator
  final Random _random = Random();

  // list of dice values (initially set to 1 for each die)
  List<int> _diceValues = List.filled(5, 1);

  // list to keep track of which dice are held (false means not held)
  List<bool> _diceHeld = List.filled(5, false);

  // method to roll dice, skips any dice being "held"
  void rollDiceHandler() {
    setState(() {
      for (int i = 0; i < 5; i++) {
        if (!_diceHeld[i]) {
          // if die is not held, assign a new random value between 1 and 6
          _diceValues[i] = _random.nextInt(6) + 1;
        }
      }
    });
  }

  // method to toggle hold status of a die
  void toggleHoldHandler(int index) {
    setState(() {
      // toggle the hold status for the die at the given index
      _diceHeld[index] = !_diceHeld[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kenny Yahtzee Roller")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // row to display all five dice with their current values represented by dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Column(
                children: [
                  // custom widget to draw dice face based on current value
                  DiceFace(value: _diceValues[index]),
                  // button to toggle hold status of the die
                  ElevatedButton(
                    onPressed: () => toggleHoldHandler(index),
                    child: Text(_diceHeld[index] ? "Release" : "Hold"),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 20),
          // button to roll all dice (only non-held dice change)
          ElevatedButton(
            onPressed: rollDiceHandler,
            child: Text("Roll Dice"),
          ),
        ],
      ),
    );
  }
}

// custom widget to draw a dice face with dots based on value
class DiceFace extends StatelessWidget {
  final int value;

  DiceFace({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: DicePainter(value),
      ),
    );
  }
}

// painter class to draw dots for dice faces
class DicePainter extends CustomPainter {
  final int value;
  DicePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final dotRadius = 4.0;
    final center = size.width / 2;

    // helper function to draw a dot at (x, y)
    void drawDot(double x, double y) {
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }

    // switch case for each dice face value with dot positions
    switch (value) {
      // one dots
      case 1:
        drawDot(center, center);
        break;
      // two dots
      case 2:
        drawDot(size.width * 0.25, size.height * 0.25);
        drawDot(size.width * 0.75, size.height * 0.75);
        break;
      // three dots
      case 3:
        drawDot(size.width * 0.25, size.height * 0.25);
        drawDot(center, center);
        drawDot(size.width * 0.75, size.height * 0.75);
        break;
      // four dots
      case 4:
        drawDot(size.width * 0.25, size.height * 0.25);
        drawDot(size.width * 0.75, size.height * 0.25);
        drawDot(size.width * 0.25, size.height * 0.75);
        drawDot(size.width * 0.75, size.height * 0.75);
        break;
      // five dots
      case 5:
        drawDot(size.width * 0.25, size.height * 0.25);
        drawDot(size.width * 0.75, size.height * 0.25);
        drawDot(center, center);
        drawDot(size.width * 0.25, size.height * 0.75);
        drawDot(size.width * 0.75, size.height * 0.75);
        break;
      // six dots
      case 6:
        drawDot(size.width * 0.25, size.height * 0.25);
        drawDot(size.width * 0.75, size.height * 0.25);
        drawDot(size.width * 0.25, center);
        drawDot(size.width * 0.75, center);
        drawDot(size.width * 0.25, size.height * 0.75);
        drawDot(size.width * 0.75, size.height * 0.75);
        break;
    }
  }

  // added by the "quick fix" helper in vscode... function is needed for CustomPainter class to work
  @override
  bool shouldRepaint(DicePainter oldDelegate) => oldDelegate.value != value;
}
