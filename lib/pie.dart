import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'graph.dart';
import 'setup.dart';

class PiePage extends StatelessWidget {
  final Graph graph;
  // final List<PieEntry> data;
  // final String title;
  const PiePage(this.graph, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var wrapper = AnimationWrapper(graph.data);

    return Scaffold(
      appBar: AppBar(
        title: Text(graph.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetupPage(graph),
                    ));
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PieWidget(wrapper, graph.data),
            WinnerTitle(wrapper),
            GoButton(wrapper)
          ],
        ),
      ),
    );
  }
}

class AnimationWrapper {
  late AnimationController rotationController;
  late Animation rotationAnimation;

  String? winner;
  late AnimationController winnerController;
  late Animation winnerAnimation;

  late List<PieEntry> data;

  AnimationWrapper(List<PieEntry> d) {
    data = toArcs(d);
  }

  void launchRotation() {
    if (rotationController.isDismissed || rotationController.isCompleted) {
      var start = rotationAnimation.value % (2 * pi);
      var sweep = 8 * pi + Random().nextDouble() * 2 * pi;

      winnerController.reset();

      rotationAnimation = Tween<double>(begin: start, end: start + sweep)
          .animate(CurvedAnimation(
              parent: rotationController, curve: Curves.easeOutQuart));

      //That's for detecting when the pointer crosses a border of a segment
      //PieEntry? currentEntry;

      // rotationAnimation.addListener(() {
      //   var current = -(rotationAnimation.value + pi / 2) % (2 * pi);
      //   var s = 0.0;
      //   for (var e in data) {
      //     s += e.value ?? 0;
      //     if (current <= s) {
      //       if (e != currentEntry) {
      //         currentEntry = e;
      //       }
      //       break;
      //     }
      //   }
      //   if (current > s) {
      //     currentEntry = data.last;
      //   }
      // });

      rotationController.reset();
      rotationController.forward().then((value) {
        var end = -(rotationAnimation.value + pi / 2) % (2 * pi);
        print(end);
        var s = 0.0;
        for (var e in data) {
          s += e.value ?? 0;
          if (end <= s) {
            winner = e.title;
            winnerController.forward();
            break;
          }
        }
        if (end > s) {
          winner = data.last.title;
          winnerController.forward();
        }
        Future.delayed(const Duration(milliseconds: 400))
            .then((value) => HapticFeedback.mediumImpact());
      });
    }
  }
}

List<PieEntry> toArcs(List<PieEntry> d) {
  List<PieEntry> _data = [];

  var sum = d.fold(
      0,
      (previousValue, element) =>
          (element.value ?? 0) + (previousValue as num));
  for (var e in d) {
    _data.add(PieEntry(e.title, ((e.value ?? 0) / sum) * 2 * pi));
  }
  return _data;
}

class PieWidget extends StatefulWidget {
  final AnimationWrapper wrapper;
  final List<PieEntry> data;
  const PieWidget(this.wrapper, this.data, {Key? key}) : super(key: key);

  @override
  State<PieWidget> createState() => _PieWidgetState();
}

class _PieWidgetState extends State<PieWidget> with TickerProviderStateMixin {
  late AnimationController controller;
  double angle = 0;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));

    //fixes bug that makes hot restart not working
    widget.wrapper.rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutExpo));

    controller.addListener(() {
      setState(() {});
    });

    widget.wrapper.rotationController = controller;

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    var size = min(h / 1.5, w / 1.5);

    return Column(
      children: [
        SizedBox(
          width: size / 10,
          height: size / 10,
          child: Center(
            child: CustomPaint(
              painter: PointerPainter(size),
            ),
          ),
        ),
        SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Transform.rotate(
                angle: widget.wrapper.rotationAnimation.value,
                child: CustomPaint(painter: ChartPainter(size, widget.data))),
          ),
        ),
      ],
    );
  }
}

class WinnerTitle extends StatefulWidget {
  final AnimationWrapper wrapper;
  const WinnerTitle(this.wrapper, {Key? key}) : super(key: key);

  @override
  State<WinnerTitle> createState() => _WinnerTitleState();
}

class _WinnerTitleState extends State<WinnerTitle>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    //fixes bug that makes hot restart not working
    widget.wrapper.winnerAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    controller.addListener(() {
      setState(() {});
    });

    widget.wrapper.winnerController = controller;

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.wrapper.winnerAnimation.value,
      child: Text(
        '${widget.wrapper.winner}',
        style: const TextStyle(color: Colors.green, fontSize: 32),
      ),
    );
  }
}

class GoButton extends StatelessWidget {
  final AnimationWrapper wrapper;
  const GoButton(this.wrapper, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    var size = (w / 3);

    return ElevatedButton(
      style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size>(Size(size, 48))),
      onPressed: (() => wrapper.launchRotation()),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Icon(
          Icons.rocket_launch,
          color: Colors.red[900],
          size: 36,
        ),
      ),
    );
  }
}

class PointerPainter extends CustomPainter {
  final double d;

  PointerPainter(this.d);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    var path = Path()
      ..moveTo(0, d / 20)
      ..lineTo(d / 20, -d / 20)
      ..lineTo(-d / 20, -d / 20)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChartPainter extends CustomPainter {
  final double d;
  final List<PieEntry> data;
  final bool withText;

  ChartPainter(this.d, this.data, [this.withText = true]);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    List<PieEntry> arcs = toArcs(data);

    var p = 0.0;

    for (var i = 0; i < data.length; i++) {
      var angle = arcs[i].value;
      canvas.drawArc(Rect.fromCircle(center: const Offset(0, 0), radius: d / 2),
          p, angle ?? 0, true, paint..color = getColor(i));

      if (withText) {
        const textStyle = TextStyle(
            color: Colors.white,
            leadingDistribution: TextLeadingDistribution.even);
        final textSpan = TextSpan(text: data[i].title, style: textStyle);
        final textPainter = TextPainter(
            text: textSpan, textDirection: TextDirection.ltr, ellipsis: '...')
          ..layout(maxWidth: d / 2 * (4 / 5));

        canvas.save();
        canvas.rotate(p + (angle ?? 0) / 2);
        textPainter.paint(canvas, Offset(d / 10, -textPainter.height / 2));
        canvas.restore();
      }

      p += angle ?? 0;
    }

    canvas.drawShadow(
        Path()
          ..addOval(Rect.fromCircle(center: const Offset(0, 0), radius: d / 2)),
        Colors.black.withAlpha(128),
        8,
        true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color getColor(int n) => Colors.primaries[n % Colors.primaries.length];
}

class PieEntry {
  final String? title;
  final double? value;
  const PieEntry(this.title, this.value);
  PieEntry.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        value = json['value'];

  Map<String, dynamic> get toJson =>
      {'title': title ?? '', 'value': value ?? 0};
}
