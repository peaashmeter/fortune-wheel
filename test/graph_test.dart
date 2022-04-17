import 'dart:convert';

import 'package:circle_sector/pie.dart';
import 'package:test/test.dart';
import 'package:circle_sector/graph.dart';

void main() {
  group('Graph', () {
    var g =
        Graph('MyGraph', const [PieEntry('First', 1), PieEntry('Second', 2)]);
    test('Encoding a graph object into json', () {
      expect(jsonEncode(g.toJson).runtimeType, String);
    });

    test('Decoding json into a map', () {
      expect(jsonDecode(json.encode(g.toJson)), isA<Map>());
    });

    test('Decoding a pieEntry', () {
      var json = {'title': 'First', 'value': 1.0};
      expect(PieEntry.fromJson(json), isA<PieEntry>());
    });

    test('Creating a graph from a map', () {
      var decoded = jsonDecode(json.encode(g.toJson));
      print(decoded);
      expect(Graph.fromJson(decoded), isA<Graph>());
    });
  });
}
