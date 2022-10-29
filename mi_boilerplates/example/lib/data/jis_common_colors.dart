// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This program uses material from the Wikipedia article "JIS慣用色名",
// which is released under the Creative Commons Attribution-Share-Alike License 3.0.

import 'package:flutter/material.dart';

///
/// JIS慣用色名
///
const jisCommonColors = [
  Color(0xFFF9A1D0), // とき色
  Color(0xFFCB4B94), // つつじ色
  Color(0xFFFFDBED), // 桜色
  Color(0xFFD34778), // ばら色
  Color(0xFFE3557F), // からくれない
  Color(0xFFFF87A0), // さんご色
  Color(0xFFE08899), // 紅梅(こうばい)色
  Color(0xFFE38698), // 桃色
  Color(0xFFBD1E48), // 紅色
  Color(0xFFB92946), // 紅赤
  Color(0xFFAE3846), // えんじ
  Color(0xFF974B52), // 蘇芳(すおう)
  Color(0xFFA0283A), // 茜(あかね)色
  Color(0xFFBF1E33), // 赤
  Color(0xFFED514E), // 朱色
  Color(0xFFA14641), // 紅樺(べにかば)色
  Color(0xFFEE5145), // 紅緋(べにひ)
  Color(0xFFD3503C), // 鉛丹(えんたん)色
  Color(0xFF703B32), // 紅海老茶
  Color(0xFF7D483E), // とび色
  Color(0xFF946259), // 小豆(あずき)色
  Color(0xFF8A4031), // 弁柄(べんがら)色
  Color(0xFF6D3D33), // 海老茶
  Color(0xFFED542A), // 金赤
  Color(0xFFB15237), // 赤茶
  Color(0xFF923A21), // 赤錆色
  Color(0xFFEF6D3E), // 黄丹(おうに)
  Color(0xFFED551B), // 赤橙
  Color(0xFFE06030), // 柿色
  Color(0xFFB97761), // 肉桂(にっけい)色
  Color(0xFFBD4A1D), // 樺(かば)色
  Color(0xFF974E33), // れんが色
  Color(0xFF664134), // 錆色
  Color(0xFF8A604F), // 檜皮(ひわだ)色
  Color(0xFF754C38), // 栗色
  Color(0xFFE45E00), // 黄赤
  Color(0xFFBA6432), // たいしゃ
  Color(0xFFB67A52), // らくだ色
  Color(0xFFBB6421), // 黄茶
  Color(0xFFF4BE9B), // 肌色
  Color(0xFFFD7E00), // 橙色
  Color(0xFF866955), // 灰茶
  Color(0xFF734E30), // 茶色
  Color(0xFF594639), // 焦茶
  Color(0xFFFFA75E), // こうじ色
  Color(0xFFDDA273), // 杏色
  Color(0xFFFA8000), // 蜜柑色
  Color(0xFF763900), // 褐色
  Color(0xFFA96E2D), // 土色
  Color(0xFFD9A46D), // 小麦色
  Color(0xFFC67400), // こはく色
  Color(0xFFC47600), // 金茶
  Color(0xFFFABE6F), // 卵色
  Color(0xFFFFA500), // 山吹色
  Color(0xFFC18A39), // 黄土色
  Color(0xFF897868), // 朽葉(くちば)色
  Color(0xFFFFB500), // ひまわり色
  Color(0xFFFCAC00), // うこん色
  Color(0xFFC9B9A8), // 砂色
  Color(0xFFCDA966), // 芥子(からし)色
  Color(0xFFFFBE00), // 黄色
  Color(0xFFFFBE00), // たんぽぽ色
  Color(0xFF70613A), // 鶯茶
  Color(0xFFFAD43A), // 中黄
  Color(0xFFEED67E), // 刈安(かりやす)色
  Color(0xFFD9CB65), // きはだ色
  Color(0xFF736F55), // みる色
  Color(0xFFC2C05C), // ひわ色
  Color(0xFF71714A), // 鶯(うぐいす)色
  Color(0xFFBDBF92), // 抹茶色
  Color(0xFFB9C42F), // 黄緑
  Color(0xFF7A7F46), // 苔色
  Color(0xFFA9B735), // 若草色
  Color(0xFF96AA3D), // 萌黄(もえぎ)
  Color(0xFF72814B), // 草色
  Color(0xFFAFC297), // 若葉色
  Color(0xFF6E815C), // 松葉色
  Color(0xFFCADBCF), // 白緑(びゃくろく)
  Color(0xFF4DB56A), // 緑
  Color(0xFF357C4C), // 常磐(ときわ)色
  Color(0xFF5F836D), // 緑青(ろくしょう)色
  Color(0xFF4A6956), // 千歳緑(ちとせみどり)
  Color(0xFF005731), // 深緑
  Color(0xFF15543B), // もえぎ色
  Color(0xFF49A581), // 若竹色
  Color(0xFF80AA9F), // 青磁色
  Color(0xFF7AAAAC), // 青竹色
  Color(0xFF244344), // 鉄色
  Color(0xFF0090A8), // 青緑
  Color(0xFF6C8D9B), // 錆浅葱
  Color(0xFF7A99AA), // 水浅葱
  Color(0xFF69AAC6), // 新橋色
  Color(0xFF0087AA), // 浅葱(あさぎ)色
  Color(0xFF84B5CF), // 白群(びゃくぐん)
  Color(0xFF166A88), // 納戸色
  Color(0xFF8CB4CE), // かめのぞき
  Color(0xFFA9CEEC), // 水色
  Color(0xFF5E7184), // 藍鼠(あいねず)
  Color(0xFF95C0EC), // 空色
  Color(0xFF0067C0), // 青
  Color(0xFF2E4B71), // 藍色
  Color(0xFF20324E), // 濃藍(こいあい)
  Color(0xFF92AFE4), // 勿忘草(わすれなぐさ)色
  Color(0xFF3D7CCE), // 露草色
  Color(0xFF3C639B), // はなだ色
  Color(0xFF3D496B), // 紺青(こんじょう)
  Color(0xFF3451A4), // るり色
  Color(0xFF324784), // るり紺
  Color(0xFF333C5E), // 紺色
  Color(0xFF4C5DAB), // かきつばた色
  Color(0xFF383C57), // 勝色(かちいろ)
  Color(0xFF414FA3), // 群青(ぐんじょう)色
  Color(0xFF232538), // 鉄紺
  Color(0xFF6869A8), // 藤納戸
  Color(0xFF4A49AD), // ききょう色
  Color(0xFF35357D), // 紺藍
  Color(0xFFA09BD8), // 藤色
  Color(0xFF948BDB), // 藤紫
  Color(0xFF704CBC), // 青紫
  Color(0xFF6D52AB), // 菫(すみれ)色
  Color(0xFF675D7E), // 鳩羽(はとば)色
  Color(0xFF7051AA), // しょうぶ色
  Color(0xFF5F4C86), // 江戸紫
  Color(0xFFA260BF), // 紫
  Color(0xFF775686), // 古代紫
  Color(0xFF47384F), // なす紺
  Color(0xFF402949), // 紫紺
  Color(0xFFC27BC8), // あやめ色
  Color(0xFFC24DAE), // 牡丹(ぼたん)色
  Color(0xFFC54EA0), // 赤紫
  Color(0xFFF1F1F1), // 白
  Color(0xFFF2E8EC), // 胡粉(ごふん)色
  Color(0xFFF0E2E0), // 生成り(きなり)色
  Color(0xFFE3D4CA), // 象牙(ぞうげ)色
  Color(0xFFA0A0A0), // 銀鼠(ぎんねず)
  Color(0xFF9F9190), // 茶鼠
  Color(0xFF868686), // 鼠色
  Color(0xFF787C7A), // 利休鼠
  Color(0xFF797A88), // 鉛色
  Color(0xFF797979), // 灰色
  Color(0xFF605448), // すす竹色
  Color(0xFF3E2E28), // 黒茶
  Color(0xFF313131), // 墨
  Color(0xFF262626), // 黒
  Color(0xFF262626), // 鉄黒
  Color(0xFFC74F90), // ローズレッド
  Color(0xFFEF93B6), // ローズピンク
  Color(0xFFAF3168), // コチニールレッド
  Color(0xFFB91E68), // ルビーレッド
  Color(0xFF83274E), // ワインレッド
  Color(0xFF452A35), // バーガンディー
  Color(0xFFC97F96), // オールドローズ
  Color(0xFFD94177), // ローズ
  Color(0xFFBB1E5E), // ストロベリー
  Color(0xFFFF87A0), // コーラルレッド
  Color(0xFFEB97A8), // ピンク
  Color(0xFF55353B), // ボルドー
  Color(0xFFFFC9D2), // ベビーピンク
  Color(0xFFDD4157), // ポピーレッド
  Color(0xFFCE314A), // シグナルレッド
  Color(0xFFBE1E3E), // カーマイン
  Color(0xFFDE424C), // レッド
  Color(0xFFDE424C), // トマトレッド
  Color(0xFF682A2B), // マルーン
  Color(0xFFED514E), // バーミリオン
  Color(0xFFDE4335), // スカーレット
  Color(0xFFAC5647), // テラコッタ
  Color(0xFFFFA594), // サーモンピンク
  Color(0xFFFBCCC3), // シェルピンク
  Color(0xFFF1BEB1), // ネールピンク
  Color(0xFFFF5D20), // チャイニーズレッド
  Color(0xFFCC572C), // キャロットオレンジ
  Color(0xFFA8593C), // バーントシェンナ
  Color(0xFF52372F), // チョコレート
  Color(0xFF754C38), // ココアブラウン
  Color(0xFFEBC0AF), // ピーチ
  Color(0xFFBB6421), // ローシェンナ
  Color(0xFFFD7E00), // オレンジ
  Color(0xFF734E31), // ブラウン
  Color(0xFFDDA273), // アプリコット
  Color(0xFFA56F3F), // タン
  Color(0xFFFD951E), // マンダリンオレンジ
  Color(0xFFA58161), // コルク
  Color(0xFFF8CFAE), // エクルベイジュ
  Color(0xFFF39A38), // ゴールデンイエロー
  Color(0xFFFFA000), // マリーゴールド
  Color(0xFFC5996D), // バフ
  Color(0xFFB37D40), // アンバー
  Color(0xFF815A2B), // ブロンズ
  Color(0xFFC1AB96), // ベージュ
  Color(0xFFC18A39), // イエローオーカー
  Color(0xFF5B462A), // バーントアンバー
  Color(0xFF4A3B2A), // セピア
  Color(0xFF9A753A), // カーキー
  Color(0xFFE3B466), // ブロンド
  Color(0xFFF2C26B), // ネープルスイエロー
  Color(0xFFE1C59B), // レグホーン
  Color(0xFF7F5C13), // ローアンバー
  Color(0xFFFFBC00), // クロムイエロー
  Color(0xFFFFCC00), // イエロー
  Color(0xFFE8D5AF), // クリームイエロー
  Color(0xFFFFCC00), // ジョンブリアン
  Color(0xFFF7D54E), // カナリヤ
  Color(0xFF68624E), // オリーブドラブ
  Color(0xFF605627), // オリーブ
  Color(0xFFE8C800), // レモンイエロー
  Color(0xFF565838), // オリーブグリーン
  Color(0xFFBDD458), // シャトルーズグリーン
  Color(0xFF879D4E), // リーフグリーン
  Color(0xFF737C3E), // グラスグリーン
  Color(0xFF9AB961), // シーグリーン
  Color(0xFF516A39), // アイビーグリーン
  Color(0xFFB0D3A8), // アップルグリーン
  Color(0xFF81CC91), // ミントグリーン
  Color(0xFF2A9B50), // グリーン
  Color(0xFF5DC288), // コバルトグリーン
  Color(0xFF4DA573), // エメラルドグリーン
  Color(0xFF008047), // マラカイトグリーン
  Color(0xFF264435), // ボトルグリーン
  Color(0xFF3E795C), // フォレストグリーン
  Color(0xFF156F5C), // ビリジアン
  Color(0xFF004840), // ビリヤードグリーン
  Color(0xFF007F91), // ピーコックグリーン
  Color(0xFF5190A4), // ナイルブルー
  Color(0xFF00708B), // ピーコックブルー
  Color(0xFF399ECC), // ターコイズブルー
  Color(0xFF005175), // マリンブルー
  Color(0xFF91B2D2), // ホリゾンブルー
  Color(0xFF219DDD), // シアン
  Color(0xFF95C0EC), // スカイブルー
  Color(0xFF0B74AF), // セルリアンブルー
  Color(0xFFABBDDA), // ベビーブルー
  Color(0xFF627DA1), // サックスブルー
  Color(0xFF3170B9), // ブルー
  Color(0xFF2863AB), // コバルトブルー
  Color(0xFF3D496B), // アイアンブルー
  Color(0xFF3D496B), // プルシャンブルー
  Color(0xFF00152D), // ミッドナイトブルー
  Color(0xFF7586BB), // ヒヤシンス
  Color(0xFF333C5E), // ネービーブルー
  Color(0xFF414FA3), // ウルトラマリンブルー
  Color(0xFF37438F), // オリエンタルブルー
  Color(0xFF776ED2), // ウィスタリア
  Color(0xFF40317E), // パンジー
  Color(0xFF836DC5), // ヘリオトロープ
  Color(0xFF6D52AB), // バイオレット
  Color(0xFF9E8EAE), // ラベンダー
  Color(0xFF835FA8), // モーブ
  Color(0xFFC2A2DA), // ライラック
  Color(0xFFC7A1D7), // オーキッド
  Color(0xFFA260BF), // パープル
  Color(0xFFC949A2), // マゼンタ
  Color(0xFFCF61A5), // チェリーピンク
  Color(0xFFF1F1F1), // ホワイト
  Color(0xFFF1F1F1), // スノーホワイト
  Color(0xFFE3D4CA), // アイボリー
  Color(0xFFBABAC6), // スカイグレイ
  Color(0xFFADADAD), // パールグレイ
  Color(0xFFA0A0A0), // シルバーグレイ
  Color(0xFF939393), // アッシュグレイ
  Color(0xFF93848B), // ローズグレイ
  Color(0xFF797979), // グレイ
  Color(0xFF736C79), // スチールグレイ
  Color(0xFF56555E), // スレートグレイ
  Color(0xFF4E4854), // チャコールグレイ
  Color(0xFF1C1C1C), // ランプブラック
  Color(0xFF1C1C1C), // ブラック
];

const jisCommonColorNames = [
  'とき色',
  'つつじ色',
  '桜色',
  'ばら色',
  'からくれない',
  'さんご色',
  '紅梅(こうばい)色',
  '桃色',
  '紅色',
  '紅赤',
  'えんじ',
  '蘇芳(すおう)',
  '茜(あかね)色',
  '赤',
  '朱色',
  '紅樺(べにかば)色',
  '紅緋(べにひ)',
  '鉛丹(えんたん)色',
  '紅海老茶',
  'とび色',
  '小豆(あずき)色',
  '弁柄(べんがら)色',
  '海老茶',
  '金赤',
  '赤茶',
  '赤錆色',
  '黄丹(おうに)',
  '赤橙',
  '柿色',
  '肉桂(にっけい)色',
  '樺(かば)色',
  'れんが色',
  '錆色',
  '檜皮(ひわだ)色',
  '栗色',
  '黄赤',
  'たいしゃ',
  'らくだ色',
  '黄茶',
  '肌色',
  '橙色',
  '灰茶',
  '茶色',
  '焦茶',
  'こうじ色',
  '杏色',
  '蜜柑色',
  '褐色',
  '土色',
  '小麦色',
  'こはく色',
  '金茶',
  '卵色',
  '山吹色',
  '黄土色',
  '朽葉(くちば)色',
  'ひまわり色',
  'うこん色',
  '砂色',
  '芥子(からし)色',
  '黄色',
  'たんぽぽ色',
  '鶯茶',
  '中黄',
  '刈安(かりやす)色',
  'きはだ色',
  'みる色',
  'ひわ色',
  '鶯(うぐいす)色',
  '抹茶色',
  '黄緑',
  '苔色',
  '若草色',
  '萌黄(もえぎ)',
  '草色',
  '若葉色',
  '松葉色',
  '白緑(びゃくろく)',
  '緑',
  '常磐(ときわ)色',
  '緑青(ろくしょう)色',
  '千歳緑(ちとせみどり)',
  '深緑',
  'もえぎ色',
  '若竹色',
  '青磁色',
  '青竹色',
  '鉄色',
  '青緑',
  '錆浅葱',
  '水浅葱',
  '新橋色',
  '浅葱(あさぎ)色',
  '白群(びゃくぐん)',
  '納戸色',
  'かめのぞき',
  '水色',
  '藍鼠(あいねず)',
  '空色',
  '青',
  '藍色',
  '濃藍(こいあい)',
  '勿忘草(わすれなぐさ)色',
  '露草色',
  'はなだ色',
  '紺青(こんじょう)',
  'るり色',
  'るり紺',
  '紺色',
  'かきつばた色',
  '勝色(かちいろ)',
  '群青(ぐんじょう)色',
  '鉄紺',
  '藤納戸',
  'ききょう色',
  '紺藍',
  '藤色',
  '藤紫',
  '青紫',
  '菫(すみれ)色',
  '鳩羽(はとば)色',
  'しょうぶ色',
  '江戸紫',
  '紫',
  '古代紫',
  'なす紺',
  '紫紺',
  'あやめ色',
  '牡丹(ぼたん)色',
  '赤紫',
  '白',
  '胡粉(ごふん)色',
  '生成り(きなり)色',
  '象牙(ぞうげ)色',
  '銀鼠(ぎんねず)',
  '茶鼠',
  '鼠色',
  '利休鼠',
  '鉛色',
  '灰色',
  'すす竹色',
  '黒茶',
  '墨',
  '黒',
  '鉄黒',
  'ローズレッド',
  'ローズピンク',
  'コチニールレッド',
  'ルビーレッド',
  'ワインレッド',
  'バーガンディー',
  'オールドローズ',
  'ローズ',
  'ストロベリー',
  'コーラルレッド',
  'ピンク',
  'ボルドー',
  'ベビーピンク',
  'ポピーレッド',
  'シグナルレッド',
  'カーマイン',
  'レッド',
  'トマトレッド',
  'マルーン',
  'バーミリオン',
  'スカーレット',
  'テラコッタ',
  'サーモンピンク',
  'シェルピンク',
  'ネールピンク',
  'チャイニーズレッド',
  'キャロットオレンジ',
  'バーントシェンナ',
  'チョコレート',
  'ココアブラウン',
  'ピーチ',
  'ローシェンナ',
  'オレンジ',
  'ブラウン',
  'アプリコット',
  'タン',
  'マンダリンオレンジ',
  'コルク',
  'エクルベイジュ',
  'ゴールデンイエロー',
  'マリーゴールド',
  'バフ',
  'アンバー',
  'ブロンズ',
  'ベージュ',
  'イエローオーカー',
  'バーントアンバー',
  'セピア',
  'カーキー',
  'ブロンド',
  'ネープルスイエロー',
  'レグホーン',
  'ローアンバー',
  'クロムイエロー',
  'イエロー',
  'クリームイエロー',
  'ジョンブリアン',
  'カナリヤ',
  'オリーブドラブ',
  'オリーブ',
  'レモンイエロー',
  'オリーブグリーン',
  'シャトルーズグリーン',
  'リーフグリーン',
  'グラスグリーン',
  'シーグリーン',
  'アイビーグリーン',
  'アップルグリーン',
  'ミントグリーン',
  'グリーン',
  'コバルトグリーン',
  'エメラルドグリーン',
  'マラカイトグリーン',
  'ボトルグリーン',
  'フォレストグリーン',
  'ビリジアン',
  'ビリヤードグリーン',
  'ピーコックグリーン',
  'ナイルブルー',
  'ピーコックブルー',
  'ターコイズブルー',
  'マリンブルー',
  'ホリゾンブルー',
  'シアン',
  'スカイブルー',
  'セルリアンブルー',
  'ベビーブルー',
  'サックスブルー',
  'ブルー',
  'コバルトブルー',
  'アイアンブルー',
  'プルシャンブルー',
  'ミッドナイトブルー',
  'ヒヤシンス',
  'ネービーブルー',
  'ウルトラマリンブルー',
  'オリエンタルブルー',
  'ウィスタリア',
  'パンジー',
  'ヘリオトロープ',
  'バイオレット',
  'ラベンダー',
  'モーブ',
  'ライラック',
  'オーキッド',
  'パープル',
  'マゼンタ',
  'チェリーピンク',
  'ホワイト',
  'スノーホワイト',
  'アイボリー',
  'スカイグレイ',
  'パールグレイ',
  'シルバーグレイ',
  'アッシュグレイ',
  'ローズグレイ',
  'グレイ',
  'スチールグレイ',
  'スレートグレイ',
  'チャコールグレイ',
  'ランプブラック',
  'ブラック',
];
