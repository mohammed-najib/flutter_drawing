import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class SaveButton extends StatelessWidget {
  final RenderRepaintBoundary? boundary;

  const SaveButton({
    super.key,
    required this.boundary,
  });

  Future<void> save() async {
    if (boundary != null) {
      try {
        final image = await boundary!.toImage();
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        final fileName = '${DateTime.now().microsecondsSinceEpoch}.png';

        if (kIsWeb) {
          final base64 = base64Encode(pngBytes);
          final anchor = html.AnchorElement(
            href: 'data:image/png;base64,$base64',
          )..target = 'blank';
          anchor.download = fileName;
          html.document.body?.append(anchor);
          anchor.click();
          anchor.remove();
        } else {
          final directoryPath = (await getApplicationDocumentsDirectory()).path;
          final imagePath = await io.File('$directoryPath/$fileName').create();
          await imagePath.writeAsBytes(pngBytes);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: save,
        child: const CircleAvatar(
          child: Icon(
            Icons.save,
            size: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
