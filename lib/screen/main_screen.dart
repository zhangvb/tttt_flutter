import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tttt/model/contents.dart';
import 'package:tttt/widget/pull_to_refresh.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ContentList();
}

class ContentList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContentListState();
}

class ContentListState extends State<ContentList> {
  @override
  void initState() {
    super.initState();
    print('init');
    print(widget);
    _onRefresh(false);
  }

  @override
  Widget build(BuildContext context) {
    print('build contentlist');
    return PullToRefreshWidget(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: ContentsManager().size(),
          itemBuilder: (BuildContext context, int index) => Item(index)),
      onRefresh: () {
        return _onRefresh(false);
      },
      onLoadMore: () {
        return _onRefresh(true);
      },
    );
  }

  Future<Null> _onRefresh(bool up) {
    print('onRefresh $up');

    Future<bool> future = Future.delayed(Duration(seconds: 3), () {
      // TODO Delay TO SHOW REFRESH ANIMATION
      return up ? ContentsManager().loadMore() : ContentsManager().refresh();
    });

    return future.then((success) {
      setState(() {});
      if (!success) {
        // Todo show Fail
      }
      print('_onRefresh finish');
      return null;
    });
  }
}

class Item extends StatefulWidget {
  final index;

  Item(this.index);

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    if (ContentsManager().contentAt(widget.index) == null) {
      print('null content ${widget.index}');
      return Container(width: 0.0, height: 0.0);
    }

    return Image.network(
      ContentsManager().contentAt(widget.index).imageUrl,
      fit: BoxFit.cover,
      height: 400.0,
    );
  }

  @override
  void dispose() {
    print("dispose item");
    super.dispose();
  }
}
