void main() {
  // loops through 1 - 10, printing out starting number and sequence
  for (int i = 1; i < 101; i++) {
    print('======= Start Number: $i =======');
    CollatzConjecture C = CollatzConjecture(startingNumber: i);
    C.startLoop();
    print(" ");
  }
}

class CollatzConjecture {
  // once a starting number is chosen, it shouldn't be changed
  final int startingNumber;

  // constructor
  CollatzConjecture({required this.startingNumber});

  /// ========== SEQUENCE GENERATOR ==========
  void startLoop() {
    // list to store steps for a given number
    List<int> steps = [];

    // variable to hold the largest number for any given sequence
    int largestNumber = 1;

    // starting number, taken from member variable
    int start = startingNumber;

    // if starting number is 1, just return map which is initialized with 1
    if (start == 1) {
      List<int> justOne = [1];
      print(justOne);
      return;
    }

    // initialize steps with the starting number
    steps.add(start);

    // main loop, goes until number is 1
    while (start > 1) {
      if (largestNumber < start) {
        largestNumber = start;
      }
      if (start % 2 == 0) {
        // if number is even, cut in half
        start = start ~/ 2;
        steps.add(start); // add number to sequence
      } else {
        // otherwise, 3 * number + 1
        start = (3 * start) + 1;
        steps.add(start); // add number to sequence
      }
    }

    // variable storing the length of the sequence
    int length = steps.length;

    print('Sequence: $steps'); // print sequence

    print(
        "-> Maximum Value: $largestNumber"); // print largest number that occurs in the sequence

    print("Length of Sequence: $length"); // print length of sequence
  }
}
