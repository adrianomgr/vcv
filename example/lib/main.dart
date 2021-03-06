import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:flutter_mobile_vision_example/ocr_text_detail.dart';

import 'package:flutter/services.dart';
import 'package:location/location.dart';

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
  var txt = new TextEditingController();
  @override
  void initState() {
    super.initState();
    initPlatformState();

    _locationSubscription =
        _location.onLocationChanged().listen((Map<String,double> result) {
          setState(() {
            _currentLocation = result;
          });
        });
  }
  initPlatformState() async {
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      _permission = await _location.hasPermission();
      location = await _location.getLocation();


      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;

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
      home: new DefaultTabController(
        length: 3,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text('Vigilância Cidadã de Veículos'),
          ),
          body: _getOcrScreen(context),
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
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Container(
                height: 60.0,
                child: RaisedButton(
                  onPressed: () {
                  },
                  child: Text("CONSULTAR",
                      style: TextStyle(color: Colors.white, fontSize: 25.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // items.addAll(
    //   ListTile.divideTiles(
    //     context: context,
    //     tiles: _textsOcr
    //         .map(
    //           (ocrText) => new OcrTextWidget(ocrText),
    //         )
    //         .toList(),
    //   ),
    // );
    items.add(new Center(
        child: new Text(_startLocation != null
            ? 'Start location: $_startLocation\n'
            : 'Error: $error\n')));
            

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
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        flash: _torchOcr,
        autoFocus: _autoFocusOcr,
        multiple: _multipleOcr,
        showText: _showTextOcr,
        camera: _cameraOcr,
        fps: 2.0,
      );
    } on Exception {
      texts.add(new OcrText('Nenhuma Placa foi detectada.'));
    }

    if (!mounted) return;    
      setState(() {
        _textsOcr = texts;
        txt.text = texts.first.value;

      });
  }
}

///
/// OcrTextWidget
///
class OcrTextWidget extends StatelessWidget {
  final OcrText ocrText;

  OcrTextWidget(this.ocrText);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: const Icon(Icons.title),
      title: new Text(ocrText.value),
      subtitle: new Text(ocrText.language),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) => new OcrTextDetail(ocrText),
            ),
          ),
    );
  }
}
