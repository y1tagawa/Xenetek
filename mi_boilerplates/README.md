# Flutterマテリアルウィジェット拡張サンプルコード

## Features

Flutterマテリアルウィジェットは素晴らしい製品ですが、一部APIや挙動に一貫性のないところがあります。例えば：

* ダークテーマ適用時にウィジェットごとにプライマリカラーが異なる
* ウィジェットごとにenabledがあったり無かったり

特にテーマ関係は、ユーザ個々人の特性に合わせた設定をアプリが提供することが困難なので、回避する必要があります。
その回避策を探る過程のサンプルコードです。

APIも不安定ですのでライブラリとしての利用は推奨できません。

参考：

フォントを変えたら、文字の読めなかった子どもが障害を乗り越え歓喜の涙！ ユニバーサルデザインの書式とは？
https://finders.me/articles.php?id=880

色覚の多様性と色覚バリアフリーなプレゼンテーション
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

* 常にテキストが存在するウィジェット（TextButton等）以外はtooltipを追加する。

## Tips

* Wikipedia:ウィキペディアを二次利用する
  https://ja.wikipedia.org/wiki/Wikipedia:%E3%82%A6%E3%82%A3%E3%82%AD%E3%83%9A%E3%83%87%E3%82%A3%E3%82%A2%E3%82%92%E4%BA%8C%E6%AC%A1%E5%88%A9%E7%94%A8%E3%81%99%E3%82%8B