import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Future<Null> RefreshCallback();

class PullToRefreshWidget extends StatefulWidget {
  const PullToRefreshWidget(
      {@required this.child,
      @required this.onRefresh,
      @required this.onLoadMore})
      : assert(child != null),
        assert(onRefresh != null),
        assert(onLoadMore != null);

  final Widget child;
  final RefreshCallback onRefresh;
  final RefreshCallback onLoadMore;

  @override
  _PullToRefreshState createState() {
    print('create $child');
    print('create $onRefresh');
    return _PullToRefreshState();
  }
}

const kDragOffset = 40.0;

class _PullToRefreshState extends State<PullToRefreshWidget> {
  static const load_state_idle = 0;
  static const load_state_more = 1;
  static const load_state_refresh = 2;

  int _loadState = load_state_idle;
  double _dragOffset;

  @override
  Widget build(BuildContext context) {
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.child,
    );

    return Column(children: [
      _loadState == load_state_refresh
          ? TumblrStyleRefreshWidget()
          : Container(
              width: 0.0,
              height: 0.0,
            ),
      Expanded(child: child),
      _loadState == load_state_more
          ? TumblrStyleRefreshWidget()
          : Container(
              width: 0.0,
              height: 0.0,
            ),
    ]);
  }

  void handleResult(Future result) {
    if (result == null) return;
    result.whenComplete(() {
      if (mounted) {
        changeLoadState(load_state_idle);
      }
    });
  }

  void changeLoadState(int newLoadState) {
    setState(() {
      _loadState = newLoadState;
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _dragOffset = 0.0;
    }

    if (notification is ScrollUpdateNotification && _dragOffset != null) {
      _dragOffset -= notification.scrollDelta;

      if (notification.metrics.extentBefore == 0.0 &&
          _dragOffset > kDragOffset) {
        // REFRESH
        if (_loadState == load_state_idle) {
          changeLoadState(load_state_refresh);
          handleResult(widget.onRefresh());
        }
      } else if (notification.metrics.extentAfter == 0.0 &&
          _dragOffset < -kDragOffset) {
        // LOAD MORE
        if (_loadState == load_state_idle) {
          changeLoadState(load_state_more);
          handleResult(widget.onLoadMore());
        }
      }
    }

    if (notification is ScrollEndNotification) {
      _dragOffset = null;
    }
    return false;
  }
}

class TumblrStyleRefreshWidget extends StatefulWidget {
  TumblrStyleRefreshWidget();

  @override
  State<TumblrStyleRefreshWidget> createState() =>
      _TumblrStyleRefreshWidgetState();
}

class _TumblrStyleRefreshWidgetState extends State<TumblrStyleRefreshWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  _TSDrawParams _tsDrawParams = _TSDrawParams()..reset();

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      })
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget child) {
            return CustomPaint(
              painter: _TumblrStylePainter(_tsDrawParams),
            );
          }),
      constraints: BoxConstraints.expand(height: 20.0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _TSDrawParams {
  List progresses;
  int drawIndex;

  _TSDrawParams();

  reset() {
    progresses = [100, 60, 20, -20];
    drawIndex = 0;
  }

  @override
  String toString() {
    return '_TSDrawParams{progresses: $progresses, drawIndex: $drawIndex}';
  }
}

class _TumblrStylePainter extends CustomPainter {
  static const colors = [
    Color(0XFFD35B3E),
    Color(0XFF509B6C),
    Color(0XFF53B786),
    Color(0XFFDC8D2F)
  ];

  _TSDrawParams _drawParams;
  Paint _paint = Paint();

  _TumblrStylePainter(this._drawParams);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      _drawParams.progresses[i] += 2;
      if (_drawParams.progresses[i] == 160) {
        _drawParams.progresses[i] = 0;
        if (_drawParams.drawIndex == 3) {
          _drawParams.drawIndex = 0;
        } else {
          _drawParams.drawIndex++;
        }
      }
    }

    print('paint');
    print(_drawParams);
    print(_drawParams.hashCode);

    var limit = 4;

    int i = _drawParams.drawIndex;
    while (i < limit) {
      if (_drawParams.progresses[i] > 0) {
        var baseWidth = 0;
        var center = size.width / 2;
        var width = (size.width - baseWidth) * _drawParams.progresses[i] / 100 +
            baseWidth;
        canvas.drawRect(
            Rect.fromLTRB(center - width / 2, 0.0, width, 20.0),
            _paint
              ..color = colors[i]
              ..style = PaintingStyle.fill);
      }

      if (_drawParams.drawIndex != 0 && i == 3) {
        limit = _drawParams.drawIndex;
        i = 0;
      } else {
        i++;
      }
    }
    print('paint end');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
