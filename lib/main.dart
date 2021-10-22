import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Radar Animation',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Widget> _unselected = [
    CircleButton(),
    CircleButton(),
    CircleButton(),
    CircleButton()
  ];
  final List<Widget> _selected = [];

  final _unselectedListKey = GlobalKey<AnimatedListState>();
  final _selectedListKey = GlobalKey<AnimatedListState>();
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    _animation = Tween(begin: .0, end: pi * 2).animate(_controller);
    _controller.repeat();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // custom code here
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF0F1532),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.90,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Positioned.fill(
                      left: 10,
                      right: 10,
                      child: Center(
                        child: Stack(children: [
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: RadarPainter(_animation.value),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            child: Center(
                              child: Container(
                                height: 70.0,
                                width: 70.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(30.0),
                                      topLeft: Radius.circular(30.0),
                                      topRight: Radius.circular(10.0)),
                                  //add border radius here
                                  child: Container(
                                    color: Color(0xFF6263C0),
                                  ), //add image location here
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 56,
                            child: AnimatedList(
                              physics: NeverScrollableScrollPhysics(),
                              key: _unselectedListKey,
                              initialItemCount: _unselected.length,
                              itemBuilder: (context, index, animation) {
                                return InkWell(
                                  onTap: () => _moveItem(
                                    fromIndex: index,
                                    fromList: _unselected,
                                    fromKey: _unselectedListKey,
                                    toList: _selected,
                                    toKey: _selectedListKey,
                                  ),
                                  child: _unselected[index],
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 150),
                            child: StaggeredGridView.count(
                              // key: _unselectedListKey,
                              crossAxisCount: 4,
                              children: List.generate(
                                  4,
                                  (index) => GestureDetector(
                                      onTap: () => _moveItem(
                                            fromIndex: index,
                                            fromList: _unselected,
                                            fromKey: _unselectedListKey,
                                            toList: _selected,
                                            toKey: _selectedListKey,
                                          ),
                                      child:
                                          Center(child: _unselected[index]))),
                              staggeredTiles: [
                                StaggeredTile.count(2,
                                    2), // takes up 2 rows and 2 columns space
                                StaggeredTile.count(
                                    2, 1), // takes up 2 rows and 1 column
                                StaggeredTile.count(2, 2),
                                StaggeredTile.count(
                                    2, 1), // takes up 1 row and 2 column space
                              ], // scatter them randomly
                            ),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF2F4155),
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SizedBox(
                    width: 56,
                    child: AnimatedList(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      key: _selectedListKey,
                      initialItemCount: _selected.length,
                      itemBuilder: (context, index, animation) {
                        return InkWell(
                          onTap: () => _moveItem(
                            fromIndex: index,
                            fromList: _selected,
                            fromKey: _selectedListKey,
                            toList: _unselected,
                            toKey: _unselectedListKey,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                _selected[index],
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'test',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  int _flyingCount = 0;

  _moveItem({
    required int fromIndex,
    required List fromList,
    required GlobalKey<AnimatedListState> fromKey,
    required List toList,
    required GlobalKey<AnimatedListState> toKey,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final globalKey = GlobalKey();

    final item = fromList.removeAt(fromIndex);
    fromKey.currentState!.removeItem(
      fromIndex,
      (context, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Opacity(
            key: globalKey,
            opacity: 0.0,
            child: CircleButton(),
          ),
        );
      },
      duration: duration,
    );
    _flyingCount++;

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      // Find the starting position of the moving item, which is exactly the
      // gap its leaving behind, in the original list.
      final box1 = globalKey.currentContext!.findRenderObject() as RenderBox;
      final pos1 = box1.localToGlobal(Offset.zero);
      // Find the destination position of the moving item, which is at the
      // end of the destination list.
      final box2 = toKey.currentContext!.findRenderObject() as RenderBox;
      final box2height = box1.size.height * (toList.length + _flyingCount - 1);
      final pos2 = box2.localToGlobal(Offset(0, box2height));
      // Insert an overlay to "fly over" the item between two lists.
      final entry = OverlayEntry(builder: (BuildContext context) {
        return TweenAnimationBuilder(
          tween: Tween<Offset>(begin: pos1, end: pos2),
          duration: duration,
          builder: (_, Offset value, child) {
            return Positioned(
              left: value.dx,
              top: value.dy,
              child: CircleButton(),
            );
          },
        );
      });

      Overlay.of(context)!.insert(entry);
      await Future.delayed(duration);
      entry.remove();
      toList.add(item);
      toKey.currentState!.insertItem(toList.length - 1);
      _flyingCount--;
    });
  }
}

class RadarPainter extends CustomPainter {
  final double angle;

  Paint _bgPaint = Paint()
    ..color = Color(0xFF9A6D2C)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  Paint _paint = Paint()..style = PaintingStyle.fill;

  int circleCount = 3;

  RadarPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    var radius = min(size.width / 2, size.height / 4);
    for (var i = 1; i <= circleCount; ++i) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2),
          radius * i / circleCount, _bgPaint);
    }

    _paint.shader = ui.Gradient.sweep(
        Offset(size.width / 2, size.height / 2),
        [Color(0xFF9A6D2C).withOpacity(.01), Color(0xFF9A6D2C).withOpacity(.5)],
        [.0, 1.0],
        TileMode.clamp,
        .0,
        pi / 12);

    canvas.save();
    double r = sqrt(pow(size.width, 2) + pow(size.height, 2));
    double startAngle = atan(size.height / size.width);
    Point p0 = Point(r * cos(startAngle), r * sin(startAngle));
    Point px = Point(r * cos(angle + startAngle), r * sin(angle + startAngle));
    canvas.translate((p0.x - px.x) / 2, (p0.y - px.y) / 2);
    canvas.rotate(angle);

    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2), radius: radius),
        0,
        pi / 0.9,
        true,
        _paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CircleButton extends StatelessWidget {
  const CircleButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: 40.0,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(40.0),
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(20.0)),
        //add border radius here
        child: Container(
          color: Color(0xFF6263C0),
        ), //add image location here
      ),
    );
  }
}
