import 'package:flutter/material.dart';

class MyMinutes extends StatelessWidget {
  final int mins;
  const MyMinutes({super.key, required this.mins});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          mins.toString(),
          style: const TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
