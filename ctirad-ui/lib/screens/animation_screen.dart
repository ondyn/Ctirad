import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SampleAnimation extends StatefulWidget {
  final String line1;
  final String line2;
  const SampleAnimation({Key? key, required this.line1, required this.line2})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SampleAnimationState();
  }
}

class SampleAnimationState extends State<SampleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  late Path _path;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    super.initState();
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    // _controller.forward();
    _controller.repeat();
    _path = drawPath();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
            top: calculate(_animation.value).dy,
            left: calculate(_animation.value).dx,
            width: 800.0,
            height: 500.0,
            child: Column(
              children: [
                Expanded(
                  child: Text(
                    widget.line1,
                    style: GoogleFonts.supermercadoOne(
                        textStyle: Theme.of(context).textTheme.bodyLarge,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  widget.line2,
                  style: GoogleFonts.supermercadoOne(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Path drawPath() {
    Size size = Size(30, 30);
    Path path = Path();
    // path.moveTo(0, size.height / 2);
    // path.quadraticBezierTo(
    //     size.width / 2, size.height, size.width, size.height / 2);
    path.addOval(Rect.fromCircle(
      center: Offset(20, 20),
      radius: 10.0,
    ));
    return path;
  }

  Offset calculate(value) {
    final PathMetrics pathMetrics = _path.computeMetrics();
    final PathMetric pathMetric = pathMetrics.elementAt(0);
    value = pathMetric.length * value;
    Tangent pos = pathMetric.getTangentForOffset(value) as Tangent;
    return pos.position;
  }
}

class PathPainter extends CustomPainter {
  Path path;

  PathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(this.path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


// https://stackoverflow.com/questions/62134361/flutter-path-scaling
