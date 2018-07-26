import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tttt/model/contents.dart';

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
    _onRefresh(false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: ContentsManager().size(),
        itemBuilder: (BuildContext context, int index) => Item(index));
  }

  void _onRefresh(bool up) {
    print('onRefresh $up');
    Future future =
        up ? ContentsManager().loadMore() : ContentsManager().refresh();
    future.then((success) {
      setState(() {});
      if (!success) {
        // Todo show Fail
      }
      print('_onRefresh finish');
    });
  }
}

class Item extends StatefulWidget {
  final index;

  Item(this.index);

  @override
  _ItemState createState() => new _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    if (ContentsManager().contentAt(widget.index) == null) {
      print('null content ${widget.index}');
      return Container();
    }

    return new RepaintBoundary(
      child: new Image.network(
        ContentsManager().contentAt(widget.index).imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void dispose() {
    print("dispose item");
    super.dispose();
  }
}
