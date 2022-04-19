import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'graph.dart';
import 'pie.dart';

class SetupPage extends StatefulWidget {
  final Graph graph;
  // final List<PieEntry> data;
  // final String title;
  const SetupPage(this.graph, {Key? key}) : super(key: key);

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late TextEditingController titleController;
  late DataModel data;

  @override
  void initState() {
    titleController = TextEditingController(text: widget.graph.title);
    data = DataModel(List.from(widget.graph.data));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        return false;
      },
      child: ChangeNotifierProvider(
        create: (context) => data,
        child: Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: titleController,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
              cursorColor: Colors.white,
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    var graph = Graph(titleController.text, data.entries);
                    await graph.saveToCache();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PiePage(graph),
                        ));
                  },
                  icon: const Icon(Icons.pie_chart))
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: height / 3,
                  child: Center(
                    child: Consumer<DataModel>(builder: (context, data, child) {
                      print(1);
                      return CustomPaint(
                        painter: ChartPainter(
                          height / 3.2,
                          List.from(data.entries),
                        ),
                      );
                    }),
                  ),
                ),
                Consumer<DataModel>(builder: (context, data, child) {
                  print(2);
                  return SetupForm(data);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SetupForm extends StatefulWidget {
  final DataModel data;
  const SetupForm(this.data, {Key? key}) : super(key: key);

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  late ControllersModel controllers;

  @override
  void initState() {
    var _controllers = List.generate(
        widget.data.entries.length,
        (index) => ControllerWrapper(
            TextEditingController(text: widget.data.getTitleByIndex(index)),
            TextEditingController(
                text: widget.data.getValueByIndex(index).toStringAsFixed(0))));
    controllers = ControllersModel(_controllers);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 2,
        child: ListView.builder(
          controller: ScrollController(initialScrollOffset: 1),
          itemCount: widget.data.entries.length + 1,
          itemBuilder: (context, index) => index < widget.data.entries.length
              ? FormEntry(index, widget.data, controllers)
              : IconButton(
                  onPressed: () {
                    widget.data.addBlank();
                    controllers.addController(
                        widget.data.entries.length - 1,
                        ControllerWrapper(TextEditingController(text: ''),
                            TextEditingController(text: '1')));
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                    color: Colors.red,
                    size: 32,
                  )),
        ));
  }
}

class ControllerWrapper {
  final TextEditingController titleController;
  final TextEditingController valueController;

  const ControllerWrapper(this.titleController, this.valueController);
}

class ControllersModel {
  final List<ControllerWrapper> _controllers;

  ControllersModel(this._controllers);

  UnmodifiableListView<ControllerWrapper> get controllers =>
      UnmodifiableListView(_controllers);

  void deleteController(int index) {
    _controllers.removeAt(index);
  }

  void addController(int index, ControllerWrapper controller) {
    _controllers.insert(index, controller);
  }
}

class FormEntry extends StatelessWidget {
  final int index;
  final DataModel data;
  final ControllersModel controllers;
  const FormEntry(this.index, this.data, this.controllers, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var titleController = controllers.controllers[index].titleController;
    var valueController = controllers.controllers[index].valueController;

    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Focus(
                onFocusChange: (focus) {
                  if (!focus) {
                    data.setEntry(
                        index,
                        PieEntry(
                            titleController.text, data.getValueByIndex(index)));
                  }
                },
                child: TextField(
                  controller: titleController,
                  onSubmitted: (text) {
                    data.setEntry(
                        index, PieEntry(text, data.getValueByIndex(index)));
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            )),
        Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Focus(
                onFocusChange: (focus) {
                  if (!focus) {
                    if (double.tryParse(valueController.text) != null) {
                      data.setEntry(
                          index,
                          PieEntry(titleController.text,
                              double.tryParse(valueController.text)));
                    } else {
                      valueController.text =
                          data.getValueByIndex(index).toStringAsFixed(0);
                    }
                  }
                },
                child: TextField(
                  controller: valueController,
                  onSubmitted: (text) {
                    if (double.tryParse(text) != null) {
                      data.setEntry(
                          index,
                          PieEntry(
                              titleController.text, double.tryParse(text)));
                    } else {
                      valueController.text =
                          data.getValueByIndex(index).toStringAsFixed(0);
                    }
                  },
                  keyboardType: TextInputType.number,
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              onPressed: () {
                data.deleteEntry(index);
                controllers.deleteController(index);
              },
              icon: const Icon(Icons.delete)),
        )
      ],
    );
  }
}
