import 'package:flutter/material.dart';

import 'graph.dart';
import 'pie.dart';

void main() async {
  //loading the last graph from cache

  WidgetsFlutterBinding.ensureInitialized();

  var json = await Graph.loadJson();
  late Graph graph;

  if (json == null) {
    graph = Graph.default_;
  } else {
    graph = Graph.fromJson(json);
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Рулетка',
    theme: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.red, backgroundColor: Colors.white)),
    home: PiePage(graph),
  ));
}
