import 'package:flutter/material.dart';

class StrokeButton extends StatelessWidget {
  final void Function() strokeButtonClicked;
  final double strokeWidth;
  final Color selectedColor;

  const StrokeButton({
    super.key,
    required this.strokeButtonClicked,
    required this.strokeWidth,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: strokeButtonClicked,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: strokeWidth * 2,
            height: strokeWidth * 2,
            decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(20.0)),
          ),
        ),
      ),
    );
  }
}
