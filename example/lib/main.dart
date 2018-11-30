import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:flutter_mobile_vision_example/detalhes.dart';

import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;

  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();
  bool _permission = false;
  String error;
  Image image1;

  bool currentWidget = true;

  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = false;
  bool _showTextOcr = true;
  List<OcrText> _textsOcr = [];
  Uint8List _image = null;
  var txt = new TextEditingController();
  @override
  void initState() {
    super.initState();
    initPlatformState();

    _locationSubscription =
        _location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        _currentLocation = result;
      });
    });
  }

  initPlatformState() async {
    Map<String, double> location;

    try {
      _permission = await _location.hasPermission();
      location = await _location.getLocation();

      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    setState(() {
      _startLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.green,
        buttonColor: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: new DefaultTabController(
        length: 3,
        child: new Scaffold(
          appBar: new AppBar(
            bottom: new TabBar(
              indicatorColor: Colors.black54,
              tabs: [
                new Tab(text: 'Consulta da Placa'),
                new Tab(text: 'Comunicar Furto'),
                new Tab(text: 'teste'),
              ],
            ),
            title: new Text('Vigilância Cidadã de Veículos'),
          ),
          body: new TabBarView(children: [
            _getOcrScreen(context),
            _comunicarFurto(context),
            _dados(context),
          ]),
        ),
      ),
    );
  }

  ///
  /// OCR Screen
  ///
  Widget _getOcrScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(
      new SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: IconButton(
                  padding: EdgeInsets.only(bottom: 100.0),
                  icon: Icon(Icons.linked_camera,
                      size: 120.0, color: Colors.green),
                  onPressed: _read),
            ),
            TextField(
              controller: txt,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: "Placa do Veículo"),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25.0, color: Colors.black),
            ),
          ],
        ),
      ),
    );

    items.add(new Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        height: 60.0,
        child: RaisedButton(
          onPressed: () {},
          child: Text("CONSULTAR",
              style: TextStyle(color: Colors.white, fontSize: 25.0)),
        ),
      ),
    ),
    );

    if(_image != null) items.add(new Image.memory(_image, height: 99.9));

    return new ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  ///
  /// OCR Method
  ///
  Future<Null> _read() async {
    Capture capture;
    List<OcrText> texts = [];
    Uint8List img = null;
    try {
      capture = await FlutterMobileVision.read(
        flash: _torchOcr,
        autoFocus: _autoFocusOcr,
        multiple: _multipleOcr,
        showText: _showTextOcr,
        camera: _cameraOcr,
        fps: 2.0,
      );
      texts = await capture.textList;
      img = await capture.image;
    } on Exception {
      texts.add(new OcrText(txt.text));
    }
    if (!mounted) return;
    setState(() {
      _textsOcr = texts;
      _image = img;
      txt.text = texts.last.value;
    });
  }
}


  ///
  /// Comunicar Furto
  ///
Widget _comunicarFurto(BuildContext context) {
  List<Widget> items = [];

  items.add(
    new SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: "Placa do Veículo"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25.0, color: Colors.black),
          ),
          new Padding(
            padding: EdgeInsets.all(20.0),
            child: Container(
              height: 60.0,
              child: RaisedButton(
                onPressed: () {},
                child: Text("Informar Furto",
                    style: TextStyle(color: Colors.white, fontSize: 25.0)),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  return new ListView(
    padding: const EdgeInsets.only(
      top: 12.0,
    ),
    children: items,
  );
}

Widget _dados(BuildContext context) {
  return new StreamBuilder(
      stream: Firestore.instance.collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return new ListView.builder(
            itemCount: snapshot.data.documents.length,
            padding: const EdgeInsets.only(top: 10.0),
            itemExtent: 25.0,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.documents[index];
              return new Text(" ${ds['plate']} ${ds['model']}");
            });
      });
}
