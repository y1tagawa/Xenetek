// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart';

void main() {
  test('scope functions test.', () {
    expect(run(() => 8), 8);
    expect(8.also((_) => 9), 8);
    expect(8.let((it) => it + 1), 9);
  });
}
