
# Flutterマテリアルウィジェット拡張サンプルアプリ

# Licenses

All emojis designed by OpenMoji – the open-source emoji and icon project. License: CC BY-SA 4.0

ghost_script_tiger.json is generated from Ghostscript_Tiger.svg
which is released under the GNU Affero General Public License 3.0.

x11_colors uses material from the Wikipedia article "Web colors",
https://en.wikipedia.org/wiki/Web_colors,
which is released under the Creative Commons Attribution-Share-Alike License 3.0.

jis_common_colors program uses material from the Wikipedia article "JIS慣用色名",
https://ja.wikipedia.org/wiki/JIS%E6%85%A3%E7%94%A8%E8%89%B2%E5%90%8D
which is released under the Creative Commons Attribution-Share-Alike License 3.0.

## open_moji_svgs作成手順

絵文字テーブル https://commons.wikimedia.org/wiki/Emoji/Table を参照し、
OpenMojiプロジェクトのSVGファイルをDLする。

1. $ cd scripts/open_moji
2. $ wget https://commons.wikimedia.org/wiki/Emoji/Table  
   (Do it the first time, then as needed.)
3. $ bash make_json.sh
4. main.pyを編集し、DLしたいインデックスをindicesに記入する。
5. $ python main.py
6. $ bash download.sh
   (DL失敗している事もあるのでdownload.logをチェックすること。)
7. /assets/open_moji/*.svgをプロジェクトのassetsフォルダにコピーする。
8. open_moji_svgs.dart.txtをプロジェクトにコピーし、リネームする。
9. プロジェクトのpubspec.yamlに assets/open_moji/ を追加する。fragment.yamlはたぶん必要ない。

二度目以後、download.shは、すでにDLされているファイルはスキップするので、 OpenMojiがアップデートされた場合、
scripts/open_moji/assets/open_moji/*.svgを削除してから実行する。

## Tips

* IconDataの作り方
  * 以下参照。  
    https://stackoverflow.com/questions/65841017/convert-image-to-icondata-flutter  
    https://www.fluttericon.com/

## TODO

* まず
  * Shape, _Beam, Meshを一つにし、MeshDataと分離する。

* ConsumeStatefulWidgetで、initStateでrefでプロバイダ初期化できるか？（awaitできないから、
  初期値をゲットできないが初期化だけならできそう）
  * 非同期初期化できなきゃ余り意味ないか。FutureProviderがあるし。
* layered architectureのサンプル
* Material designのanatomy的な設定箇所の説明図
* M2AppBar上用のデフォルトテーマ
  * 淡色AppBar
* https://pub.dev/packages/scrollable_positioned_list
* 通知一覧ページと通知アイコン
* https://pub.dev/packages/audioplayers
  * https://commons.wikimedia.org/wiki/Category:Sound_sample_files
  * https://commons.wikimedia.org/wiki/Category:MIDI_files
  * WindowsはWAV, mp3しかだめみたい
  * https://pub.dev/packages/just_audio こっちの方がよさそう？
    * 試しに変えたらWindowsがなおさら弱かったので今は止めておく。
    * https://pub.dev/packages/dart_vlc、https://pub.dev/packages/flutter_vlc_player 
      VLCもあるが、プラットフォームで差があったり、将来に期待。
* https://pub.dev/packages/dynamic_color#dynamic_color
* https://pub.dev/packages/maps_launcher
* TextPainterで文字列の幅を取得、Widgetの幅を可変にする（端末設定で変わったりもする）
* Path operation https://api.flutter.dev/flutter/dart-ui/Path-class.html