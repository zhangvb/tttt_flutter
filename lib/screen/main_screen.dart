import 'dart:async';

import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ListView _listView;
  final List<String> _listData = List<String>();

  @override
  Widget build(BuildContext context) {
    var dataBuilder = StreamBuilder(
      stream: _getData(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        } else if (snapshot.hasError) {
          return Text('Error');
        }
        _listData.add(snapshot.data);// TODO WRONG! CREATE NEW EVERY TIME. CORRECT IT LATER
        return createListViewIfNeeded(context, snapshot);
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Home Page"),
      ),
      body: dataBuilder,
    );
  }

  Stream<String> _getData() {
    var maxCount = 1000;
    StreamController<String> controller = StreamController<String>();
    int counter = 0;

    void tick(Timer timer) {
      counter++;
      controller.add('$counter');
      if (maxCount != null && counter >= maxCount) {
        timer.cancel();
        controller.close();
      }
    }

    Timer.periodic(Duration(seconds: 1), tick);
    return controller.stream;
  }

  Widget createListViewIfNeeded(BuildContext context, AsyncSnapshot snapshot) {
   return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          print('index $index');
          if (index >= _listData.length) {
            return null;
          }
          return new Column(
            children: <Widget>[
              new ListTile(
                title: Text(_listData[index]),
              ),
              new Divider(
                height: 2.0,
              ),
            ],
          );
        });
  }
}
