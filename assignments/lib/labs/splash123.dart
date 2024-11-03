// Barrett Koster
// demo of Routing/Navigation

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

TextStyle ts = TextStyle(fontSize: 30);

class CounterState {
  int count;
  CounterState(this.count);
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(0));

  void inc() {
    emit(CounterState(state.count + 1));
  }
}

void main() {
  runApp(RoutesDemo());
}

class RoutesDemo extends StatelessWidget {
  RoutesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    String title = "Routes Demo";
    return MaterialApp(title: title, home: TopBloc(title: title));
  }
}

class TopBloc extends StatelessWidget {
  final String title;
  TopBloc({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (context) => CounterCubit(),
      child: BlocBuilder<CounterCubit, CounterState>(
          builder: (context, state) => Route1(title: title)),
    );
  }
}

class Route1 extends StatelessWidget {
  final String title;
  Route1({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    CounterCubit cc = BlocProvider.of<CounterCubit>(context);
    return Scaffold(
      appBar: AppBar(title: Text(title, style: ts)),
      body: Column(
        children: [
          Text("page 1", style: ts),
          Text("${cc.state.count}", style: ts),
          ElevatedButton(
            onPressed: () {
              cc.inc();
            },
            child: Text("add 1", style: ts),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => Route2(title: title, cc: cc)),
              );
            },
            child: Text("go to page 2", style: ts),
          ),
        ],
      ),
    );
  }
}

class Route2 extends StatelessWidget {
  final String title;
  final CounterCubit cc;
  Route2({required this.title, required this.cc, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>.value(
      value: cc,
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(title, style: ts)),
            body: Column(
              children: [
                Text("page 2", style: ts),
                Text("${cc.state.count}", style: ts),
                ElevatedButton(
                  onPressed: () {
                    cc.inc();
                  },
                  child: Text("add 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("go back to page 1", style: ts),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              Route3(titleOfPage: title, counterCubit: cc)),
                    );
                  },
                  child: Text("go to page 3", style: ts),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ======================== THIRD PAGE ======================== //
class Route3 extends StatelessWidget {
  // title and counter cubit
  final String titleOfPage;
  final CounterCubit counterCubit;

  // constructor
  Route3({required this.titleOfPage, required this.counterCubit, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>.value(
      value: counterCubit,
      child: BlocBuilder<CounterCubit, CounterState>(
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                  title: Text(
                titleOfPage,
                style: ts,
              )),

              // ======================== BODY ======================== //
              body: Column(
                children: [
                  Text("page 3", style: ts),
                  Text("${counterCubit.state.count}", style: ts),

                  // button to increment the counter
                  ElevatedButton(
                    onPressed: () {
                      counterCubit.inc();
                    },
                    child: Text("add 1", style: ts),
                  ),

                  // button to go back one page
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("go back to page 2", style: ts),
                  ),

                  // button to go back 2 pages
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text("go back to page 1", style: ts),
                  ),
                ],
              ));
        },
      ),
    );
  }
}
