
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

* bend
  * rigに対しては、長さ・捻り角・曲げ方向・曲げ角度・分割数を指定。
    * 分割した曲げの結果を足したというか掛け合わせたものをmatrixとする。（つまり途中を省略した感じ）その逆行列も取れる。
    * スキンモディファイアはできたら対応したい
* 今のMeshDataで出来ない事
  * 使い途によってListになったりMapになったり。一個でカバーしたい→HumanRigメッシュとかの出力結果
  * 一方名無しデータも簡単に作りたい。MeshBuilderのため。
    * 名無しである必要は無いのでは？
      * MeshDataでなくMeshにkeyを入れておき、toMeshDataで生成
    * 安価なJoin
  * マテリアルマッピング
    * mtllib, usemtlによるグループ化→HumanRigメッシュとかの出力結果
  * Sによるグループ化
  * グループが頂点を共有する必要は必ずしもない。まずは共有無しで考える
  * 複数データを一個に
    * HumanRigへのmesh設定結果をtoMeshDataで一気にできない
    * マテリアルを一個で管理しにくい
  * 今のMeshDataにmtllib, usemtlを追加し、MeshObjectとする
  * <String, List<MeshObject>>をMeshDataとする
    * シンプルなコンストラクタ（個々の図形用）およびマップからのコンストラクタ
* cutter modifier
  * magnetに近いが、質点でなく一定の距離にする（スカルプト）
  * 点でなく三角形とかできないか
  * むしろmagnetに頂点リストで形状を与えたい。今のままでモデリングは難しい
* normalはmodifierと合いが悪い...削除すべきか？
  * 折れ目を考えると回転体もいまいちな感じ。ちょっと考える。
    * 母線に同じ頂点が並んだら折れ目でもいいかな
  * vertices + (faces + smooth)*
  * テクスチャは後でface groupにラップ

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