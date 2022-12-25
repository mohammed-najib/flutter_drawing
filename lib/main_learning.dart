import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWidget(),
    ),
  );
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow[50],
      child: CustomPaint(
        painter: MyCustomPainter(),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  // Method to draw on the canvas
  @override
  void paint(Canvas canvas, Size size) {
    // Offset startPoint = const Offset(0, 0);
    // Offset endPoint = Offset(size.width, size.height);

    // Paint paint = Paint();

    // canvas.drawLine(startPoint, endPoint, paint);

    Paint paintMountains = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.brown;
    Paint paintSun = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.deepOrangeAccent;

    Path path = Path();
    path.moveTo(0, 250);
    path.lineTo(100, 200);
    path.lineTo(150, 150);
    path.lineTo(200, 50);
    path.lineTo(250, 150);
    path.lineTo(300, 200);
    path.lineTo(size.width, 250);
    path.lineTo(0, 250);
    canvas.drawPath(path, paintMountains);

    path = Path();
    path.moveTo(100, 100);
    path.addOval(
      Rect.fromCircle(
        center: const Offset(100, 100),
        radius: 25,
      ),
    );
    canvas.drawPath(path, paintSun);

    // Paint paintMountains = Paint()
    //   ..style = PaintingStyle.fill
    //   ..color = Colors.brown;

    // Paint paintSun = Paint()
    //   ..style = PaintingStyle.fill
    //   ..color = Colors.deepOrangeAccent;

    // Path path = Path();
    // // Drawing mountains
    // path.moveTo(0, 250);
    // path.lineTo(100, 200);
    // path.lineTo(150, 150);
    // path.lineTo(200, 50);
    // path.lineTo(250, 150);
    // path.lineTo(300, 200);
    // path.lineTo(size.width, 250);
    // path.lineTo(0, 250);
    // canvas.drawPath(path, paintMountains);

    // // Drawing the sun
    // path = Path();
    // path.moveTo(100, 100);
    // path.addOval(Rect.fromCircle(center: const Offset(100, 100), radius: 25));
    // canvas.drawPath(path, paintSun);
  }

  // Method to decide if repainting is necessary on rebuild
  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return true;
  }
}
