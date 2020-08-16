import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BobWCDPlayer extends StatefulWidget {
  final _BobWCDPlayerState bobWCDPlayerState = _BobWCDPlayerState();

  final Function(BobWCDPlayer playerObj) playerObject;
  final Function(String playerState, List<dynamic> param) playerState;
  final String initVid;

  BobWCDPlayer({this.playerObject, this.playerState, this.initVid});

  @override
  _BobWCDPlayerState createState() {
    if (playerObject != null) {
      playerObject(this);
    }

    setSource(initVid);

    return bobWCDPlayerState;
  }

  void play() {
    bobWCDPlayerState.play();
  }

  void pause() {
    bobWCDPlayerState.pause();
  }

  void stop() {
    bobWCDPlayerState.stop();
  }

  void setSource(String src) {
    bobWCDPlayerState.setSource(src);
  }

  Future<String> getState() async {
    return await bobWCDPlayerState.getState();
  }
}

class _BobWCDPlayerState extends State<BobWCDPlayer> {
  InAppWebViewController webView;
  String src = "";
  String margin = "-19px";

  _BobWCDPlayerState() {
    if(Platform.isIOS) {
      margin = "-20px";
    }
  }

  String get wcdPlayer =>
      ''''<!DOCTYPE html>
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
          <script src="http://play.wecandeo.com/html/utils/iframeAPI.js"></script>
          <script>
          var api;
          window.onload = function(){
            var ifrm = document.getElementById('bobplayer');
            var contents = ifrm.contentWindow || ifrm.contentDocument;
            let script = document.createElement('script')
            script.onload = () => {
              api = new smIframeAPI(contents);
              console.log(smIframeEvent.PLAY);
              //api.setName('bobplayer'); //api.setName의 입력값과 iframe 태그의 name 값은 같아야 합니다.
              api.onEvent(smIframeEvent.PLAY , function(){
                window.flutter_inappwebview.callHandler('PLAY');
              });
              api.onEvent(smIframeEvent.READY , function(){
                window.flutter_inappwebview.callHandler('READY');
              });
              
              api.onEvent(smIframeEvent.PAUSE , function(){
                window.flutter_inappwebview.callHandler('PAUSE');
              });
              api.onEvent(smIframeEvent.BUFFERING , function(data){
                window.flutter_inappwebview.callHandler('BUFFERING', data);
              });
              api.onEvent(smIframeEvent.IDLE , function(){
                window.flutter_inappwebview.callHandler('IDLE');
              });
              
              api.onEvent(smIframeEvent.COMPLETE , function(){
                window.flutter_inappwebview.callHandler('COMPLETE');
              });
              api.onEvent(smIframeEvent.ERROR , function(data){
                window.flutter_inappwebview.callHandler('ERROR', data);
              });
              api.onEvent(smIframeEvent.VIDEO_RATE , function(data){
                window.flutter_inappwebview.callHandler('VIDEO_RATE', data);
              });
              api.onEvent(smIframeEvent.VOLUME , function(data){
                window.flutter_inappwebview.callHandler('VOLUME', data);
              });
              api.onEvent(smIframeEvent.SEEK , function(data){
                window.flutter_inappwebview.callHandler('SEEK', data);
              });
//              api.onEvent(smIframeEvent.TIME , function(data){
//                window.flutter_inappwebview.callHandler('TIME');
//              });
              api.onEvent(smIframeEvent.FULLSCREEN , function(data){
                window.flutter_inappwebview.callHandler('FULLSCREEN', data);
              });
            }
            script.async = true
            script.src = 'https://play.wecandeo.com/html/utils/iframeAPI.js'
            document.head.appendChild(script);
          }
          
          function play() {
            api.play();
            return;
          }
          
          function stop() {
            api.stop();
            return;
          }
          
          function pause() {
            api.pause();
            return;
          }
          
          function getState() {
            return api.getState();
          }
          
          </script>
          <iframe id='bobplayer'
            style="margin-top: $margin;"
            width="100%" height="100%" 
            src="$src&auto=true" 
            frameborder="0" 
            allowfullscreen 
            allow="autoplay;fullscreen;">
           </iframe>
          </body>
          </html>''';
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: wcdPlayer,
        baseUrl: 'http://play.wecandeo.com',
        encoding: 'utf-8',
        mimeType: 'text/html',
      ),
      initialOptions: InAppWebViewGroupOptions(
        ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
        crossPlatform: InAppWebViewOptions(
          //mediaPlaybackRequiresUserGesture: true,
          transparentBackground: true,
          //debuggingEnabled: true,
          //supportZoom: false
        ),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        controller
          ..addJavaScriptHandler(handlerName: 'PLAY', callback: (_){
          playerState('play', null);
        })
        ..addJavaScriptHandler(handlerName: 'READY', callback: (_){
          playerState('ready', null);
          play();
        })
        ..addJavaScriptHandler(handlerName: 'PAUSE', callback: (_){
          playerState('pause', null);
        })
        ..addJavaScriptHandler(handlerName: 'BUFFERING', callback: (data){
          playerState('buffering', data);
        })
        ..addJavaScriptHandler(handlerName: 'IDLE', callback: (_){
          playerState('idle', null);
        })
        ..addJavaScriptHandler(handlerName: 'COMPLETE', callback: (_){
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          playerState('complete', null);
        })
        ..addJavaScriptHandler(handlerName: 'ERROR', callback: (data){
          playerState('error', data);
        })
        ..addJavaScriptHandler(handlerName: 'VIDEO_RATE', callback: (data){
          playerState('video_rate', data);
        })
        ..addJavaScriptHandler(handlerName: 'VOLUME', callback: (data){
          playerState('volume', data);
        })
        ..addJavaScriptHandler(handlerName: 'SEEK', callback: (data){
          playerState('seek', data);
        })
        ..addJavaScriptHandler(handlerName: 'TIME', callback: (data){
          playerState('time', data);
        })
        ..addJavaScriptHandler(handlerName: 'FULLSCREEN', callback: (data){
          fullScreen(data);
        });
        },
      onLoadStart: (InAppWebViewController controller, String url) {
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
      },
    );
  }

  void playerState(String value, List<dynamic> param) {
    if (widget.playerState != null) {
      widget.playerState(value, param);
    }
  }

  void fullScreen(List<dynamic> param) {
    if (param[0]["value"]) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void setSource(String src) {
    if (src != this.src) {
      this.src = src;
      webView?.loadData(data: wcdPlayer);
    }
  }

  void play() {
    webView?.evaluateJavascript(source: "play()");
  }

  void stop() {
    webView?.evaluateJavascript(source: "stop()");
  }

  void pause() {
    webView?.evaluateJavascript(source: "pause()");
  }

  //          Returns String
//          – VALUE : idle , playing , pause , buffering
  Future<String> getState() async {
      return await webView?.evaluateJavascript(source: "getState()");
  }
}
