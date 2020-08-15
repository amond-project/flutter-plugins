import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'BobPlyrPlayer.dart';
import 'BobWCDPlayer.dart';
import 'BobYouTubePlayer.dart';
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

  void setSource(String src) {
    _bobMultiPlayerState.setSource(src);
  }

  Future<String> getState() async {
    return await _bobMultiPlayerState.getState();
  }
}


class _BobMultiPlayerState extends State<BobMultiPlayer> {
  bool _isPlayerReady = false;
  BobWCDPlayer _wcdPlayerObj;
  BobPlyrPlayer _bobYouTubePlayerObj;

  PlayerState _playerState;

  Widget _player;

  PlayerType _playerType = PlayerType.none;

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
        _bobYouTubePlayerObj.setSource(src);
      } else {
        _playerType = PlayerType.youTube;
        setState(() {
          _player = BobPlyrPlayer(
            initVid: src,
            playerObject: (obj) {
              _bobYouTubePlayerObj = obj;
            },
            playerState: (value, param) {
              if (widget.playerState != null && mounted) {
                widget.playerState(value, param);
              }
            },
            onDataLoaded:(){
            },
          );
        });
      }
    }
  }

  void play() {
    _playerType == PlayerType.youTube?_bobYouTubePlayerObj?.play(): _wcdPlayerObj?.play();
  }

  void stop() {
    _playerType == PlayerType.youTube?_bobYouTubePlayerObj?.pause(): _wcdPlayerObj?.stop();
  }

  void pause() {
    _playerType == PlayerType.youTube?_bobYouTubePlayerObj?.pause():_wcdPlayerObj?.pause();
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
