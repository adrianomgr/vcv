import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';

class Detalhes extends StatefulWidget {
  final OcrText ocrText;

  Detalhes(this.ocrText);

  @override
  _DetalhesState createState() => new _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => _roubado());
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Detalhes do Veículo'),
      ),
      body: new ListView(
        children: <Widget>[
          new ListTile(
            title: new Text(widget.ocrText.value),
            subtitle: const Text('Placa do Veículo'),
          ),
        ],
      ),
    );
  }
  void _roubado(){
    roubado(context).then((bool value) {
      print ("valor foi $value");
    });
  }
}



Future<bool> roubado(context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Rewind and remember'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('You will never be satisfied.'),
              Text('You\’re like me. I’m never satisfied.'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Regret'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}