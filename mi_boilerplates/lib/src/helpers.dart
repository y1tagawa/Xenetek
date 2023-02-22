// Copyright 2023 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

Iterable<int> iota(int n, {int start = 0}) => Iterable<int>.generate(n, (i) => i + start);

//
// Scope function alternatives.
//

T run<T>(T Function() fun) => fun();

extension ScopeFunctions<T> on T {
  T also(void Function(T it) fun) {
    fun(this);
    return this;
  }

  U let<U>(U Function(T it) fun) => fun(this);
}

//
// Container extensions.
//

extension IterableHelper<T> on Iterable<T> {
  List<T> sorted({int Function<T>(T a, T b)? compare}) {
    final t = toList();
    t.sort(compare);
    return t;
  }
}

extension ListHelper<T> on List<T> {
  List<T> added(T value) {
    final t = toList();
    t.add(value);
    return t;
  }

  List<T> moved(int oldIndex, int newIndex) {
    final t = toList();
    t.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, t.removeAt(oldIndex));
    return t;
  }

  List<T> removed(T value) {
    final t = toList();
    t.remove(value);
    return t;
  }

  List<T> removedAt(int index) {
    final t = toList();
    t.removeAt(index);
    return t;
  }

  List<T> replacedAt(int index, T value) {
    final t = toList();
    t[index] = value;
    return t;
  }
}

extension SetHelper<T> on Set<T> {
  Set<T> added(T value) {
    final t = toSet();
    t.add(value);
    return t;
  }

  Set<T> removed(T value) {
    final t = toSet();
    t.remove(value);
    return t;
  }
}
