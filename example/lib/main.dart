import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:flutter_mobile_vision_example/ocr_text_detail.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = false;
  bool _showTextOcr = true;
  List<OcrText> _textsOcr = [];

  @override
  void initState() {
    super.initState();
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
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(Icons.linked_camera, size: 120.0, color: Colors.green),
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Placa do Veículo"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25.0),
            // _getOcrScreen(context)
                  ),
                  Container(
                    height:60.0,
                    child: RaisedButton(
                      onPressed: (  ) {},
                      child: Text("CONSULTAR", style: TextStyle(color: Colors.white, fontSize: 25.0)),
                    )
                  )
                  
                ])
            ),
      ),
    );
  }

  ///
  /// OCR Screen
  ///
  Widget _getOcrScreen(BuildContext context) {
    List<Widget> items = [];

    // items.add(new Padding(
    //   padding: const EdgeInsets.only(
    //     top: 8.0,
    //     left: 18.0,
    //     right: 18.0,
    //   ),
    //   child: const Text('Camera:'),
    // ));

    // items.add(new Padding(
    //   padding: const EdgeInsets.only(
    //     left: 18.0,
    //     right: 18.0,
    //   ),
    //   child: new DropdownButton(
    //     items: _getCameras(),
    //     onChanged: (value) => setState(
    //           () => _cameraOcr = value,
    //         ),
    //     value: _cameraOcr,
    //   ),
    // ));

    // items.add(new SwitchListTile(
    //   title: const Text('Auto focus:'),
    //   value: _autoFocusOcr,
    //   onChanged: (value) => setState(() => _autoFocusOcr = value),
    // ));

    // items.add(new SwitchListTile(
    //   title: const Text('Torch:'),
    //   value: _torchOcr,
    //   onChanged: (value) => setState(() => _torchOcr = value),
    // ));

    // items.add(new SwitchListTile(
    //   title: const Text('Multiple:'),
    //   value: _multipleOcr,
    //   onChanged: (value) => setState(() => _multipleOcr = value),
    // ));

    // items.add(new SwitchListTile(
    //   title: const Text('Show text:'),
    //   value: _showTextOcr,
    //   onChanged: (value) => setState(() => _showTextOcr = value),
    // ));

    items.add(
      new Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: new RaisedButton(
          onPressed: _read,
          child: new Text('Câmera'),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _textsOcr
            .map(
              (ocrText) => new OcrTextWidget(ocrText),
            )
            .toList(),
      ),
    );

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
      texts.add(new OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;

    setState(() => _textsOcr = texts);
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
