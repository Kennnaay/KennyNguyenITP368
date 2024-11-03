import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// PancakeCubit
// Contains a constructor for a stack of pancakes
// and a function to flip the stack based on which pancake the user clicked
class PancakeCubit extends Cubit<List<int>> {
  PancakeCubit() : super([]);

  // constructor to create a new stack of pancakes
  void newPancakeStack(int totalNumberOfPancakes) {
    final shuffledStack =
        List<int>.generate(totalNumberOfPancakes, (i) => i + 1);
    shuffledStack.shuffle();
    emit(shuffledStack);
  }

  // function to flip the pancake stack
  void flipStack(int flippingIndex) {
    // if trying to flip the top pancake, do nothing
    if (flippingIndex < 0 || flippingIndex >= state.length) return;

    // iterate through the stack, swapping the current pancake with its mirror
    final updatedStack = List<int>.from(state);
    for (int i = 0; i <= flippingIndex ~/ 2; i++) {
      final temp = updatedStack[i];
      updatedStack[i] = updatedStack[flippingIndex - i];
      updatedStack[flippingIndex - i] = temp;
    }

    // update the state
    emit(updatedStack);
  }

  // function to check if the pancakes are sorted
  bool isSorted(List<int> pancakes) {
    // loop through stack, making sure each pancake is bigger than the one before it
    for (int i = 0; i < pancakes.length - 1; i++) {
      if (pancakes[i] > pancakes[i + 1]) {
        return false;
      }
    }
    return true;
  }
}

// main function
void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PancakeCubit()..newPancakeStack(5)),
      ],
      child: MaterialApp(
        home: Pancake(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    ),
  );
}

class Pancake extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PancakeCubit, List<int>>(
      listener: (context, pancakes) {
        // calls function to check if stack is sorted
        if (context.read<PancakeCubit>().isSorted(pancakes)) {
          // if yes, display win message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('You Win!!'),
                content: const Text('Pancakes are sorted!'),
                actions: [
                  TextButton(
                    child: Text('Keep Playing'),
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: PancakeView(),
    );
  }
}

class PancakeView extends StatefulWidget {
  @override
  _PancakeViewState createState() => _PancakeViewState();
}

class _PancakeViewState extends State<PancakeView> {
  // starting pancake stack size is 5
  int pancakeCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========== AppBar ========= //
      appBar: AppBar(
        title: Text('Kenny\'s Pancake Sorting'),
      ),
      // ========== Body ========= //
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ========== Instruction Text ========= //
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Pancake Sorting Game\n\n'
                  'Sort the pancakes from largest (bottom) to smallest (top).\n'
                  '\nHow to play:\n'
                  '1. Tap on a pancake to all the pancakes above it (including the one you clicked on).\n'
                  '2. Use the + and - buttons to change the amount of pancakes in the stack.\n'
                  '3. Use the refresh button to shuffle the pancakes.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
              // ========== Pancake Stack ========= //
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<PancakeCubit, List<int>>(
                    builder: (context, pancakes) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: pancakes.map((size) {
                          return PancakeWidget(sizeOfPancake: size);
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ========== BUTTONS ========= //
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ========== INCREMENT Total Amount Of Pancakes ========= //
              FloatingActionButton(
                onPressed: () {
                  if (pancakeCount < 20) {
                    setState(() {
                      pancakeCount++;
                    });
                    context.read<PancakeCubit>().newPancakeStack(pancakeCount);
                  }
                },
                child: Icon(Icons.add),
              ),
              SizedBox(height: 10),
              // ========== DECREMENT Total Amount Of Pancakes ========= //
              FloatingActionButton(
                onPressed: () {
                  if (pancakeCount > 2) {
                    setState(() {
                      pancakeCount--;
                    });
                    context.read<PancakeCubit>().newPancakeStack(pancakeCount);
                  }
                },
                child: Icon(Icons.remove),
              ),
            ],
          ),
          SizedBox(width: 10),
          // ========== RESHUFFLE Pancake Stack========= //
          FloatingActionButton(
            onPressed: () {
              context.read<PancakeCubit>().newPancakeStack(pancakeCount);
            },
            child: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

// Pancake widget- represents each individual pancake
class PancakeWidget extends StatelessWidget {
  // variable to hold size of pancake
  final int sizeOfPancake;

  // constructor
  const PancakeWidget({required this.sizeOfPancake});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // when pancake is clicked, call flip stack function
      onTap: () {
        final state = context.read<PancakeCubit>().state;
        context.read<PancakeCubit>().flipStack(state.indexOf(sizeOfPancake));
      },
      // container which makes the pancake
      child: Container(
        height: 50,
        width: 150 + (sizeOfPancake * 100),
        color: Colors.brown,
        margin: const EdgeInsets.symmetric(vertical: 2),
      ),
    );
  }
}
