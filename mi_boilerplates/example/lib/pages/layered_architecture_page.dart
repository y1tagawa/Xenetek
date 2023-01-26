// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;

//
// Layered architecture example
//

// インフラストラクチャ層
//
// （しばしば非同期的にしかアクセスできない）リソースへのAPI。
// データベースやデバイス、ネットワークリソースなど。

late int _lastValue;

// 非同期的な初期化
Future<void> _initValue() async {
  _lastValue = 0;
}

Future<int> _nextValue() async {
  return _lastValue++;
}

/// View state
///
/// ドメインとビュー間のプロトコル。
class SampleState {
  final int value;

//<editor-fold desc="Data Methods">

  const SampleState({
    required this.value,
  });

//TOD@override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SampleState && runtimeType == other.runtimeType && value == other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'SampleState{' + ' value: $value,' + '}';
  }

  SampleState copyWith({
    int? value,
  }) {
    return SampleState(
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': this.value,
    };
  }

  factory SampleState.fromMap(Map<String, dynamic> map) {
    return SampleState(
      value: map['value'] as int,
    );
  }

  //</editor-fold>
}

// ドメイン層
//
// サービスロジックの群れ。
// インフラストラクチャと通信するため、やっぱり非同期になる。

class SampleService {
  static SampleService _createInstance() {
    final valueStream = StreamController<int>();
    final provider = StreamProvider<SampleState>(
      (ref) async* {
        // 非同期的にリソースを初期化し...
        await _initValue();
        // 必要なら初期状態をゲットしてリスナに通知
        valueStream.add(await _nextValue());
        // 以後状態が変わるごとにリスナに通知
        // TODO: 自動的に値が変わる場合(カメラ画像とか)
        await for (final value in valueStream.stream) {
          yield SampleState(value: value);
        }
      },
    );
    return SampleService._(
      valueStream: valueStream,
      provider: provider,
    );
  }

  static final _instance = _createInstance();

  static SampleService get instance => _instance;

  final StreamController<int> _valueStream;
  final StreamProvider<SampleState> provider;

  const SampleService._({
    required valueStream,
    required this.provider,
  }) : _valueStream = valueStream;

  // 次の値を要求
  Future<bool> requestNextValue() async {
    _valueStream.sink.add(await _nextValue());
    return true; // OK
  }
}

// プレゼンテーション層
//
// ビューの群れ。

class LayeredArchitecturePage extends ConsumerWidget {
  static const icon = Icon(Icons.layers_outlined);
  static const title = Text('Layered architecture');

  static final _logger = Logger((LayeredArchitecturePage).toString());

  const LayeredArchitecturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    final value = ref.watch(SampleService.instance.provider);

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: Center(
        child: value.when(
          data: (data) {
            return Text(data.value.toString());
          },
          error: (error, _) => Text(error.toString()),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 非同期的にサービスロジックを呼び出す。
          await SampleService.instance.requestNextValue();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
