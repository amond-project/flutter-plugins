# bob_multi_player

Ados Bob Multi Player

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Install
pubspec.yaml에서 아래와 같이 입력한다.
__nteko라고 되어있는 부분은 github의 아이디 이므로 자신의 id를 입력.__

그리고 암호를 입력해야 받을 수 있으므로, 꼭 터미널에서 flutter pub get 이라고 치고, 암호를 물으면 입력하도록 한다.

dependencies:
  flutter:
    sdk: flutter
  bob_multi_player:
    git:
      url: https://nteko@github.com/amond-project/flutter-plugins

## How to Use
__사용될 유닛__
import 'package:bob_multi_player/bob_multi_player.dart';

__코드__
<pre>
<code>
BobMultiPlayer playerObj;

AspectRatio(
            aspectRatio: 320 / 240,
            child: BobMultiPlayer(playerObject: (obj) {
              playerObj = obj;
            },
              playerState: (value, param) {
                print("----" + value + "," + param.toString());
              },),
          ),
</code>
</pre>

