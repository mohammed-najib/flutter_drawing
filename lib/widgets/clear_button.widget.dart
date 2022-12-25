import 'package:flutter/material.dart';

class ClearButton extends StatelessWidget {
  final void Function() clear;

  const ClearButton({
    super.key,
    required this.clear,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: clear,
        child: const CircleAvatar(
          child: Icon(
            Icons.create,
            size: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
