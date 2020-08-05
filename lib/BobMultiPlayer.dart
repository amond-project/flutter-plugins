import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'BobWCDPlayer.dart';
import 'player_type.dart';

class BobMultiPlayer extends StatefulWidget {
  final _BobMultiPlayerState _bobMultiPlayerState = _BobMultiPlayerState();

  final Function(BobMultiPlayer playerObj) playerObject;
  final Function(String playerState, List<dynamic> param) playerState;

  BobMultiPlayer({this.playerObject, this.playerState});

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

  Future<String> getState() async {
    return await _bobMultiPlayerState.getState();
  }
}


class _BobMultiPlayerState extends State<BobMultiPlayer> {
  bool _isPlayerReady = false;
  BobWCDPlayer _wcdPlayerObj;

  PlayerState _playerState;
  YoutubeMetaData _videoMetaData;
  YoutubePlayerController _controller;

  Widget _player;

  PlayerType _playerType = PlayerType.none;

  void listener() {
//    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
//        _playerState = _controller.value.playerState;
//        _videoMetaData = _controller.metadata;
//    }

    if (widget.playerState != null && mounted) {
      if (_playerState != _controller.value.playerState)
        switch (_controller.value.playerState) {
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
        }
    }
    _playerState = _controller.value.playerState;
  }

  YoutubePlayer createYoutubePlayer(String vid) {
    _controller = YoutubePlayerController(
      initialVideoId: vid,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);

    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blueAccent,
      onReady: () {
        _isPlayerReady = true;
      },
      onEnded: (data) {

      },
    );
  }

  @override
  void initState() {
    super.initState();
    _player = Container(color: Colors.black,);
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
        _wcdPlayerObj?.setSouce(src);
      } else {
        _playerType = PlayerType.weCanDeo;
        setState(() {
          _player = BobWCDPlayer(playerObject: (obj) {
            _wcdPlayerObj = obj;
            _wcdPlayerObj?.setSouce(src);
          },
            playerState: (value, param) {
              if (widget.playerState != null && mounted) {
                widget.playerState(value, param);
              }
            },);
        });
      }
    }
    else {
      if (_playerType == PlayerType.youTube) {
        _controller.load(src);
      } else {
        _playerType = PlayerType.youTube;
        setState(() {
          _player = createYoutubePlayer(src);
        });
      }
    }
  }

  void play() {
    _playerType == PlayerType.youTube?_controller?.play(): _wcdPlayerObj?.play();
  }

  void stop() {
    _playerType == PlayerType.youTube?_controller?.pause(): _wcdPlayerObj?.stop();
  }

  void pause() {
    _playerType == PlayerType.youTube?_controller?.pause():_wcdPlayerObj?.pause();
  }

  //          Returns String
  //          – VALUE : idle , playing , pause , buffering
  Future<String> getState() async {
    if (_playerType == PlayerType.weCanDeo)
      return await _wcdPlayerObj.getState();
    else {
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
    return null;
  }
}
