import 'package:flutter/material.dart';

class BB extends Container {
  BB(String s)
      : super(
          decoration: BoxDecoration(
            border: Border.all(width: 2),
          ),
          width: 100,
          height: 50,
          child: Text(s, style: const TextStyle(fontSize: 20)),
        );
}
