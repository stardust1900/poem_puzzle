import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '古诗拼图',
      home: Column(children: <Widget>[
        Expanded(
          flex: 3,
          child: Center(
            child: Column(
                children: [
              FittedBox(child: wRow("山行")),
              FittedBox(child: wRow("杜牧")),
              wRow('远上寒山石径斜'),
              wRow('白云深处有人家'),
              wRow('停车坐爱枫林晚'),
              wRow('霜叶红于二月花'),
            ]
                    .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: e,
                        ))
                    .toList()),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 30.0,
            color: Color.fromARGB(255, 226, 230, 231),
          ),
        ),
      ]),
    );
  }

  Widget wRow(String text) {
    List<String> characters = text.split("");
    int len = characters.length;
    Widget child;
    child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // children: [child, child, child, child, child],
        children: List<Widget>.generate(
            len,
            (i) => Container(
                  width: 80.0,
                  height: 80.0,
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: Text(characters[i]),
                )));
    return child;
  }
}
