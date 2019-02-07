import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext c) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Game();
  }
}

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  _Sequence sequence = _Sequence();
  AudioCache audio = AudioCache(prefix: 'sounds/')..load('ow.mp3');
  AnimationController _controller;
  List<double> _xs = [0, 0, 0, 0, 0];
  List<double> _vs = [0, 0, 0, 0, 0];
  List<bool> _hits = [false, false, false, false, false];

  @override
  void initState() {
    super.initState();

    num duration = sequence.t;
    List<_Event> events = sequence.events;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (duration).round()),
    );

    int i = 0;
    _controller.addListener(() {
      while (i < events.length && events[i].t / duration <= _controller.value) {
        _Event e = events[i];
        _xs[e.i] = 0;
        _vs[e.i] = 1;
        _hits[e.i] = false;
        i++;
      }

      setState(() {
        for (int i = 0; i < _xs.length; i++) {
          if (_xs[i] < 0)
            _vs[i] = 0;
          if (_xs[i] >= 1 || _hits[i])
            _vs[i] = -1;
          _xs[i] += _vs[i] / 30.0;
        }
      });
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext c) {
    GlobalKey _key = GlobalKey();

    return GestureDetector(
      child: CustomPaint(
        child: Container(key: _key),
        painter: _Painter(_xs, _hits),
      ),
      onTapDown: (TapDownDetails details) {
        Offset tap = details.globalPosition;
        RenderBox box = _key.currentContext.findRenderObject();
        double w = box.size.width / _xs.length;
        double r = w / 2;
        for (int i = 0; i < _xs.length; i++) {
          if (_xs[i] != null && !_hits[i]) {
            double h = 2 * w * _xs[i] - r;
            Offset c = Offset(w * (i + 0.5), h);
            bool inRect = w * i <= tap.dx && tap.dx <= w * (i + 1) && tap.dy < c.dy;
            bool inCircle = (pow(c.dx - tap.dx, 2) + pow(c.dy - tap.dy, 2)) < pow(r, 2);
            if (inRect || inCircle) {
              registerHit(i);
              break;
            }
          }
        }
      }
    );
  }

  void registerHit(int i) {
    setState(() {
      _hits[i] = true;
      audio.play('ow.mp3');
    });
  }
}

class _Painter extends CustomPainter {
  Paint _paint = Paint()..color = Colors.green;
  Paint _hitPaint = Paint()..color = Colors.pink;
  List<double> xs;
  List<bool> hits;

  _Painter(this.xs, this.hits);

  @override
  void paint(Canvas c, Size s) {
    double w = s.width / xs.length;
    double r = w / 2;
    for (int i = 0; i < xs.length; i++) {
      if (xs[i] > 0) {
        double h = 2 * w * xs[i] - r;
        Offset center = Offset(w * (i + 0.5), h);
        Paint p = hits[i] ? _hitPaint : _paint;
        c.drawRect(Rect.fromLTWH(w * i, 0, w, h), p);
        c.drawCircle(center, r, p);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter o) => true;
}

class _Sequence {
  List<_Event> events;
  num t = 0;

  _Sequence() {
    createEvents();
  }

  add(int i) => events.add(_Event(t, i));

  createEvents() {
    events = [];
    num d = 1200;

    t += d * 2;
    List<int> gators = [0, 1, 2, 3, 4]..shuffle();
    for (int i in gators) {
      add(i);
      t += d;
    }

    t += d * 2;
    for (int i = 0; i < 5; i++) {
      gators = [0, 1, 2, 3, 4]..shuffle();
      add(gators[0]);
      add(gators[1]);
      t += d;
    }

    t += d * 2;
    for (int i = 0; i < 4; i++) {
      gators = [0, 1, 2, 3, 4]..shuffle();
      add(gators[0]);
      add(gators[1]);
      add(gators[2]);
      t += d;
    }

    t += d * 2;
    List<int> last = [];
    gators = [0, 1, 2, 3, 4]..shuffle();
    for (int i = 0; i < 8; i++) {
      int first = gators.removeAt(0);
      add(first);
      last.add(first);
      t += d / 3;
      if (last.length == 4) {
        last.shuffle();
        gators += last;
        last = [];
      }
    }

    gators = [0, 1, 2, 3, 4]..shuffle();
    for (int i = 0; i < 12; i++) {
      int first = gators.removeAt(0);
      add(first);
      last.add(first);
      t += d / 4;
      if (last.length == 3) {
        last.shuffle();
        gators += last;
        last = [];
      }
    }
    last = [];

    t += d * 2;
    gators = [0, 1, 2, 3, 4]..shuffle();
    for (int i = 0; i < 30; i++) {
      int first = gators.removeAt(0);
      add(first);
      last.add(first);
      t += d / 6;
      if (last.length == 1) {
        last.shuffle();
        gators += last;
        last = [];
      }
    }

    t += d * 2;
  }
}

class _Event {
  num t;
  int i;
  _Event(this.t, this.i);
}