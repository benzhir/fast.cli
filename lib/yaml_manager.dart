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
import 'package:yaml/yaml.dart';
import 'core/exceptions.dart';
import 'yaml_reader.dart';

class YamlScaffoldKeys {
  static String commandsKey = 'commands';
  static String structureKey = 'structure';
  static String testStructureKey = 'test_structure';
  static String dependenciesKey = 'dependencies';
  static String dev_dependenciesKey = 'dev_dependencies';
}

class YamlCommand {
  final String key;
  final String command;

  YamlCommand(this.key, this.command);
}

class Dependency {
  final String name;
  String version;

  Dependency(this.name, [this.version]) {
    version ??= '';
  }
}

class YamlDependencies {
  static List<Dependency> readDependencies(String key, YamlReader reader) {
    var yamldata = reader.reader();
    var dependencies = <Dependency>[];
    var dependenciesData = yamldata[key] as Map;
    dependenciesData.forEach((key, comand) {
      dependencies.add(Dependency(key, comand));
    });

    return dependencies;
  }
}

class Structure {
  final List data;
  var mainFolder = Folder('src');

  void createStructure(dynamic data, Folder parent) {
    if (data is YamlList) {
      data.forEach((folderName) {
        createStructure(folderName, parent);
      });
    }

    if (data is YamlMap) {
      data.forEach((key, childData) {
        var folder = Folder(key);
        parent.addSubFolder(folder);
        createStructure(childData, folder);
      });
    }

    // parent.add(Folder(data));

    if (data is String) {
      var splited = data.split('.');

      if (splited.length == 1) {
        parent.addSubFolder(Folder(data));
      } else {
        parent.addFile(YamlFile(data));
      }
    }
  }

  Structure(this.data) {
    createStructure(data, mainFolder);
  }
}

class Folder {
  final String name;
  List<Folder> subFolders = <Folder>[];
  List<YamlFile> files = <YamlFile>[];

  Folder(this.name);

  void addSubFolder(Folder folder) {
    subFolders.add(folder);
  }

  void addFile(YamlFile file) {
    files.add(file);
  }
}

class YamlFile {
  final String name;
  final String content;
  final String extension;

  YamlFile(this.name, {this.content, this.extension});
}

class Template {
  final String name;
  final String description;
  final String to;
  final List<String> args;

  Template({this.description, this.name, this.to, this.args});
}

class Scaffold {
  final Structure structure;
  final Structure testStructure;

  Scaffold({this.structure, this.testStructure});
}

class YamlManager {
  static List<Template> loadTemplates(String folder) {
    var templates = <Template>[];

    var dir = Directory(folder);
    dir.listSync().forEach((element) {
      templates
          .add(YamlTemplateReader('${element.path}/template.yaml').reader());
    });

    return templates;
  }

  static List<Scaffold> loadScaffolds(String folder) {
    var Scaffolds = <Scaffold>[];

    var dir = Directory(folder);
    dir.listSync().forEach((element) {
      var Scaffold = readerYamlScaffoldFile('${element.path}/scaffold.yaml');
      Scaffolds.add(Scaffold);
    });

    return Scaffolds;
  }

  static Scaffold loadScaffold(String folderPath) {
    Scaffold scaffold;
    var dir = Directory(folderPath);
    scaffold = readerYamlScaffoldFile('${dir.path}/scaffold.yaml');
    return scaffold;
  }

  static List<YamlCommand> readerYamlCommandsFile(String yamlPath) {
    var yamlCommands = <YamlCommand>[];
    var reader = YamlReader(yamlPath);
    var yamldata = reader.reader();
    var yamlCommandsData = yamldata[YamlScaffoldKeys.commandsKey] as Map;
    yamlCommandsData.forEach((key, comand) {
      yamlCommands.add(YamlCommand(key, comand));
    });

    return yamlCommands;
  }

  static Scaffold readerYamlScaffoldFile(String yamlPath) {
    var reader = YamlReader(yamlPath);
    dynamic structureData;
    var yamldata = reader.reader();

    structureData = yamldata[YamlScaffoldKeys.structureKey];
    var structure = Structure(structureData);

    var testStructureData = yamldata[YamlScaffoldKeys.testStructureKey];
    var testStructure = Structure(testStructureData);

    return Scaffold(
      structure: structure,
      testStructure: testStructure,
    );
  }
}

class YamlTemplateReader {
  final String path;
  YamlReader yamlReader;

  YamlTemplateReader(this.path) {
    yamlReader = YamlReader(path);
  }

  Template reader() {
    try {
      var yamlData = yamlReader.reader();
      var args =
          (yamlData['args'] as YamlList).map((value) => '$value').toList();
      return Template(
        name: yamlData['name'],
        to: yamlData['to'],
        args: args,
        description: yamlData['description'],
      );
    } catch (error) {
      throw FastException('''
An error occurred while reading the template $path's file.
Check that the yaml file has been written correctly.
Error: $error
      ''');
    }
  }
}
