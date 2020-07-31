import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'BobWCDPlayer.dart';

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

  bool isYouTubePlayer = false;

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
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
    );

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
      isYouTubePlayer = false;
      setState(() {
        _player = BobWCDPlayer(playerObject: (obj){
          _wcdPlayerObj = obj;
          _wcdPlayerObj?.setSouce(src);
        },
          playerState: (value, param){
            print("----"+value+"," +  param.toString() );
          },);
      });
    }
    else {
      isYouTubePlayer = true;
      setState(() {
        _player = createYoutubePlayer(src);
      });
    }
  }

  void play() {
    isYouTubePlayer?_controller?.play(): _wcdPlayerObj?.play();
  }

  void stop() {
    isYouTubePlayer?_controller?.pause(): _wcdPlayerObj?.stop();
  }

  void pause() {
    isYouTubePlayer?_controller?.pause():_wcdPlayerObj?.pause();
  }

  //          Returns String
//          – VALUE : idle , playing , pause , buffering
  Future<String> getState() async {
    return await _wcdPlayerObj.getState();
  }
}
