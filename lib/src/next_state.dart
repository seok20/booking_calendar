import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NextStatePage extends StatefulWidget {
  final DateTime data;
  const NextStatePage({Key? key, required this.data}) : super(key: key);


  @override
  State<NextStatePage> createState() => _NextStatePageState();
}

class _NextStatePageState extends State<NextStatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('다음 화면'),
      ),
      body: Center(
        child: Text('data is ${widget.data}'),
      ),
    );
  }
}
