
# Flutterマテリアルウィジェット拡張サンプルアプリ

All emojis designed by OpenMoji – the open-source emoji and icon project. License: CC BY-SA 4.0

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

* Material designのanatomy的な設定箇所の説明図
* M2AppBar上用のデフォルトテーマ
  * 淡色AppBar
* https://pub.dev/packages/scrollable_positioned_list
* ToastのF.I./F.O.、キュー（まではいらないか。SnackBarがあるのだから）
* 通知一覧ページと通知アイコン
