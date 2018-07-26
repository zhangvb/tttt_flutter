import 'dart:async';

import 'package:flutter/material.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:tttt/model/contents.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    var dataBuilder = FutureBuilder<bool>(
      future: ContentsManager().refresh(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        } else if (snapshot.hasError || !snapshot.data) {
          print('snapSHot.has ${snapshot.hasError}');
          print('snapshot.data ${snapshot.data}');

          return Text('Error Found.');
        } else if (!ContentsManager().hasContent()) {
          return Text('No Contents Now.');
        }
        return ContentList();
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("TianTianTieTu"),
      ),
      body: dataBuilder,
    );
  }
}

class ContentList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContentListState();
}

class ContentListState extends State<ContentList> {
  RefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) => Item(index));

    return new SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        controller: _controller,
        onRefresh: _onRefresh,
        headerBuilder: _headerCreate,
        footerBuilder: _footerCreate,
        footerConfig: RefreshConfig(),
        onOffsetChange: _onOffsetCallback,
        child: listView);
  }

  Widget _headerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(mode: mode);
  }

  Widget _footerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(
      mode: mode,
      refreshingText: 'loading...',
      idleIcon: const Icon(Icons.arrow_upward),
      idleText: 'Loadmore...',
    );
  }

  void _onRefresh(bool up) {
    Future future =
        up ? ContentsManager().loadMore() : ContentsManager().refresh();
    future.then((success) {
      setState(() {});
      _controller.sendBack(false, RefreshStatus.idle);
      if (!success) {
        // Todo show Fail
      }
    });
  }

  void _onOffsetCallback(bool isUp, double offset) {}
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
    if (ContentsManager().contentAt(widget.index) == null)
      return Container(width: 0.0, height: 0.0);

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
