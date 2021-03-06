//Copyright 2020 Pedro Bissonho
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import 'package:fast/commands/flutter/create_flutter_comand.dart';
import 'package:fast/core/action.dart';
import 'package:fast/core/process_extension.dart';

class CreaterFlutterAction implements Action {
  final String path;
  final FlutterAppArgs flutterProjectArgs;
  final FastProcess process;

  CreaterFlutterAction(this.path, this.flutterProjectArgs, this.process);

  @override
  Future<void> execute() async {
    var args = ['create', '--no-pub'];
    if (flutterProjectArgs.useKotlin) args.addAll(['-a', 'kotlin']);
    if (flutterProjectArgs.useSwift) args.addAll(['-i', 'swift']);
    if (flutterProjectArgs.useAndroidX) args.add('--androidx');

    args.addAll([
      '--project-name',
      flutterProjectArgs.name,
      '--description',
      flutterProjectArgs.description
    ]);

    args.add(path);
    await process.executeProcessShellPath('flutter', args, path);
  }

  @override
  String get actionName => 'Create flutter app.';
}
