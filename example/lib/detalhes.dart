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
          new ListTile(
            title: new Text(widget.ocrText.isroubado.toString()),
            subtitle: const Text('Status'),
          ),
          new ListTile(
            title: new Text(widget.ocrText.modelo),
            subtitle: const Text('Modelo'),
          ),
          new ListTile(
            title: new Text(widget.ocrText.latitude.toString()),
            subtitle: const Text('Latitude'),
          ),
          new ListTile(
            title: new Text(widget.ocrText.longitude.toString()),
            subtitle: const Text('Longitude'),
          ),
        ],
      ),
    );
  }
}
