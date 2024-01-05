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
  Widget build(BuildContext context) {
    if (choosePoem != null) {
      List<Widget> wgts = [];
      var title = choosePoem['title'];
      wgts.add(titleRow(title));
      var author = choosePoem['author'];
      wgts.add(authorRow(author));

      List<String> tags =
          choosePoem['tags'].map<String>((item) => item.toString()).toList();
      if (tags.isNotEmpty) {
        wgts.add(tagsRow(tags));
      }
      List<String> rows = [];
      for (int idx = 0; idx < choosePoem['paragraphs'].length; idx++) {
        var line = choosePoem['paragraphs'][idx];
        final sb = StringBuffer();
        for (var s in line.split("")) {
          sb.write(s);
          if (!checkPunctuate(s)) {
            rows.add(sb.toString());
            sb.clear();
          }
        }
        // wgts.add(wRow(rowIndex, choosePoem['paragraphs'][rowIndex]));
      }

      for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        wgts.add(wRow(rowIndex, rows[rowIndex], context));
      }
      final ctrler = ScrollController(initialScrollOffset: 0);
      return Scaffold(
        appBar: AppBar(
          title: const Text("拼拼古诗"),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 238, 234, 14),
        ),
        body: Column(children: <Widget>[
          Expanded(
            flex: 3,
            child: Scrollbar(
                controller: ctrler,
                scrollbarOrientation: ScrollbarOrientation.right,
                child: SingleChildScrollView(
                    controller: ctrler,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(8.0),
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

  Widget wRow(int rowIndex, String text, BuildContext context) {
    List<String> characters = text.split("");
    var targetVisibables = [];
    for (var c in characters) {
      targetVisibables.add(!checkPunctuate(c));
    }
    if (rowVisibables.length < rowIndex + 1) {
      rowVisibables.add(targetVisibables);
    }

    List<Widget> targetWidgets = [];
    var len = characters.length;
    for (int i = 0; i < len; i++) {
      if (checkPunctuate(characters[i])) {
        targetWidgets.add(DragTarget<String>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 40,
              height: 40,
              color: const Color.fromARGB(255, 243, 239, 239),
              alignment: Alignment.center,
              child: Visibility(
                  visible: rowVisibables[rowIndex][i],
                  child: Text(characters[i],
                      style: const TextStyle(fontSize: 30))),
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
              // print(rowVisibables);
              for (int r = 0; r < rowVisibables.length; r++) {
                for (int s = 0; s < rowVisibables[r].length; s++) {
                  if (!rowVisibables[r][s]) {
                    return;
                  }
                }
              }
              showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text("恭喜你"),
                      content: Text("拼接古诗成功！"),
                    );
                  });
            });
          },
        ));
      } else {
        targetWidgets
            .add(Text(characters[i], style: const TextStyle(fontSize: 30)));
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
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 3,
                    // children: [child, child, child, child, child],
                    children: targetWidgets))));
    return child;
  }

  Widget titleRow(String text) {
    // print(text.length);
    double w = 20.0 * text.length;
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
                    height: 25,
                    color: Color.fromARGB(255, 238, 240, 114),
                    alignment: Alignment.center,
                    child: Wrap(
                        spacing: 2,
                        //动态创建一个List<Widget>
                        children: text
                            .split("")
                            .map((e) => Text(
                                  e,
                                  style: const TextStyle(fontSize: 15),
                                ))
                            .toList())))));
  }

  Widget authorRow(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 60,
            height: 18,
            color: Color.fromARGB(255, 238, 240, 114),
            alignment: Alignment.center,
            child: Wrap(
                spacing: 2,
                //动态创建一个List<Widget>
                children: text
                    .split("")
                    .map((e) => Text(
                          e,
                          style: const TextStyle(fontSize: 10),
                        ))
                    .toList())),
        Tooltip(
            message: '看答案',
            child: TextButton(
              onPressed: () => {
                setState(() {
                  for (int i = 0; i < rowVisibables.length; i++) {
                    for (int j = 0; j < rowVisibables[i].length; j++) {
                      rowVisibables[i][j] = true;
                    }
                  }
                  pickCharacters.clear();
                })
              },
              child: const Icon(Icons.lightbulb_circle),
            ))
      ],
    );
  }

  Widget tagsRow(List<String> tags) {
    return Center(
        child: Wrap(
      spacing: 2,
      children: tags
          .map((t) => Chip(
              // labelPadding: const EdgeInsets.all(-1.0),
              // labelPadding:
              //     const EdgeInsets.only(left: 1, right: 1, top: 0, bottom: 0),
              // padding: const EdgeInsets.only(left: 1, right: 1, top: -10),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(t),
              labelStyle: const TextStyle(fontSize: 10)))
          .toList(),
    ));
  }

  Widget _pickArea() {
    final ctrler = ScrollController(initialScrollOffset: 0);
    List<Widget> wrap1children = [];
    List<Widget> wrap2children = [];
    for (int i = 0; i < pickCharacters.length; i++) {
      var c = pickCharacters[i];
      var drag = Draggable<String>(
        data: c,
        feedback: Container(
          // 拖拽时的显示
          width: 55,
          height: 55,
          color: const Color.fromARGB(255, 243, 239, 239).withOpacity(0.5),
          alignment: Alignment.center,
          child: Text(c, style: const TextStyle(fontSize: 45)),
        ), // 携带的数据
        child: Container(
          // 正常状态下的显示
          width: 45,
          height: 45,
          color: const Color.fromARGB(255, 243, 239, 239),
          alignment: Alignment.center,
          child: Text(
            c,
            style: const TextStyle(fontSize: 35),
          ),
        ),
      );
      if (i < pickCharacters.length / 2) {
        wrap1children.add(drag);
      } else {
        wrap2children.add(drag);
      }
    }
    return Expanded(
        flex: 1,
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.bottom,
          controller: ctrler,
          // 显示进度条
          child: SingleChildScrollView(
            controller: ctrler,
            scrollDirection: Axis.horizontal,
            // padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Wrap(
                    spacing: 3,
                    // runSpacing: 10,
                    //动态创建一个List<Widget>
                    children: wrap1children,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Wrap(
                      spacing: 3,
                      // runSpacing: 10,
                      //动态创建一个List<Widget>
                      children: wrap2children,
                    ))
              ],
            ),
          ),
        ));
  }
}
