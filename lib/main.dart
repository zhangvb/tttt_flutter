import 'package:flutter/material.dart';
import 'package:tttt/screen/main_screen.dart';

void main() => runApp(TTTTApp());

class TTTTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TianTianTieTu',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('TianTianTieTu'),
          ),
          body: ContentList(),
          bottomNavigationBar: BottomAppBar(child: Text('Bottom'),),
        ));
  }
}
