import 'package:flutter/material.dart';

import 'pie.dart';

void main() {
  runApp(MaterialApp(
    title: 'Рулетка',
    theme: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.red, backgroundColor: Colors.white)),
    home: const PiePage(
        [PieEntry('Первый', 1), PieEntry('Второй', 2), PieEntry('Третий', 3)]),
  ));
}
