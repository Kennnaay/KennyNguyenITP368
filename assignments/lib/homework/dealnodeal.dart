import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(home: DealOrNoDealGame()));
}

class DealOrNoDealGame extends StatefulWidget {
  @override
  _DealOrNoDealGameState createState() => _DealOrNoDealGameState();
}

class _DealOrNoDealGameState extends State<DealOrNoDealGame> {
  // list of all suit case values
  final List<int> values = [
    1,
    5,
    10,
    100,
    1000,
    5000,
    10000,
    100000,
    500000,
    1000000
  ];

  //  variables for FocusNode and which case, to be used later
  final FocusNode gameFocusNode = FocusNode();
  int focusedCase = 0;

  @override
  void dispose() {
    gameFocusNode.dispose();
    super.dispose();
  }

  // ========================= KEYBOARD INPUT LOGIC ========================= //
  void handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // after games terminates, enter or space bar resets the game
      if (gameEnded) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          startNewGame();
        }
        return;
      }

      // when an offer is made, D accepts, N denies
      if (offerStage) {
        if (event.logicalKey == LogicalKeyboardKey.keyD) {
          makeDecision(true);
        } else if (event.logicalKey == LogicalKeyboardKey.keyN) {
          makeDecision(false);
        }
        return;
      }

      // if a case number is typed using the number keys select corresponding case
      if (event.logicalKey.keyLabel.length == 1) {
        int? number = int.tryParse(event.logicalKey.keyLabel);
        if (number != null) {
          if (number == 0) number = 10;
          if (number >= 1 && number <= 10) {
            selectCase(number - 1);
            return;
          }
        }
      }

      // arrow keys allows user to select each suit case
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft: // left arrow key
          setState(() {
            focusedCase = (focusedCase - 1).clamp(0, 9);
          });
          break;
        case LogicalKeyboardKey.arrowRight: // right arrow key
          setState(() {
            focusedCase = (focusedCase + 1).clamp(0, 9);
          });
          break;
        case LogicalKeyboardKey.arrowUp: // up array key
          setState(() {
            focusedCase = (focusedCase - 5).clamp(0, 9);
          });
          break;
        case LogicalKeyboardKey.arrowDown: // down arrow key
          setState(() {
            focusedCase = (focusedCase + 5).clamp(0, 9);
          });
          break;

        // enter or space selects
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          selectCase(focusedCase);
          break;
      }
    }
  }

  /// 1. list of all unopened suit case values
  /// 2. copy of values to display which suit cases are left
  /// 3. list to hold just case values
  List<int> remainingValues = [];
  List<int> orderedValues = [];
  List<int> caseValues = [];

  /// 4. list of booleans representing whether each suit case is OPENED or not
  /// 5. list of booleans representing whether a suit case should be REVEALED or not
  List<bool> openedCases = List.filled(10, false);
  List<bool> revealedValues = List.filled(10, false);

  /// 6. int to hold value of suit case user chose to hold
  /// 7. int to represent currently selected suit case
  int? playerCase;
  int? selectedCase;

  /// 8. most recent offer to user
  int currentOffer = 0;

  /// 9. bool to represent whether game is ended or not
  /// 10. bool to represent whether user has been offered a deal or not
  bool gameEnded = false;
  bool offerStage = false;

  // main void
  @override
  void initState() {
    super.initState();
    startNewGame();
    gameFocusNode.requestFocus(); // Request focus here
  }

  // instantiation
  void startNewGame() {
    // initializing lists
    remainingValues = List.from(values);
    orderedValues = List.from(values);
    caseValues = List.from(remainingValues);
    openedCases = List.filled(10, false);
    revealedValues = List.filled(10, false);

    // shuffle lists for randomization
    remainingValues.shuffle();

    // initializing variables
    playerCase = null;
    selectedCase = null;
    gameEnded = false;
    offerStage = false;
    currentOffer = 0;
  }

  // function called when user selects a case
  void selectCase(int index) {
    // if player doesn't have a case, make selected case the player case
    if (playerCase == null) {
      setState(() {
        playerCase = index;
        offerStage = true;
        currentOffer = calculateOffer();
      });
    }

    // if player has a case, update state
    else if (!offerStage && !openedCases[index]) {
      setState(() {
        selectedCase = index; // store selected case
        openedCases[index] = true; // indicate this case to be opened
        offerStage =
            true; // set boolean to represent an offer has just been made
        currentOffer =
            calculateOffer(); // calculate offer based off remaining cases
      });
    }
  }

  // function to calculate the offer (90% of average of leftover cases)
  int calculateOffer() {
    if (remainingValues.isEmpty) return 0;
    double average =
        remainingValues.reduce((a, b) => a + b) / remainingValues.length;
    return (average * 0.9).round();
  }

  // function to handle when user clicks "deal" or "no deal"
  void makeDecision(bool deal) {
    // if player says deal, end game with the current offer
    if (deal) {
      endGame(currentOffer);
    }

    // if player says no deal, update state to reveal the value of the selected case
    else {
      setState(() {
        if (selectedCase != null) {
          // if there is a selected case
          revealedValues[selectedCase!] = true; // reveal selected case
          remainingValues.remove(caseValues[
              selectedCase!]); // remove selected case from remaining cases
          orderedValues.remove(caseValues[
              selectedCase!]); // remove selected case's value from remaining values
          selectedCase = null; // reset value so a new case can be selected
        }
        offerStage = false; // turn off state

        // if user chooses no deal on final case, end game with the value of the player's suit case
        if (remainingValues.length == 1) {
          endGame(remainingValues[0]);
        }
      });
    }
  }

  // function to display the case content based on its state
  String displayCaseContent(int index) {
    if (revealedValues[index]) {
      // show value of case only after user clicks "no Deal"
      return '\$${caseValues[index]}';
    } else if (openedCases[index] && !revealedValues[index]) {
      // display "OPENED" when user selects case
      return 'OPENED';
    } else if (playerCase == index) {
      // indicates which case is the players
      return 'Your Case\n#${index + 1}';
    } else {
      return 'Case\n#${index + 1}'; // all other unopened cases just display their label
    }
  }

  // function to end the game and display final amount won by user
  void endGame(int finalAmount) {
    setState(() {
      gameEnded = true;
      currentOffer = finalAmount;
    });
  }

  // main build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deal or No Deal')),
      body: RawKeyboardListener(
        focusNode: gameFocusNode,
        onKey: handleKeyPress,
        child: Column(
          // ========================= GRID OF SUIT CASES + DIRECTIONS ========================= //
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Keyboard Controls: Arrow keys to move • Numbers 1-9,0 to select • D for Deal • N for No Deal • Space/Enter to select',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  bool isFocused = focusedCase == index && !openedCases[index];
                  // ========================= SELECTING USING KEYBOARD ========================= //
                  return GestureDetector(
                    onTap: () => selectCase(index),
                    child: Card(
                      color: openedCases[index]
                          ? Colors.grey
                          : (playerCase == index
                              ? Colors.blue
                              : (isFocused
                                  ? Colors.orange[300]
                                  : Colors.orange)),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              displayCaseContent(index),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          if (isFocused)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // ========================= LIST OF REMAINING SUIT CASES ========================= //
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Remaining values: ${orderedValues.join(", ")}',
                style: TextStyle(fontSize: 24),
              ),
            ),
            // ========================= OFFER + DEAL\NO DEAL BUTTONS ========================= //
            if (offerStage && !gameEnded)
              Column(
                children: [
                  Text(
                    'Offer: \$${currentOffer}',
                    style: TextStyle(fontSize: 24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => makeDecision(true),
                        child: Text(
                          'DEAL (D)',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => makeDecision(false),
                        child: Text(
                          'NO DEAL (N)',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            // ========================= END SCREEN ========================= //
            if (gameEnded)
              Column(
                children: [
                  Text('Game Over! You won: \$${currentOffer}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        startNewGame();
                      });
                    },
                    child: Text('Play Again (Enter)'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
