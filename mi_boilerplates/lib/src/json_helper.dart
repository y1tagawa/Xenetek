// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

extension JsonHelper on Map<String, dynamic> {
  // 破壊的変更
  Map<String, dynamic> setBool(String key, bool? value) {
    this[key] = value;
    return this;
  }

  // bool?の取得もとりあえずこれで間に合わす
  bool? tryGetBool(String key) {
    final value = this[key];
    assert(value == null || value is bool);
    return value as bool?;
  }

  //
  bool getBool(String key) {
    final value = tryGetBool(key);
    assert(value != null);
    return value!;
  }

  bool getBoolOr(String key, bool or) {
    return tryGetBool(key) ?? or;
  }

  // containsKeyはそのまま使う
  //  int tryGetInt(String key);
}
