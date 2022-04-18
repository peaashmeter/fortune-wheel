import 'dart:convert';
import 'dart:io';

import 'package:circle_sector/pie.dart';
import 'package:path_provider/path_provider.dart';

class Graph {
  late String title;
  late List<PieEntry> data;

  static Graph default_ =
      Graph('Название', const [PieEntry('Первый', 1), PieEntry('Второй', 2)]);

  Graph(this.title, this.data);
  Graph.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    data = List<PieEntry>.generate((json['data'] as List).length,
        (index) => PieEntry.fromJson((json['data'] as List)[index]));
  }

  Map<String, dynamic> get toJson => {
        'title': title,
        'data': List.generate(data.length, (index) => data[index].toJson)
      };

  Future<File> saveToCache() async {
    final dir = await getApplicationDocumentsDirectory();
    var file = File('${dir.path}/last.json');

    var json = jsonEncode(toJson);
    return file.writeAsString(json);
  }

  ///Returns a decoded json if success, otherwise returns null.
  static Future<Map<String, dynamic>?> loadJson() async {
    final dir = await getApplicationDocumentsDirectory();
    var file = File('${dir.path}/last.json');

    if (!await file.exists()) {
      await file.create();
    }

    var s = await file.readAsString();

    if (s.isEmpty) return null;

    try {
      return jsonDecode(s);
    } catch (e) {
      return null;
    }
  }
}
