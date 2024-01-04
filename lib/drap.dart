import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('DragTarget 示例')),
        body: const Center(
          child: DragDemo(),
        ),
      ),
    );
  }
}

class DragDemo extends StatefulWidget {
  const DragDemo({super.key});

  @override
  _DragDemoState createState() => _DragDemoState();
}

class _DragDemoState extends State<DragDemo> {
// 存储可拖拽的颜色列表
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
// 创建一个 DragTarget，用于接收拖拽过来的颜色
        DragTarget<Color>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: 200,
              height: 200,
              color: Colors.grey,
              alignment: Alignment.center,
              child: const Text(
                '拖拽到这里删除',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            );
          },
// 当拖拽进入时，判断是否接受
          onWillAccept: (color) {
            return true; // 接受任何颜色
          },
// 当拖拽完成时，执行删除操作
          onAccept: (color) {
            setState(() {
              _colors.remove(color); // 从颜色列表中移除该颜色
            });
          },
        ),
// 创建一个 Wrap，用于显示可拖拽的颜色
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _colors.map((color) {
            return Draggable<Color>(
              data: color,
              feedback: Container(
// 拖拽时的显示
                width: 50,
                height: 50,
                color: color.withOpacity(0.5),
              ), // 携带的数据
              child: Container(
// 正常状态下的显示
                width: 50,
                height: 50,
                color: color,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
