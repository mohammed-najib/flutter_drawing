import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'drawn_line.dart';
import 'sketcher.dart';
import 'widgets/clear_button.widget.dart';
import 'widgets/save_button.widget.dart';
import 'widgets/stroke_button.widget.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();
  List<DrawnLine?> lines = <DrawnLine>[];
  DrawnLine? line;
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

  final StreamController<List<DrawnLine?>> linesStreamController =
      StreamController<List<DrawnLine?>>.broadcast();
  final StreamController<DrawnLine?> currentLineStreamController =
      StreamController<DrawnLine?>.broadcast();

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
    });
  }

  void onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    line = DrawnLine([point], selectedColor, selectedWidth);
    currentLineStreamController.add(line);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    final linePath = line?.path;
    if (linePath != null) {
      final List<Offset?> path = List.from(linePath)..add(point);
      line = DrawnLine(path, selectedColor, selectedWidth);
      currentLineStreamController.add(line);
    }
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line);
    linesStreamController.add(lines);
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<DrawnLine?>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) => CustomPaint(
              painter: Sketcher(
                lines: [line],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder<List<DrawnLine?>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) => CustomPaint(
            painter: Sketcher(
              lines: lines,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top,
      right: 10.0,
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewPadding.vertical,
        width: 58.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: 58.0,
                child: ListView(
                  children: [
                    ClearButton(clear: clear),
                    const Divider(height: 10.0),
                    SaveButton(
                        boundary: _globalKey.currentContext?.findRenderObject()
                            as RenderRepaintBoundary?),
                    const Divider(height: 10.0),
                    buildColorButton(Colors.red),
                    buildColorButton(Colors.blueAccent),
                    buildColorButton(Colors.deepOrange),
                    buildColorButton(Colors.green),
                    buildColorButton(Colors.lightBlue),
                    buildColorButton(Colors.black),
                    buildColorButton(Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StrokeButton(
                  strokeButtonClicked: () {
                    selectedWidth = 5.0;
                  },
                  strokeWidth: 5.0,
                  selectedColor: selectedColor,
                ),
                StrokeButton(
                  strokeButtonClicked: () {
                    selectedWidth = 10.0;
                  },
                  strokeWidth: 10.0,
                  selectedColor: selectedColor,
                ),
                StrokeButton(
                  strokeButtonClicked: () {
                    selectedWidth = 15.0;
                  },
                  strokeWidth: 15.0,
                  selectedColor: selectedColor,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color,
        child: Container(),
        onPressed: () {
          setState(() {
            selectedColor = color;
          });
        },
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: const CircleAvatar(
        child: Icon(
          Icons.create,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Stack(
        children: [
          buildAllPaths(context),
          buildCurrentPath(context),
          buildColorToolbar(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }
}
