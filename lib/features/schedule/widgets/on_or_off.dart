import 'package:flutter/material.dart';

class OnOff extends StatelessWidget {
  final bool onOff;
  const OnOff({super.key, required this.onOff});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          onOff ? 'On' : 'Off',
          style: const TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
