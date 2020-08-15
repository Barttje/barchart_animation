import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(BarChartAnimationDemo());
}

class BarChartAnimationDemo extends StatefulWidget {
  @override
  _BarChartAnimationDemoState createState() => _BarChartAnimationDemoState();
}

class _BarChartAnimationDemoState extends State<BarChartAnimationDemo>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Bar chart demo"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BarChart(
            animation: animation,
          ),
        ),
      ),
    );
  }
}

class BarChart extends AnimatedWidget {
  BarChart({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  final Map<String, int> data = {
    "Banana": 16,
    "Orange": 8,
    "Appple": 10,
    "Kiwi": 10,
    "Pear": 3
  };
  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Column(
      children: <Widget>[
        CustomPaint(
          painter: BarChartPainter(data, "Favorite Fruit", animation.value),
          child: Container(
            width: 350,
            height: 200,
          ),
        ),
        CustomPaint(
          painter: BarChartPainter(data, "Favorite Fruit", animation.value),
          child: Container(
            width: 350,
            height: 200,
          ),
        ),
        CustomPaint(
          painter: BarChartPainter(data, "Favorite Fruit", animation.value),
          child: Container(
            width: 350,
            height: 200,
          ),
        ),
      ],
    );
  }
}

class BarChartPainter extends CustomPainter {
  final String title;
  final Map<String, int> data;
  // Currently based on the length of the category names
  double marginTopX = 0;
  double marginTopY;
  //padding between the bars
  final double paddingY = 5;
  final double axisWidth = 2;
  final double barHeight = 15;
  final double percentage;
  BarChartPainter(this.data, this.title, this.percentage) {
    // determine where to begin with X, based on the width of the category names
    data.forEach((key, value) {
      var text = createText(key, 1);
      if ((text.width + 5) > marginTopX) {
        marginTopX = text.width + 5;
      }
    });
    marginTopY = createText(title, 1.5).height + paddingY;
  }
  @override
  void paint(Canvas canvas, Size size) {
    Paint axis = Paint()
      ..strokeWidth = axisWidth
      ..color = Colors.grey;

    double number = 0;
    double sum = 0;
    data.forEach((key, value) {
      drawBar(canvas, size, number, key, value, sum);
      number++;
      sum += value;
    });
    drawAxes(canvas, size, axis);
    drawTitle(canvas, size);
  }

  void drawTitle(Canvas canvas, Size size) {
    TextPainter tp = createText(title, 1.5);
    tp.paint(canvas, new Offset(size.width / 2 - tp.width / 2, 0));
  }

  void drawAxes(Canvas canvas, Size size, Paint axis) {
    canvas.drawLine(
      Offset(marginTopX,
          data.entries.length * (paddingY + barHeight) + marginTopY),
      Offset(size.width,
          data.entries.length * (paddingY + barHeight) + marginTopY),
      axis,
    );
    canvas.drawLine(
      Offset(marginTopX,
          data.entries.length * (paddingY + barHeight) + marginTopY),
      Offset(marginTopX, marginTopY - paddingY),
      axis,
    );
  }

  void drawBar(Canvas canvas, Size size, double number, String key, int value,
      double sum) {
    double y = number * (paddingY + barHeight) + marginTopY + barHeight / 2;
    drawText(key, canvas, y);
    Paint paint = Paint()
      ..strokeWidth = barHeight
      ..color = Colors.blue;

    double minValue = min(totalValue() * percentage / 100 - sum, value * 1.0);
    if (minValue > 0) {
      final width = (size.width - marginTopX) / (maxValue() / minValue);
      canvas.drawLine(
        Offset(marginTopX, y),
        Offset(width + marginTopX, y),
        paint,
      );
    }
  }

  void drawText(String key, Canvas canvas, double y) {
    TextPainter tp = createText(key, 1);
    tp.paint(canvas, new Offset(0, y - tp.height / 2));
  }

  TextPainter createText(String key, double scale) {
    TextSpan span =
        new TextSpan(style: new TextStyle(color: Colors.grey[600]), text: key);
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textScaleFactor: scale,
        textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) =>
      this.percentage != oldDelegate.percentage;

  int maxValue() => data.values.reduce(max);
  int totalValue() => data.values.fold(0, (p, c) => p + c);
}
