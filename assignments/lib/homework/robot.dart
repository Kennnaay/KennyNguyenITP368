import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: RobotGrid()));
}

class RobotGrid extends StatefulWidget {
  @override
  _RobotGridState createState() => _RobotGridState();
}

class _RobotGridState extends State<RobotGrid> {
  final int gridSize = 5;
  int robotX = 2;
  int robotY = 2;

  void moveRobot(String direction) {
    setState(() {
      if (direction == 'up' && robotY > 0) {
        robotY--;
      } else if (direction == 'down' && robotY < gridSize - 1) {
        robotY++;
      } else if (direction == 'left' && robotX > 0) {
        robotX--;
      } else if (direction == 'right' && robotX < gridSize - 1) {
        robotX++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kenny's Robot"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Grid Area',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 55, 0)),
          ),
          SizedBox(height: 20),
          Container(
            width: 200,
            height: 200,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: gridSize * gridSize,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemBuilder: (context, index) {
                int x = index % gridSize;
                int y = index ~/ gridSize;

                return Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: Center(
                    child: (x == robotX && y == robotY)
                        ? Text(
                            'R',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => moveRobot('up'),
                child: Text('up', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => moveRobot('down'),
                child: Text('down', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => moveRobot('left'),
                child: Text('left', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => moveRobot('right'),
                child: Text('right', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
