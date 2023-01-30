# Flutterマテリアルウィジェット拡張サンプルコード

## Features

Flutterマテリアルウィジェットは素晴らしい製品ですが、一部APIや挙動に一貫性のないところがあります。例えば：

* ダークテーマ適用時にウィジェットごとにプライマリカラーが異なる
* ウィジェットごとにenabledがあったり無かったり

特にテーマ関係は、ユーザ個々人の特性に合わせた設定をアプリが提供することが困難なので、回避する必要があります。
その回避策を探る過程のサンプルコードです。

APIも不安定ですのでライブラリとしての利用は推奨できません。

参考：
* フォントを変えたら、文字の読めなかった子どもが障害を乗り越え歓喜の涙！ ユニバーサルデザインの書式とは？  
  https://finders.me/articles.php?id=880
* 色覚の多様性と色覚バリアフリーなプレゼンテーション  
  https://www.nig.ac.jp/color/barrierfree/

## Getting started

1. Checkout.
2. flutter pub get at project root.
3. flutter pub get at project root/example.

## Additional information

/exampleにサンプルアプリがあります。

## カスタムウィジェット実装方針

* テーマはアプリ中の一か所で制御すべきである。つまりmain.dartの最上位のTheme。
  カスタムウィジェットでは、デフォルトのコードで一貫した設定がされてないところを、テーマの色から設定するだけにする。

* CheckboxListTileをモデルに、ウィジェットにenabledを追加する。
  * 多用するもの・変更が多いものに限ることにしよう、切りが無いから……

* 常にテキストが存在するウィジェット（TextButton等）以外はtooltipを追加する。
  * 同上

* WoWではSnackBarにアイコンを載せているが、IconThemeは未対応である。
  https://api.flutter.dev/flutter/material/SnackBar-class.html
  しかしマテリアルデザインでは、アイコンはご法度なのでそのままにしておく。
  https://m2.material.io/components/snackbars#anatomy

## Tips

* Wikipedia:ウィキペディアを二次利用する  
  https://ja.wikipedia.org/wiki/Wikipedia:%E3%82%A6%E3%82%A3%E3%82%AD%E3%83%9A%E3%83%87%E3%82%A3%E3%82%A2%E3%82%92%E4%BA%8C%E6%AC%A1%E5%88%A9%E7%94%A8%E3%81%99%E3%82%8B
* Android実機でAnimation再生速度が合わないとき  
  https://github.com/flutter/flutter/issues/60917#issuecomment-654378296

# TODO

* nullableなプロパティも使えるcopyWithの代替
* fromJson, toJsonはtoMap, fromMapを介してはいけない。（jsonEncodeですら要素のパースで嵌るから）

* リリースビルド
* 回避策の実態コメント
* snack barのサンプル+toastの実験ページ
  * 実験中
* embedded tabのもっとおもしろいやつ
* ex_appbar整理
* スプライトビュー
  * domainとpresentationの切り分けの練習
* 3Dの数値モデラ
* loadImage, loadImages
  * FutureProviderでハンドルできるやつ
  * precacheImageも使ってみたがcontextが要るのでWidgetの中に入れねばならず、汎用性が無いのでいったん戻す。
    ImageProvider.resolve→ImageStreamからasyncでロードするにはどうしたら良いのか。

# 

Node
  // 親の座標空間中の原点位置（例えば肘なら肩からのオフセット）
  Point position
  // 親からの回転（肘の曲げ角）
  Quaternion rotation
  Map<String, Node> children

  // パスにあるchild nodeを置換・変換
  // *他のノードも全てコピー
  // *nodeを丸ごと置換する場会は、position, rotation, childrenはできない
  // * pathがnullなら自身のプロパティ。nodeはできない。
  Node copyWith(List<string>? path = null, Node? node, Point? position, rotation, ...)
  

  
