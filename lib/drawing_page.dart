import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_drawing/drawn_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'sketcher.dart';

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

  Future<void> save() async {
    try {
      final boundary = _globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final fileName = '${DateTime.now().microsecondsSinceEpoch}.png';

      // final saved = await Image

      //
      if (kIsWeb) {
        //
        // FlutterFileSaver().writeFileAsBytes(
        //   fileName: fileName,
        //   bytes: pngBytes,
        // );
        //
        //
        final base64 = base64Encode(pngBytes);
        final anchor = html.AnchorElement(
          // href: 'data:application/octet-stream;base64,$base64',
          href: 'data:image/png;base64,$base64',
        )..target = 'blank';
        anchor.download = fileName;
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        // ..setAttribute('download', fileName)
        // ..click();
        // AnchorElement anchorElement = AnchorElement(href: )
        //
      } else {
        final directoryPath = (await getApplicationDocumentsDirectory()).path;
        final imagePath = await File('$directoryPath/$fileName').create();
        //
        // print('imagePath is: $imagePath');
        //
        await imagePath.writeAsBytes(pngBytes);
      }

      // Image.end
      //
    } catch (e) {
      print(e);
    }
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
    });
  }

  void onPanStart(DragStartDetails details) {
    // print('User started drawing');

    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    // print(point);

    // setState(() {
    //   line = DrawnLine([point], selectedColor, selectedWidth);
    // });

    line = DrawnLine([point], selectedColor, selectedWidth);
    currentLineStreamController.add(line);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    // if (line != null) {
    //   final List<Offset?> path = List.from(line!.path)..add(point);
    //   line = DrawnLine(path, selectedColor, selectedWidth);

    //   setState(() {
    //     if (lines.isEmpty) {
    //       lines.add(line!);
    //     } else {
    //       lines[lines.length - 1] = line;
    //     }
    //   });
    // }

    // print(point);

    // final linePath = line?.path;
    // if (linePath != null) {
    //   final List<Offset?> path = List.from(linePath)..add(point);
    //   setState(() {
    //     line = DrawnLine(path, selectedColor, selectedWidth);
    //   });
    // }

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

    // setState(() {
    //   lines.add(line);
    // });
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
          // child: CustomPaint(
          //   // painter: Sketcher(lines: [line]),
          //   painter: Sketcher(lines: lines),
          // ),
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

  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 100.0,
      right: 10.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(15.0),
        ],
      ),
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        selectedWidth = strokeWidth;
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(
              color: selectedColor, borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 40.0,
      right: 10.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildClearButton(),
          const Divider(height: 10.0),
          buildSaveButton(),
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

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: save,
      child: const CircleAvatar(
        child: Icon(
          Icons.save,
          size: 20.0,
          color: Colors.white,
        ),
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
          buildStrokeToolbar(),
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
