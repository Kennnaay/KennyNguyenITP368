import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ConverterPage(),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  _ConverterPageState createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  String _input = '';
  String _output = '';
  bool _isCelsiusToFahrenheit = true;
  bool _isPoundsToKilograms = true;
  bool _isTemperature = true;

  // function to update the input of the user
  void _updateInput(String value) {
    setState(() {
      if (value == 'C') {
        // clears user input field
        _input = '';
      } else if (value == '⌫') {
        // deletes one number
        _input =
            _input.isNotEmpty ? _input.substring(0, _input.length - 1) : '';
      } else if (value == '.' && !_input.contains('.')) {
        // if user inputs '.' and input field does not already have a '.', add a '.'
        _input += value;
      } else if (value != '.') {
        // every other input, append to the end
        _input += value;
      }
      _convert(); // call convert function
    });
  }

  void _convert() {
    if (_input.isEmpty) {
      // empty field check
      _output = '';
      return;
    }

    double? inputValue = double.tryParse(_input);
    if (inputValue == null) {
      _output = 'Invalid input';
      return;
    }

    double result;
    // if in temperature conversion mode
    if (_isTemperature) {
      // converts celsius to fahrenheit
      if (_isCelsiusToFahrenheit) {
        result = (inputValue * 9 / 5) + 32;
        _output = '${result.toStringAsFixed(2)}°F';
      }
      // converts fahrenheit to celsius
      else {
        result = (inputValue - 32) * 5 / 9;
        _output = '${result.toStringAsFixed(2)}°C';
      }
    }
    // if in weight conversion mode
    else {
      // converts lbs to kgs
      if (_isPoundsToKilograms) {
        result = inputValue * 0.453592;
        _output = '${result.toStringAsFixed(2)} kg';
      }
      // converts kgs to lbs
      else {
        result = inputValue / 0.453592;
        _output = '${result.toStringAsFixed(2)} lbs';
      }
    }
  }

  // handles button to switch modes
  void _toggleConversion() {
    setState(() {
      if (_isTemperature) {
        _isCelsiusToFahrenheit = !_isCelsiusToFahrenheit;
      } else {
        _isPoundsToKilograms = !_isPoundsToKilograms;
      }
      _convert();
    });
  }

  // switches unit
  void _toggleUnit() {
    setState(() {
      _isTemperature = !_isTemperature;
      _input = '';
      _output = '';
    });
  }

  Widget _buildNumberButton(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          onPressed: () => _updateInput(label),
          child: Text(label, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isTemperature
            ? 'Temperature Converter'
            : 'Weight Converter'), // title changes depending on state
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===================== user input field =================
            Text(
              _input,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ===================== outputs conversion =====================
            Text(
              _output,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ===================== number inputs =====================
            Row(
              children: [
                _buildNumberButton('7'),
                _buildNumberButton('8'),
                _buildNumberButton('9'),
              ],
            ),
            Row(
              children: [
                _buildNumberButton('4'),
                _buildNumberButton('5'),
                _buildNumberButton('6'),
              ],
            ),
            Row(
              children: [
                _buildNumberButton('1'),
                _buildNumberButton('2'),
                _buildNumberButton('3'),
              ],
            ),
            Row(
              children: [
                _buildNumberButton('0'),
                _buildNumberButton('.'),
                _buildNumberButton('⌫'),
              ],
            ),
            Row(
              children: [
                _buildNumberButton('C'),
              ],
            ),
            const SizedBox(height: 20),

            // ===================== Button to switch between celsius and fahrenheit conversion =====================
            ElevatedButton(
              onPressed: _toggleConversion,
              child: Text('Switch ${_isTemperature ? "C ↔ F" : "lbs ↔ kg"}'),
            ),
            const SizedBox(height: 20),

            // ===================== Button to switch from lbs to kgs =====================
            ElevatedButton(
              onPressed: _toggleUnit,
              child: Text(
                  'Switch to ${_isTemperature ? "Weight" : "Temperature"}'),
            ),
          ],
        ),
      ),
    );
  }
}
