import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BobYouTubePlayer extends StatefulWidget {
  _BobYouTubePlayerState bobYouTubePlayerState;
  final Function(BobYouTubePlayer playerObj) playerObject;
  final Function(String playerState, List<dynamic> param) playerState;
  final Function() onDataLoaded;
  final String initVid;

  BobYouTubePlayer({this.initVid, this.playerObject, this.playerState, this.onDataLoaded}) {
    print("BobYouTubePlayer Created");
    bobYouTubePlayerState = _BobYouTubePlayerState(initVid);
  }

  @override
  _BobYouTubePlayerState createState() {
    if (playerObject != null) {
      playerObject(this);
    }

    return bobYouTubePlayerState;
  }

  void play() {
    bobYouTubePlayerState.play();
  }

  void pause() {
    bobYouTubePlayerState.pause();
  }

  void stop() {
    bobYouTubePlayerState.stop();
  }

  void setSource(String src) {
    bobYouTubePlayerState.setSource(src);
  }

  Future<String> getState() async {
    return await bobYouTubePlayerState.getState();
  }
}

class _BobYouTubePlayerState extends State<BobYouTubePlayer> {
  InAppWebViewController webView;
  String src = "";

  _BobYouTubePlayerState(String initVid) {
    src = initVid;
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: player,
        baseUrl: 'https://www.youtube.com',
        encoding: 'utf-8',
        mimeType: 'text/html',
      ),
      initialOptions: InAppWebViewGroupOptions(
        ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
        crossPlatform: InAppWebViewOptions(
          //userAgent:'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36',
          transparentBackground: true,
        ),
      ),
      onWebViewCreated: (webController) {
        webView = webController;
        webController
          ..addJavaScriptHandler(
            handlerName: 'Ready',
            callback: (_) {
              print('BobYT Ready');
            },
          )
          ..addJavaScriptHandler(
            handlerName: 'StateChange',
            callback: (data) {
              switch (data.first as int) {
                case -1: //unStarted
                  playerState('ready', null);
                  break;
                case 0: //ended
                  playerState('complete', null);
                  break;
                case 1: //playing
                  playerState('playing', null);
                  break;
                case 2: //paused
                  playerState('pause', null);
                  break;
                case 3: //buffering
                  playerState('buffering', data);
                  break;
                case 5: //cued
                  playerState('ready', null);
                  break;
                default:
                  throw Exception("Invalid player state obtained.");
              }
            },
          )
          ..addJavaScriptHandler(
            handlerName: 'PlaybackQualityChange',
            callback: (args) {
                print( args.first as String);
            },
          )
          ..addJavaScriptHandler(
            handlerName: 'PlaybackRateChange',
            callback: (args) {
              final num rate = args.first;
                print(rate);
            },
          )
          ..addJavaScriptHandler(
            handlerName: 'Errors',
            callback: (args) {
                print(args.first);
            },
          )
          ..addJavaScriptHandler(
            handlerName: 'VideoData',
            callback: (args) {
               print(args.first);
            },
          )
          ..addJavaScriptHandler(
            handlerName: 'VideoTime',
            callback: (args) {
              final position = args.first * 1000;
              final num buffered = args.last;
//                  position: Duration(milliseconds: position.floor()),
//                  buffered: buffered.toDouble(),
            },
          );
      },
      onLoadStop: (_, __) {
        if (widget.onDataLoaded != null) {
          widget.onDataLoaded();
        }
      },
      onReceivedServerTrustAuthRequest: (InAppWebViewController controller, ServerTrustChallenge challenge) async {
        return new ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
      },
    );
  }

  void playerState(String value, List<dynamic> param) {
    if (widget.playerState != null) {
      widget.playerState(value, param);
    }
  }

  void setSource(String src) {
    if (src != this.src) {
      this.src = src;
//      webView?.loadData(data: player);
      webView?.evaluateJavascript(source: "loadById('$src')");
    }
  }

  void play() {
    webView?.evaluateJavascript(source: "play()");
  }

  void pause() {
    webView?.evaluateJavascript(source: "pause()");
  }

  void stop() {
    webView?.evaluateJavascript(source: "pause()");
  }

  Future<String> getState() async {
    return await webView?.evaluateJavascript(source: "getState()");
  }

  String get player => '''
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            html,
            body {
                margin: 0;
                padding: 0;
                background-color: #000000;
                overflow: hidden;
                position: fixed;
                height: 100%;
                width: 100%;
            }
        </style>
        <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
    </head>
    <body>
        <div id="player"></div>
        <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
            var player;
            var timerId;
            function onYouTubeIframeAPIReady() {
                player = new YT.Player('player', {
                    height: '100%',
                    width: '100%',
                    videoId: '$src',
                    playerVars: {
                        'enablejsapi': 1,
                        'fs': 0,
                        'rel': 0,
                        'showinfo': 0,
                        'playsinline': 1,
                        'autoplay': 1,
                    },
                    events: {
                        onReady: function(event) { window.flutter_inappwebview.callHandler('Ready'); },
                        onStateChange: function(event) { sendPlayerStateChange(event.data); },
                        onPlaybackQualityChange: function(event) { window.flutter_inappwebview.callHandler('PlaybackQualityChange', event.data); },
                        onPlaybackRateChange: function(event) { window.flutter_inappwebview.callHandler('PlaybackRateChange', event.data); },
                        onError: function(error) { window.flutter_inappwebview.callHandler('Errors', error.data); }
                    },
                });
            }

            function sendPlayerStateChange(playerState) {
                clearTimeout(timerId);
                window.flutter_inappwebview.callHandler('StateChange', playerState);
//                if (playerState == 1) {
//                    startSendCurrentTimeInterval();
//                    sendVideoData(player);
//                }
            }

            function sendVideoData(player) {
                var videoData = {
                    'duration': player.getDuration(),
                    'title': player.getVideoData().title,
                    'author': player.getVideoData().author,
                    'videoId': player.getVideoData().video_id
                };
                window.flutter_inappwebview.callHandler('VideoData', videoData);
            }

            function startSendCurrentTimeInterval() {
                timerId = setInterval(function () {
                    window.flutter_inappwebview.callHandler('VideoTime', player.getCurrentTime(), player.getVideoLoadedFraction());
                }, 100);
            }

            function play() {
                player.playVideo();
                return '';
            }

            function pause() {
                player.pauseVideo();
                return '';
            }

            function loadById(loadSettings) {
                player.loadVideoById(loadSettings);
                return '';
            }

            function cueById(cueSettings) {
                player.cueVideoById(cueSettings);
                return '';
            }

            function loadPlaylist(playlist, index, startAt) {
                player.loadPlaylist(playlist, 'playlist', index, startAt);
                return '';
            }

            function cuePlaylist(playlist, index, startAt) {
                player.cuePlaylist(playlist, 'playlist', index, startAt);
                return '';
            }

            function mute() {
                player.mute();
                return '';
            }

            function unMute() {
                player.unMute();
                return '';
            }

            function setVolume(volume) {
                player.setVolume(volume);
                return '';
            }

            function seekTo(position, seekAhead) {
                player.seekTo(position, seekAhead);
                return '';
            }

            function setSize(width, height) {
                player.setSize(width, height);
                return '';
            }

            function setPlaybackRate(rate) {
                player.setPlaybackRate(rate);
                return '';
            }

            function setTopMargin(margin) {
                document.getElementById("player").style.marginTop = margin;
                return '';
            }
        </script>
    </body>
    </html>
  ''';
}
