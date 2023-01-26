// Copyright 2022 Xenetek. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mi_boilerplates/mi_boilerplates.dart' as mi;

import 'ex_app_bar.dart' as ex;

//
// Layered architecture example
//

//
// Repository
//

//
// View state
//

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

//
// Service logic
//

class SampleService extends StateNotifier<SampleState> {
  static final _instance = SampleService._();

  factory SampleService.instance() => _instance;

  void plusOne() {
    _instance.state = _instance.state.copyWith(
      value: _instance.state.value + 1,
    );
  }

  SampleService._() : super(const SampleState(value: 0));
}

final _sampleServiceProvider =
    StateNotifierProvider<SampleService, SampleState>((ref) => SampleService.instance());

//
// View
//

class LayeredArchitecturePage extends ConsumerWidget {
  static const icon = Icon(Icons.layers_outlined);
  static const title = Text('Layered architecture');

  static final _logger = Logger((LayeredArchitecturePage).toString());

  const LayeredArchitecturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.fine('[i] build');

    final enabled = ref.watch(ex.enableActionsProvider);

    final value = ref.watch(_sampleServiceProvider).value;

    return ex.Scaffold(
      appBar: ex.AppBar(
        prominent: ref.watch(ex.prominentProvider),
        icon: icon,
        title: title,
      ),
      body: Column(
        children: [
          Text(value.toString()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SampleService.instance().plusOne(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const ex.BottomNavigationBar(),
    ).also((_) {
      _logger.fine('[o] build');
    });
  }
}
