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
  ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController()..addListener(_scrollListener);
    super.initState();
    _onRefresh(false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: ContentsManager().size(),
        controller: _controller,
        itemBuilder: (BuildContext context, int index) => Item(index));
  }

  void _onRefresh(bool up) {
    print('onRefresh $up');
    if (ContentsManager().isLoading()) {
      print('onRefresh loading now!!!');
      return;
    }
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

  void _scrollListener() {
    print('extendAfter ${_controller.position.extentAfter}');
    if (_controller.position.extentAfter < 500) {
      _onRefresh(true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    super.dispose();
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
      return Container();
    }

    return RepaintBoundary(
      child: Image.network(
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
