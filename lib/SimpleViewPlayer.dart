library flutter_page_video;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';

class SimpleViewPlayer extends StatefulWidget {
  final String source;
  final bool isFullScreen;
  final Function listener;
  final Function(SimpleViewPlayer playerObj) playerObject;
  VideoPlayerController controller;
  _SimpleViewPlayerState _simpleViewPlayerState;

  SimpleViewPlayer(this.source, this.listener, {this.playerObject, this.isFullScreen: false}) {
     controller = VideoPlayerController.network(source);
  }

  @override
  _SimpleViewPlayerState createState() {
    _simpleViewPlayerState = _SimpleViewPlayerState();
    if (playerObject != null) {
      playerObject(this);
    }
    return _simpleViewPlayerState;
  }

  void setSource(String src) {
    _simpleViewPlayerState.setSource(src);
  }
}

class _SimpleViewPlayerState extends State<SimpleViewPlayer> {
  VideoPlayerController controller;
  VoidCallback listener;
  bool hideBottom = true;


  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }

      if (!controller.value.isPlaying) {
        if (controller.value.position.inMilliseconds ==
            controller.value.duration.inMilliseconds
        ) {
          if (widget.listener != null)
            widget.listener("complete", null);
        }
      }

      setState(() {});

    };
    controller = widget.controller;
    controller.initialize();
    controller.setLooping(false);
    controller.addListener(listener);
    controller.play();
    Screen.keepOn(true);
    if (widget.isFullScreen) {
      SystemChrome.setEnabledSystemUIOverlays([]);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void setSource(String src) {
    controller = VideoPlayerController.network(src);
    controller.initialize();
    controller.play();
  }

  @override
  void dispose() {
    controller.dispose();
    Screen.keepOn(false);
    if (widget.isFullScreen) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayView(
        controller,
        listener: widget.listener,
        allowFullScreen: !widget.isFullScreen,
      ),
    );
  }
}

class PlayView extends StatefulWidget {
  final VideoPlayerController controller;
  final bool allowFullScreen;
  final Function listener;

  PlayView(this.controller, {this.listener, this.allowFullScreen: true});

  @override
  _PlayViewState createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  VideoPlayerController get controller => widget.controller;
  bool hideBottom = true;

  void onClickPlay() {
    if (!controller.value.initialized) {
      return;
    }
    setState(() {
      hideBottom = false;
    });
    if (controller.value.isPlaying) {
      controller.pause();
      if (widget.listener != null) widget.listener("pause", null);
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) {
          return;
        }
        if (!controller.value.initialized) {
          return;
        }
        if (controller.value.isPlaying && !hideBottom) {
          setState(() {
            hideBottom = true;
          });
        }
      });
      controller.play();
      if (widget.listener != null) widget.listener("play", null);
    }
  }

  void onClickFullScreen() {
    List<dynamic> params = List();
    Map<String, bool> param = Map();
    param["value"] = true;
    params.add(param);
    if (widget.listener != null) widget.listener("fullscreen", params);

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // current portrait , enter fullscreen
      SystemChrome.setEnabledSystemUIOverlays([]);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      Navigator.of(context)
          .push(PageRouteBuilder(
        settings: RouteSettings(name:'isInitialRoute', arguments: false),
        pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            ) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              return Scaffold(
                resizeToAvoidBottomPadding: false,
                body: PlayView(controller),
              );
            },
          );
        },
      ))
          .then((value) {
        // exit fullscreen
        List<dynamic> params = List();
        Map<String, bool> param = Map();
        param["value"] = false;
        params.add(param);
        if (widget.listener != null) widget.listener("fullscreen", params);
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      });
    }
  }

  void onClickExitFullScreen() {
    List<dynamic> params = List();
    Map<String, bool> param = Map();
    param["value"] = false;
    params.add(param);
    if (widget.listener != null) widget.listener("fullscreen", params);

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      // current landscape , exit fullscreen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    if (controller.value.initialized) {
      final Size size = controller.value.size;
      return GestureDetector(
        child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                Center(
                    child: AspectRatio(
                      aspectRatio: size.width / size.height,
                      child: VideoPlayer(controller),
                    )),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: hideBottom
                        ? Container()
                        : Opacity(
                      opacity: 0.8,
                      child: Container(
                          height: 30.0,
                          color: Colors.black45,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  child: controller.value.isPlaying
                                      ? Icon(
                                    Icons.pause,
                                    color: Colors.white,
                                  )
                                      : Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: onClickPlay,
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Center(
                                    child: Text(
                                      "${controller.value.position.toString().split(".")[0]}",
                                      style:
                                      TextStyle(color: Colors.white),
                                    ),
                                  )),
                              Expanded(
                                  child: VideoProgressIndicator(
                                    controller,
                                    allowScrubbing: true,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 1.0, vertical: 1.0),
                                    colors: VideoProgressColors(
                                        playedColor: primaryColor),
                                  )),
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Center(
                                    child: Text(
                                      "${controller.value.duration.toString().split(".")[0]}",
                                      style:
                                      TextStyle(color: Colors.white),
                                    ),
                                  )),
                              Container(
                                child: widget.allowFullScreen
                                    ? Container(
                                  child: MediaQuery.of(context)
                                      .orientation ==
                                      Orientation.portrait
                                      ? GestureDetector(
                                    child: Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                    ),
                                    onTap: onClickFullScreen,
                                  )
                                      : GestureDetector(
                                    child: Icon(
                                      Icons.fullscreen_exit,
                                      color: Colors.white,
                                    ),
                                    onTap:
                                    onClickExitFullScreen,
                                  ),
                                )
                                    : Container(),
                              )
                            ],
                          )),
                    )),
                Align(
                  alignment: Alignment.center,
                  child: controller.value.isPlaying
                      ? Container()
                      : Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 48.0,
                  ),
                )
              ],
            )),
        onTap: onClickPlay,
      );
    } else if (controller.value.hasError && !controller.value.isPlaying) {
      return Container(
        color: Colors.black,
        child: Center(
          child: RaisedButton(
            onPressed: () {
              controller.initialize();
              controller.setLooping(false);
              controller.play();
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            child: Text("play error, try again!"),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}