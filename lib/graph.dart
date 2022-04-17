import 'package:circle_sector/pie.dart';

class Graph {
  late String title;
  late List<PieEntry> data;

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
}
