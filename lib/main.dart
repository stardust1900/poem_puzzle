import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MainApp());
  // runApp(const MyApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '古诗拼图',
      home: PoemHomePage(),
    );
  }
}

class PoemHomePage extends StatefulWidget {
  const PoemHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _PoemHomePageState();
}

class _PoemHomePageState extends State<PoemHomePage> {
  List<String> characters = [];

  var poemJson;

  var choosePoem;

  var rowVisibables = [];
  List<String> pickCharacters = [];
  @override
  void initState() {
    // int rInt;
    rootBundle.loadString('asset/datas/poem.json').then((res) => {
          poemJson = jsonDecode(res),
          setState(() {
            choosePoem = poemJson[Random().nextInt(poemJson.length)];
            for (var p in choosePoem['paragraphs']) {
              for (var c in p.split("")) {
                if (checkPunctuate(c)) {
                  pickCharacters.add(c);
                }
              }
            }
            pickCharacters.shuffle();
          })
        });

    super.initState();
  }

  //检查是不是标点符号
  bool checkPunctuate(String s) {
    return s != '，' && s != '。' && s != '？' && s != '！';
  }

  @override
  Widget build(Object context) {
    if (choosePoem != null) {
      List<Widget> wgts = [];
      var title = choosePoem['title'];
      wgts.add(titleRow(title));
      var author = choosePoem['author'];
      wgts.add(authorRow(author));
      for (int rowIndex = 0;
          rowIndex < choosePoem['paragraphs'].length;
          rowIndex++) {
        wgts.add(wRow(rowIndex, choosePoem['paragraphs'][rowIndex]));
      }
      final ctrler = ScrollController(initialScrollOffset: 0);
      return Scaffold(
        body: Column(children: <Widget>[
          Expanded(
            flex: 3,
            child: Scrollbar(
                controller: ctrler,
                scrollbarOrientation: ScrollbarOrientation.right,
                child: SingleChildScrollView(
                    controller: ctrler,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Wrap(
                          children: wgts
                              .map((e) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 1),
                                    child: e,
                                  ))
                              .toList()),
                    ))),
          ),
          _pickArea(),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {
            setState(() {
              pickCharacters.clear();
              choosePoem = poemJson[Random().nextInt(poemJson.length)];
              for (var p in choosePoem['paragraphs']) {
                for (var c in p.split("")) {
                  if (checkPunctuate(c)) {
                    pickCharacters.add(c);
                  }
                }
              }
              pickCharacters.shuffle();
              rowVisibables.clear();
            })
          },
          tooltip: '换一首',
          child: const Icon(Icons.refresh),
        ),
      );
    } else {
      return const Icon(Icons.home);
    }
  }

  Widget wRow(int rowIndex, String text) {
    List<String> characters = text.split("");
    var targetVisibables = [];
    for (var c in characters) {
      targetVisibables.add(!checkPunctuate(c));
    }
    rowVisibables.add(targetVisibables);
    List<Widget> targetWidgets = [];
    var len = characters.length;
    for (int i = 0; i < len; i++) {
      if (checkPunctuate(characters[i])) {
        targetWidgets.add(DragTarget<String>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 60,
              height: 60,
              color: const Color.fromARGB(255, 243, 239, 239),
              alignment: Alignment.center,
              child: Visibility(
                  visible: rowVisibables[rowIndex][i],
                  child: Text(characters[i],
                      style: const TextStyle(fontSize: 35))),
            );
          },
          // 当拖拽进入时，判断是否接受
          onWillAccept: (c) {
            return !rowVisibables[rowIndex][i] && c == characters[i];
          },
          // 当拖拽完成时，执行删除操作
          onAccept: (c) {
            setState(() {
              // print('rowIndex:$rowIndex i:$i');
              rowVisibables[rowIndex][i] = true;
              pickCharacters.remove(c);
            });
          },
        ));
      } else {
        targetWidgets
            .add(Text(characters[i], style: const TextStyle(fontSize: 35)));
      }
    }

    Widget child;
    final ctrler = ScrollController(initialScrollOffset: 0);
    child = Scrollbar(
        scrollbarOrientation: ScrollbarOrientation.bottom,
        controller: ctrler,
        // 显示进度条
        child: Center(
            child: SingleChildScrollView(
                controller: ctrler,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    // children: [child, child, child, child, child],
                    children: targetWidgets))));
    return child;
  }

  Widget titleRow(String text) {
    // print(text.length);
    double w = 70.0 * text.length;
    final ctrler = ScrollController(initialScrollOffset: 0);
    return Scrollbar(
        scrollbarOrientation: ScrollbarOrientation.bottom,
        controller: ctrler,
        // 显示进度条
        child: Center(
            child: SingleChildScrollView(
                controller: ctrler,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: Container(
                    width: w,
                    height: 80,
                    color: Color.fromARGB(255, 238, 240, 114),
                    alignment: Alignment.center,
                    child: Wrap(
                        spacing: 10,
                        //动态创建一个List<Widget>
                        children: text
                            .split("")
                            .map((e) => Text(
                                  e,
                                  style: const TextStyle(fontSize: 35),
                                ))
                            .toList())))));
  }

  Widget authorRow(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 100,
            height: 80,
            color: Color.fromARGB(255, 238, 240, 114),
            alignment: Alignment.center,
            child: Wrap(
                spacing: 10,
                //动态创建一个List<Widget>
                children: text
                    .split("")
                    .map((e) => Text(
                          e,
                          style: const TextStyle(fontSize: 20),
                        ))
                    .toList()))
      ],
    );
  }

  Widget _pickArea() {
    final ctrler = ScrollController(initialScrollOffset: 0);
    return Expanded(
        flex: 1,
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.bottom,
          controller: ctrler,
          // 显示进度条
          child: SingleChildScrollView(
            controller: ctrler,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Wrap(
                spacing: 10,
                //动态创建一个List<Widget>
                children: pickCharacters
                    //每一个字母都用一个Text显示,字体为原来的两倍
                    .map((c) => Draggable<String>(
                          data: c,
                          feedback: Container(
                            // 拖拽时的显示
                            width: 80,
                            height: 80,
                            color: const Color.fromARGB(255, 243, 239, 239)
                                .withOpacity(0.5),
                            alignment: Alignment.center,
                            child: Text(c),
                          ), // 携带的数据
                          child: Container(
                            // 正常状态下的显示
                            width: 80,
                            height: 80,
                            color: const Color.fromARGB(255, 243, 239, 239),
                            alignment: Alignment.center,
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 35),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ));
  }
}
