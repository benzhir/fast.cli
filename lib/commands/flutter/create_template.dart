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

import 'dart:io';

import 'package:fast/actions/create_template.dart';
import '../../yaml_manager.dart';
import '../command_base.dart';

import 'package:fast/core/directory/directory.dart';

class CreateTemplateCommand extends CommandBase {
  final String templateYamlPath;
  final String templateFolderPath;
  final Template template;

  @override
  String get description => template.description;

  @override
  String get name => template.name;

  CreateTemplateCommand(
      {this.templateYamlPath, this.templateFolderPath, this.template}) {
    template.args.forEach((arg) {
      argParser.addOption(arg);
    });
  }

  @override
  Future<void> run() async {
    var argsMap = <String, String>{};

    template.args.forEach((arg) {
      var argresult = argResults[arg];

      if (argresult != null) {
        argsMap[arg] = argresult;
      }
    });

    var createTamplateAction =
        CreateTemplateAction(template, templateFolderPath, argsMap);
    await createTamplateAction.execute();

    var directory =
        Directory(replacerFile(template.to, createReplacers(argsMap)));
    await directory.createRecursive();

    createTamplateAction.templateFiles.forEach((f) {
      if (f.extension.toLowerCase() != '.yaml') {
        var file = File('${directory.path}/${f.name}');
        file.writeAsString(f.content);
      }
    });
  }
}
