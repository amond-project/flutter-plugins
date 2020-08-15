import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BobPlyrPlayer extends StatefulWidget {
  _BobPlyrPlayerState bobPlyrPlayerState;
  final Function(BobPlyrPlayer playerObj) playerObject;
  final Function(String playerState, List<dynamic> param) playerState;
  final Function() onDataLoaded;
  final String initVid;

  BobPlyrPlayer({this.initVid, this.playerObject, this.playerState, this.onDataLoaded});

  @override
  _BobPlyrPlayerState createState() {
    if (playerObject != null) {
      playerObject(this);
    }
    bobPlyrPlayerState = _BobPlyrPlayerState(this.initVid);
    return bobPlyrPlayerState;
  }

  void play() {
    bobPlyrPlayerState.play();
  }

  void pause() {
    bobPlyrPlayerState.pause();
  }

  void stop() {
    bobPlyrPlayerState.stop();
  }

  void setSource(String src) {
    bobPlyrPlayerState.setSource(src);
  }

  Future<String> getState() async {
    return await bobPlyrPlayerState.getState();
  }
}

class _BobPlyrPlayerState extends State<BobPlyrPlayer> {
  InAppWebViewController webView;
  String src;

  _BobPlyrPlayerState(this.src);

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
              print('BobPlyr Ready');
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

  void toggleFullScreen() {
    webView?.evaluateJavascript(source: "toggleFullScreen()");
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
        <link rel="stylesheet" href="https://cdn.plyr.io/3.6.2/plyr.css" />
        <script src="https://cdn.plyr.io/3.6.2/plyr.js"></script>
    </head>
    <body>
    <div class="plyr__video-embed" id="player">
      <iframe
        src="https://www.youtube.com/embed/$src?origin=https://plyr.io&amp;iv_load_policy=3&amp;modestbranding=1&amp;playsinline=1&amp;showinfo=0&amp;rel=0&amp;enablejsapi=1"
        allowfullscreen
        allowtransparency
        allow="autoplay"
      ></iframe>
    </div>
    <script>
    const player = new Plyr('#player');
    player.on('ready', event => {
        //const instance = event.detail.plyr;
        window.flutter_inappwebview.callHandler('Ready');
    });
    player.on('play', event => {
        //const instance = event.detail.plyr;
        window.flutter_inappwebview.callHandler('Play');
    });
    player.on('pause', event => {
        //const instance = event.detail.plyr;
        window.flutter_inappwebview.callHandler('Pause');
    });
    player.on('ended', event => {
        //const instance = event.detail.plyr;
        window.flutter_inappwebview.callHandler('Complete');
    });
    player.on('enterfullscreen', event => {
        //const instance = event.detail.plyr;
        window.flutter_inappwebview.callHandler('FullScreen', 1);
    });
    player.on('exitfullscreen', event => {
        //const instance = event.detail.plyr;
        window.flutter_inappwebview.callHandler('FullScreen', 0);
    });
    player.on('controlshidden', event => {
        //const instance = event.detail.plyr;
        window.flutter_inappwebview.callHandler('ControlsHidden');
    });
    player.on('controlsshown', event => {
        //const instance = event.detail.plyr;
        window.flutter_inappwebview.callHandler('ControlsShown');
    });
    player.on('statechange', event => {
        window.flutter_inappwebview.callHandler('StateChange', event.detail.code);
    });
    
    function play() {
      player.play();
    }

    function pause() {
      player.pause();
    }
    
    function toggleFullScreen() {
      player.fullscreen.toggle();
    }
    
    function loadById(src) {
        player.source = {
          type: 'video',
          sources: [
            {
              src: src,
              provider: 'youtube',
            },
          ],
        };
    }
    </script>
    </body>
    </html>
  ''';
}
