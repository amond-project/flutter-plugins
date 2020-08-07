import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:bob_multi_player/bob_multi_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
    ),
  );
  runApp(WCDPlayerDemoApp());
}

/// Creates [WCDPlayerDemoApp] widget.
class WCDPlayerDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bob WCD Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.blueAccent,
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 20.0,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.blueAccent,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

/// Homepage
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  BobMultiPlayer playerObj;
  double _yPosition = 0;
  double _width;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    Future.delayed(Duration.zero, () {
      _width = MediaQuery.of(context).size.width;
    });
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget bobPlayer() {
    return BobMultiPlayer(
      playerObject: (obj) {
        playerObj = obj;
      },
      playerState: (value, param) {
        print("----" + value + "," + param.toString());
      },
    );
  }

  Widget body() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: _width,
          height: 900,
          child: Column(
            children: <Widget>[
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? SizedBox(
                      height: MediaQuery.of(context).viewPadding.top,
                    )
                  : SizedBox.shrink(),
              AspectRatio(
                  aspectRatio: MediaQuery.of(context).orientation == Orientation.portrait
                      ? 16 / 9
                      : MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top),
                  child: bobPlayer()),
              MediaQuery.of(context).orientation == Orientation.portrait ? buttons() : SizedBox.shrink(),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 150,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  Widget buttons() {
    return Column(
      children: <Widget>[
        FlatButton(
          child: Text("We Can Deo Play"),
          onPressed: () {
            playerObj.setSouce(
                "http://play.wecandeo.com/video/v/?key=BOKNS9AQWrFXVTfipXQ6c1hsN1ZaB9TxKej10EZ2nAvJisRYkiixl6fbrKGKgfKFPwplFGipd7WMv3b27rE983vAVwieie");
            //playerObj.setSouce("iLnmTe5Q2Qw");
          },
        ),
        FlatButton(
          child: Text("YouTube Play"),
          onPressed: () {
            playerObj.setSouce("bSsXw2Fg5dw");
            //playerObj.play();
          },
        ),
        FlatButton(
          child: Text("We Can Deo 2"),
          onPressed: () {
            //playerObj.stop();
            playerObj.setSouce(
                "http://play.wecandeo.com/video/v/?key=BOKNS9AQWrHtFFoZ3udAS4k647dHAtlqG4eh4nY4J3bKZbvfbASNbLKGKgfKFPwplFGipd7WMv3b27rE983vAVwieie");
          },
        ),
        FlatButton(
          child: Text("Youtube Play 2"),
          onPressed: () {
            playerObj.setSouce("6N9tRwLa3Rs");
          },
        ),
        FlatButton(
          child: Text("Pause"),
          onPressed: () {
            playerObj.pause();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
//      appBar: AppBar(
//        leading: Padding(
//          padding: const EdgeInsets.only(left: 12.0),
//          child: Image.asset(
//            'assets/ypf.png',
//            fit: BoxFit.fitWidth,
//          ),
//        ),
//        title: const Text(
//          'Bob WECANDO Player Flutter',
//          style: TextStyle(color: Colors.white),
//        ),
//        actions: [
//          IconButton(
//            icon: const Icon(Icons.video_library),
//            onPressed: () {
//              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//            },
//          ),
//        ],
//      ),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            top: _yPosition,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onPanStart: (dragStartDetail) {

              },
              onPanUpdate: (dragUpdateDetail) {
                setState(() {
                  _yPosition += dragUpdateDetail.delta.dy;
                  double yper = _yPosition / MediaQuery.of(context).size.height;
                  _width = MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width - 150) * yper;
                });
              },
              onPanEnd: (dragEndDetail) {
                print(dragEndDetail.velocity);
                if (MediaQuery.of(context).size.height / 3 < _yPosition) {
                  setState(() {
                    _width = 150;
                    _yPosition = MediaQuery.of(context).size.height - 150;
                  });
                } else {
                  setState(() {
                    _width = MediaQuery.of(context).size.width;
                    _yPosition = 0;
                  });
                }
              },
              child: body(),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
