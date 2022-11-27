
# Flutterマテリアルウィジェット拡張サンプルアプリ

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

二度目以後、download.shは、すでにDLされているファイルはスキップする。
OpenMojiがアップデートされた場合、scripts/open_moji/assets/open_moji/*.svgを削除してから実行する。

## TODO
* Material designのanatomy的な設定箇所の説明図
* Colors
  * Reorderable, dismissive
* M2AppBar上用のデフォルトテーマ
  * 淡色AppBar
* https://pub.dev/packages/scrollable_positioned_list

* 絵文字テーブル https://commons.wikimedia.org/wiki/Emoji/Table をDL、コードと名前をピックして 
  * dartを生成
  * OpenMojiからDL
    wget https://commons.wikimedia.org/wiki/Emoji/Table
    grep -e '^<td><code>\|^<td style="text-align: initial">\|^<th>[0-9]' Table >table2
    sed -e 's/<\/code> <br \/> <code>/-/g' -e 's/<\/code>/":/g' -e 's/<td><code>/{"/g' table2

  * sed -e 's/<th>\([0-9]*\)$/{"\1":/g' table2 |
    sed -e 's/<\/code> <br \/> <code>/-/g' -e 's/<\/code>/",/g' -e 's/<td><code>/{"code":/g' |
    sed -e 's/<br \/><small>/","keywords": "/g' -e 's/<\/small>/"}},/g' -e 's/<td style="text-align: initial">/"name":"/g'

sed -e 's/<th>\([0-9]*\)/{"\1":/g' Documents/emoji_dl/table2 |   sed -e 's/<\/code> <br \/> <code>/-/g' -e 's/<\/code>/",/g' -e 's/<td><code>/{"code":/g' |   sed -e ' s/<br \/><small>/","keywords": "/g' -e 's/<\/small>/"}},/g' -e 's/<td style="text-align: initial">/"name":"/g'


## Tips

* IconDataの作り方
  * 以下参照。  
    https://stackoverflow.com/questions/65841017/convert-image-to-icondata-flutter  
    https://www.fluttericon.com/
