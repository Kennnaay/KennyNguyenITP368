import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MonkeyTypeClone());
}

class MonkeyTypeClone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KennyType',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const TypingTestScreen(),
    );
  }
}

class TypingTestScreen extends StatefulWidget {
  const TypingTestScreen({super.key});

  @override
  _TypingTestScreenState createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends State<TypingTestScreen> {
  // list of words to pull from
  final List<String> _wordList = [
    "flutter",
    "program",
    "consider",
    "develop",
    "large",
    "app",
    "mobile",
    "development",
    "great",
    "dart",
    "professor",
    "classroom",
    "itp",
    "tuesday",
    "thursday",
    "semester",
    "afternoon",
    "android",
    "emulator",
    "audio",
    "barrett",
    "koster",
    "platform",
    "widget",
    "state",
    "framework",
    "debug",
    "design",
    "build",
    "student",
    "project",
    "lecture",
    "library",
    "function",
    "interface",
    "screen",
    "keyboard",
    "hotreload",
    "layout",
    "pixel",
    "syntax",
    "material",
    "output",
    "input",
    "component",
    "structure",
    "session",
    "engineer",
    "canvas",
    "performance",
    "syntax",
  ];

  // data members to be used in the program
  String _promptString = ""; // The full prompt string (including spaces)
  String _userInput = ""; // What the user has typed so far
  bool _isTestStarted = false;
  String _selectedPromptLength = "medium"; // Default prompt length
  String _selectedTime = "30"; // Default time
  int _timeLeft = 30;
  int _correctCharacters = 0; // Correctly typed characters
  bool _isShiftPressed = false; // Tracks if Shift is being held
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _generatePrompt();
  }

  ///
  /// generates the prompt that the user will have to type
  ///
  void _generatePrompt() {
    // determine word count based on selected prompt length
    int wordCount;
    switch (_selectedPromptLength) {
      case "short":
        wordCount = 10;
        break;
      case "medium":
        wordCount = 20;
        break;
      case "long":
        wordCount = 50;
        break;
      default:
        wordCount = 20;
    }

    // generate random unique words and limit to wordCount
    List<String> promptWords = List.of(_wordList)..shuffle();
    promptWords = promptWords.take(wordCount).toList(); // Limit to word count
    _promptString = promptWords.join(" "); // Join words with spaces
  }

  ///
  /// initializes variables top start the testing
  ///
  void _startTest() {
    setState(() {
      _isTestStarted = true;
      _userInput = "";
      _timeLeft = int.parse(_selectedTime);
      _correctCharacters = 0;
    });

    // start countdown
    Future.delayed(const Duration(seconds: 1), _decrementTime);
  }

  ///
  /// decreases the time left
  ///
  void _decrementTime() {
    if (_timeLeft > 0 && _isTestStarted) {
      setState(() {
        _timeLeft--;
      });
      Future.delayed(const Duration(seconds: 1), _decrementTime);
    } else {
      setState(() {
        _isTestStarted = false;
      });
    }
  }

  ///
  /// ends the test
  ///
  void _abortTest() {
    setState(() {
      _isTestStarted = false;
      _userInput = "";
      _timeLeft = int.parse(_selectedTime); // Reset time
    });
  }

  ///
  /// checks to see which keys were clicked and handles accordingly
  ///
  KeyEventResult _handleKeyPress(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final keyLabel = event.character;

      // Shift + Space to abort and go back to home screen
      if (_isShiftPressed && event.logicalKey == LogicalKeyboardKey.space) {
        _abortTest();
        return KeyEventResult.handled;
      }

      // handle Shift press
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        _isShiftPressed = true;
      }

      // handles Backspace
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        setState(() {
          if (_userInput.isNotEmpty) {
            _userInput = _userInput.substring(0, _userInput.length - 1);
          }
        });
        return KeyEventResult.handled;
      }

      // ignore non-character keys
      if (keyLabel == null || keyLabel.isEmpty) {
        return KeyEventResult.handled;
      }

      // add valid typed character
      setState(() {
        _userInput += keyLabel.toLowerCase();

        // check if user has completed the prompt
        if (_userInput == _promptString) {
          // end the test and navigate to the result screen
          _isTestStarted = false;
          _timeLeft = 0;
        }
      });
    } else if (event is KeyUpEvent) {
      // reset Shift state on release
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        _isShiftPressed = false;
      }
    }

    return KeyEventResult.handled;
  }

  ///
  /// changes prompt color to match correct/incorrect char input
  ///
  List<TextSpan> _buildPromptSpans() {
    List<TextSpan> spans = [];

    _correctCharacters = 0; // reset correct character count

    for (int i = 0; i < _promptString.length; i++) {
      Color color = Colors.grey;

      // highlight correct characters in the prompt
      if (i < _userInput.length) {
        if (_userInput[i].toLowerCase() == _promptString[i].toLowerCase()) {
          color = Colors.green;
          _correctCharacters++;
        } else {
          color = Colors.red;
        }
      }

      // add the character to the spans list
      spans.add(
        TextSpan(
          text: _promptString[i],
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return spans;
  }

  ///
  /// computes user accuracy
  ///
  double _calculateAccuracy() {
    if (_userInput.isEmpty) return 0;
    return (_correctCharacters / _userInput.length) * 100;
  }

  ///
  /// calculates user chars per sec
  ///
  double _calculateCPS() {
    return _correctCharacters / int.parse(_selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyPress,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isTestStarted && _timeLeft > 0)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ======================= Title: "kennytype" =======================
                      const Text(
                        "kennytype",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ======================= Prompt Length Selection =======================
                      const Text(
                        "Prompt Options",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedPromptLength == "short"
                                  ? Colors.yellow
                                  : Colors.black,
                              foregroundColor: _selectedPromptLength == "short"
                                  ? Colors.black
                                  : Colors.yellow,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedPromptLength = "short";
                              });
                            },
                            child: const Text("Short"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedPromptLength == "medium"
                                  ? Colors.yellow
                                  : Colors.black,
                              foregroundColor: _selectedPromptLength == "medium"
                                  ? Colors.black
                                  : Colors.yellow,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedPromptLength = "medium";
                              });
                            },
                            child: const Text("Medium"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedPromptLength == "long"
                                  ? Colors.yellow
                                  : Colors.black,
                              foregroundColor: _selectedPromptLength == "long"
                                  ? Colors.black
                                  : Colors.yellow,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedPromptLength = "long";
                              });
                            },
                            child: const Text("Long"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // =======================  Time Selection =======================
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedTime == "15"
                                  ? Colors.yellow
                                  : Colors.black,
                              foregroundColor: _selectedTime == "15"
                                  ? Colors.black
                                  : Colors.yellow,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedTime = "15";
                              });
                            },
                            child: const Text("15s"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedTime == "30"
                                  ? Colors.yellow
                                  : Colors.black,
                              foregroundColor: _selectedTime == "30"
                                  ? Colors.black
                                  : Colors.yellow,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedTime = "30";
                              });
                            },
                            child: const Text("30s"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedTime == "60"
                                  ? Colors.yellow
                                  : Colors.black,
                              foregroundColor: _selectedTime == "60"
                                  ? Colors.black
                                  : Colors.yellow,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedTime = "60";
                              });
                            },
                            child: const Text("60s"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // ======================= Start Test Button =======================
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 40,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side:
                              const BorderSide(color: Colors.yellow, width: 2),
                        ),
                        onPressed: () {
                          _focusNode.requestFocus();
                          _generatePrompt();
                          _startTest();
                        },
                        child: const Text(
                          'Start Test',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_isTestStarted)
                  Column(
                    children: [
                      // ======================= Abort early text =======================
                      Text(
                        "Shift + Space - abort test",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.yellow.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // =======================  Timer =======================
                      Text(
                        "$_timeLeft",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ======================= Prompt text =======================
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: _buildPromptSpans(),
                        ),
                      ),
                    ],
                  ),

                // ======================= RESULT =======================
                if (!_isTestStarted && _timeLeft == 0)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Test Finished!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Characters Per Second: ${_calculateCPS().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      Text(
                        'Accuracy: ${_calculateAccuracy().toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // =======================  Retry Button =======================
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side:
                              const BorderSide(color: Colors.yellow, width: 2),
                        ),
                        onPressed: () {
                          _generatePrompt();
                          _focusNode.requestFocus();
                          _startTest();
                        },
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ======================= Home Button =======================
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side:
                              const BorderSide(color: Colors.yellow, width: 2),
                        ),
                        onPressed: () {
                          setState(() {
                            _isTestStarted = false;
                            _userInput = "";
                            _timeLeft = int.parse(_selectedTime);
                          });
                        },
                        child: const Text(
                          'Home',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
