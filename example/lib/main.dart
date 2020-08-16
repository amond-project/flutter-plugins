import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  BobMultiPlayer playerObj;
  double _yPosition = 0;
  double _width = 0;

  AnimationController _controller;
  Tween<double> _tween;
  Animation<double> _moveAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_width !=  MediaQuery.of(context).size.width) {
        setState(() {
          _width = MediaQuery
              .of(context)
              .size
              .width;
        });
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _tween = Tween(
      begin: _yPosition,
      end: 0.0,
    );

    Animation curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _moveAnim = _tween.animate(curve)
      ..addListener(() {
        setState(() {
          _yPosition = _moveAnim.value;
          double yper = _yPosition / MediaQuery.of(context).size.height;
          _width = MediaQuery.of(context).size.width -
              (MediaQuery.of(context).size.width - 150) * yper;
        });
      })
      ..addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          setState(() {
            print('completed');
          });
        }
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
      initScreen: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width / _getHeightRatio(),
        color: Colors.black,
        child: Center(
          child: Text(
            "플레이어 대기 중...\n이곳에는 이미지가 올 수도 있고~ 원하는것 다 올려보셈!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget scaledPlayer() {
    return Stack(
      overflow: Overflow.clip,
      children: <Widget>[
        Container( //이곳이 작아졌을 때 들어갈 컨텐츠 넣을 곳.
          width: MediaQuery.of(context).size.width,
          height: _getScaledHeight(),
          color: Colors.amber,
        ),
        Transform.scale(
          alignment: Alignment.topLeft,
          scale: _getScale(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: bobPlayer(),
            ),
          ),
        ),
      ],
    );
  }

  double _getScale() {
    return 1 - (_yPosition / (MediaQuery.of(context).size.height + 300));
  }

  double _getScaledHeight() {
    return MediaQuery.of(context).size.width / _getHeightRatio() * _getScale();
  }

  double _getHeightRatio() {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? 16 / 9
        : MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewPadding.top);
  }

  Widget body() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            MediaQuery.of(context).orientation == Orientation.portrait &&
                    _width == MediaQuery.of(context).size.width
                ? SizedBox(
                    height: MediaQuery.of(context).viewPadding.top,
                  )
                : SizedBox.shrink(),
            scaledPlayer(),
            MediaQuery.of(context).orientation == Orientation.portrait &&
                    _width == MediaQuery.of(context).size.width
                ? buttons()
                : SizedBox.shrink(),
          ],
        ),
        Expanded(
          child: Container(
            height: _width / _getHeightRatio(),
            color: Colors.grey,
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

  void _toTop() {
    _tween.begin = _yPosition;
    _tween.end = 0;
    _controller.reset();
    _controller.forward();
  }

  void _toBottom() {
    _tween.begin = _yPosition;
    _tween.end = MediaQuery.of(context).size.height - 86;
    _controller.reset();
    _controller.forward();
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
              onPanStart: (dragStartDetail) {},
              onPanUpdate: (dragUpdateDetail) {
                if (MediaQuery.of(context).orientation ==
                    Orientation.portrait) {
                  setState(() {
                    _yPosition += dragUpdateDetail.delta.dy;
                    if (_yPosition > 0) {
                      double yper =
                          _yPosition / MediaQuery.of(context).size.height;
                      _width = MediaQuery.of(context).size.width -
                          (MediaQuery.of(context).size.width - 150) * yper;
                    } else {
                      _yPosition = 0;
                    }
                  });
                }
              },
              onPanEnd: (dragEndDetail) {
                if (MediaQuery.of(context).orientation ==
                    Orientation.portrait) {
                  if (dragEndDetail.velocity.pixelsPerSecond.dy < -1000) {
                    _toTop();
                  } else if (dragEndDetail.velocity.pixelsPerSecond.dy > 1000) {
                    _toBottom();
                  } else {
                    if (MediaQuery.of(context).size.height / 2.5 < _yPosition) {
                      _toBottom();
                    } else {
                      _toTop();
                    }
                  }
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
