import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'BobWCDPlayer.dart';
import 'SimpleViewPlayer.dart';
import 'player_type.dart';

class BobMultiPlayer extends StatefulWidget {
  final _BobMultiPlayerState _bobMultiPlayerState = _BobMultiPlayerState();

  final Function(BobMultiPlayer playerObj) playerObject;
  final Function(String playerState, List<dynamic> param) playerState;
  final Widget initScreen;
  BobMultiPlayer({this.playerObject, this.playerState, this.initScreen});

  @override
  _BobMultiPlayerState createState() {
    if (playerObject != null) {
      playerObject(this);
    }
    return _bobMultiPlayerState;
  }

  void play() {
    _bobMultiPlayerState.play();
  }

  void pause() {
    _bobMultiPlayerState.pause();
  }

  void stop() {
    _bobMultiPlayerState.stop();
  }

  void setSouce(String src) {
    _bobMultiPlayerState.setSource(src);
  }

  void toggleYtFullScreenMode() {
    _bobMultiPlayerState.toggleYtFullScreenMode();
  }

  Future<String> getState() async {
    return await _bobMultiPlayerState.getState();
  }
}


class _BobMultiPlayerState extends State<BobMultiPlayer> {
  bool _isPlayerReady = false;
  BobWCDPlayer _wcdPlayerObj;

  PlayerState _playerState;
  YoutubeMetaData _videoMetaData;
  YoutubePlayerController _ytController;
  SimpleViewPlayer simpleViewPlayer;

  Widget _player;

  PlayerType _playerType = PlayerType.none;
  bool _fullScreen = false;

  void listener() {
//    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
//        _playerState = _controller.value.playerState;
//        _videoMetaData = _controller.metadata;
//    }

    if (widget.playerState != null && mounted) {
      if (_playerState != _ytController.value.playerState)
        switch (_ytController.value.playerState) {
          case PlayerState.cued :
            widget.playerState("ready", null);
            break;
          case PlayerState.unStarted :
            widget.playerState("ready", null);
            break;
          case PlayerState.buffering :
            widget.playerState("buffering", null);
            break;
          case PlayerState.ended :
            widget.playerState("complete", null);
            break;
          case PlayerState.paused :
            widget.playerState("pause", null);
            break;
          case PlayerState.playing :
            widget.playerState("play", null);
            break;
          case PlayerState.unknown :
            widget.playerState("unknown", null);
            break;
        }

      if (_ytController.value.isFullScreen) {
        if (!_fullScreen) {
          _fullScreen = true; //한번만 이벤트 발생을 시키기 위해..
          List<dynamic> params = List();
          Map<String, bool> param = Map();
          param["value"] = true;
          params.add(param);
          widget.playerState("fullscreen", params);
        }
      } else {
        if (_fullScreen) {
          _fullScreen = false;
          List<dynamic> params = List();
          Map<String, bool> param = Map();
          param["value"] = false;
          params.add(param);
          widget.playerState("fullscreen", params);
        }
      }
    }
    _playerState = _ytController.value.playerState;
  }

  Widget createVideoPlayer(String src){
    return SimpleViewPlayer(src, (value, param) {

      widget.playerState(value, param);


      //print(value);

    }, playerObject: (SimpleViewPlayer simpleViewPlayer) {
       this.simpleViewPlayer = simpleViewPlayer;
    },);
  }

  YoutubePlayer createYoutubePlayer(String vid) {
    _ytController = YoutubePlayerController(
      initialVideoId: vid,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);

    return YoutubePlayer(
      controller: _ytController,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blueAccent,
      onReady: () {
        _isPlayerReady = true;
      },
      onEnded: (data) {
        _playerType = PlayerType.none;
        setState(() {
           SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          _player = widget.initScreen==null ? Container(color: Colors.black,) : widget.initScreen;
        });
      },
    );
  }



  @override
  void initState() {
    super.initState();
    _player = widget.initScreen==null ? Container(color: Colors.black,) : widget.initScreen;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: Duration(seconds: 1),
        child: _player);
  }

  void setSource(String src) {
    //if (_controller.value.isPlaying) _controller.pause();

    if (src.startsWith('http')) {
      if (_playerType == PlayerType.weCanDeo) {
          _wcdPlayerObj?.setSource(src);
      } else {
        if (src.contains("wecandeo")) {
          _playerType = PlayerType.weCanDeo;
          setState(() {
            _player = BobWCDPlayer(
              initVid: src,
              playerObject: (obj) {
                _wcdPlayerObj = obj;
              },
              playerState: (value, param) {
                if (widget.playerState != null && mounted) {
                  widget.playerState(value, param);
                }
                if (value == "complete") {
                  _playerType = PlayerType.none;
                  setState(() {
                    _player = widget.initScreen == null ? Container(color: Colors.black,) : widget.initScreen;
                  });
                } else if (value == "fullscreen") {
                  if ((param[0]["value"])) { //풀 스크린의 경우

                  } else { //복원 되는 경우

                  }
                }
              },);
          });
        } else { //일반 플레이어로 생성.
          if (_playerType == PlayerType.general) {
            simpleViewPlayer.setSource(src);
          } else {
            _playerType = PlayerType.general;
            setState(() {
              _player = createVideoPlayer(src);
            });
          }
        }
      }
    }
    else {
      if (_playerType == PlayerType.youTube) {
        _ytController.load(src);
      } else {
        _playerType = PlayerType.youTube;
        setState(() {
          _player = createYoutubePlayer(src);
        });
      }
    }
  }

  void play() {
    _playerType == PlayerType.youTube?_ytController?.play(): _wcdPlayerObj?.play();
  }

  void stop() {
    _playerType == PlayerType.youTube?_ytController?.pause(): _wcdPlayerObj?.stop();
  }

  void pause() {
    _playerType == PlayerType.youTube?_ytController?.pause():_wcdPlayerObj?.pause();
  }

  void toggleYtFullScreenMode(){
    if (_playerType == PlayerType.youTube) {
      _ytController.toggleFullScreenMode();
    }
  }
  
  //          Returns String
  //          – VALUE : idle , playing , pause , buffering
  Future<String> getState() async {
    if (mounted) {
      if (_playerType == PlayerType.weCanDeo)
        return await _wcdPlayerObj.getState();
      else {
        print(_playerState);
        switch (_playerState) {
          case PlayerState.cued :
            return "ready";
          case PlayerState.unStarted :
            return "ready";
          case PlayerState.buffering :
            return "buffering";
          case PlayerState.ended :
            return "complete";
          case PlayerState.paused :
            return "pause";
          case PlayerState.playing :
            return "playing";
          case PlayerState.unknown:
            return "unknown";
        }
      }
    }
    return null;
  }
}
