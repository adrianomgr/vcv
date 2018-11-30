import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';

import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CarDatabase carData = CarDatabase();
  final otherController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    otherController.dispose();
    super.dispose();
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
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            bottom: new TabBar(
              indicatorColor: Colors.black54,
              tabs: [
                new Tab(text: 'Consulta da Placa'),
                new Tab(text: 'Comunicar Furto'),
              ],
            ),
            title: new Text('Vigilância Cidadã de Veículos'),
          ),
          body: new TabBarView(children: [
            new OcrScreen(carData: carData),
            _comunicarFurto(context, otherController, carData ),
          ]),
        ),
      ),
    );
  }
}

class OcrScreen extends StatefulWidget {
  final CarDatabase carData;

  const OcrScreen({Key key, this.carData}) : super(key: key);

  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;

  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();
  bool _permission = false;
  String error;

  bool currentWidget = true;
  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = false;
  bool _showTextOcr = true;
  List<OcrText> _textsOcr = [];
  Uint8List _image = null;
  final myController = TextEditingController();

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
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: myController,
              decoration: InputDecoration(labelText: "Placa do Veículo"),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25.0, color: Colors.black),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                height: 60.0,
                child: RaisedButton(
                  onPressed: _plateStatus,
                  child: Text("CONSULTAR",
                      style: TextStyle(color: Colors.white, fontSize: 25.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (_image != null) items.add(new Image.memory(_image));

    // items.add(new Center(
    //     child: new Text(_currentLocation != null
    //         ? 'Current location: $_currentLocation\n'
    //         : 'Error: $error\n')));

    return new ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  Future _plateStatus() async {
    Car report = await showDialog<Car>(
      context: context,
      builder: (context) {
        String plate = myController.text;
        return new FutureBuilder<Car>(
          future: widget.carData.search(plate),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new SimpleDialog(
                  children: <Widget>[Text('Loading....')],
                );
              default:
                if (snapshot.hasError)
                  return new SimpleDialog(
                    children: <Widget>[Text('Error: ${snapshot.error}')],
                  );
                else if (snapshot.hasData && snapshot.data.statusCode == 0)
                  return new SimpleDialog(
                    children: <Widget>[_getCar(context, snapshot.data)],
                  );
                else if (snapshot.hasData && snapshot.data.statusCode != 0)
                  return new SimpleDialog(
                    children: <Widget>[
                      _getCar(context, snapshot.data),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, snapshot.data);
                        },
                        child: const Text('Denunciar'),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ],
                  );
                else
                  return new SimpleDialog(
                    children: <Widget>[Text('Placa inválida: ${plate}')],
                  );
            }
          },
        );
      },
    );

    if (report != null) {
      print("Submit report");
      Map<String, dynamic> reportMap;
      reportMap["car"] = report.docID;
      reportMap["location"] = _currentLocation;
      reportMap["dateTime"] = new DateTime.now();
      reportMap["image"] = "";
      Firestore.instance.collection('sightings').add(reportMap);
    }
  }

  Widget _getCar(BuildContext context, Car carStatus) {
    List<Widget> items = [];

    items.add(Text('Status: ${carStatus.status}'));
    items.add(Text(carStatus.plate));
    items.add(Text(carStatus.brand));
    items.add(Text(carStatus.model));
    items.add(Text(carStatus.color));

    return new Column(
      mainAxisSize: MainAxisSize.min,
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
      texts.add(new OcrText(myController.text));
    }
    if (!mounted) return;
    setState(() {
      _textsOcr = texts;
      _image = img;
      myController.text = texts.last.value;
    });
  }
}

class CarDatabase {
  Sinesp sinespClient;

  CarDatabase() {
    this.sinespClient = new Sinesp();
  }

  Future<Car> search(String plate) async {
    RegExp platePattern = new RegExp(r"^[a-zA-Z]{3}(-| )*\d{4}$");
    if (!platePattern.hasMatch(plate)) return null;

    var lhs = RegExp(r"^[a-zA-Z]{3}").stringMatch(plate);
    var rhs = RegExp(r"\d{4}$").stringMatch(plate);
    var stdPlate = '${lhs.toUpperCase()}${rhs}';

    var fireData = await Firestore.instance
        .collection('cars')
        .where('plate', isEqualTo: stdPlate)
        .getDocuments();

    var all_results = fireData.documents;

    if (all_results.isNotEmpty) {
      var result = all_results.first;
      if (result != null && result.exists) {
        print(result.data['plate']);
        return new Car.fromFire(result.documentID, result.data);
      }
    }

    var car = await this.sinespClient.search(stdPlate);
    var carDoc =
        await Firestore.instance.collection('cars').add(car.toMap());
    car.docID = carDoc.documentID;
    return car;
  }

  String getStdPlate(String plate) {
    var lhs = RegExp(r"^[a-zA-Z]{3}").stringMatch(plate);
    var rhs = RegExp(r"\d{4}$").stringMatch(plate);
    return '${lhs.toUpperCase()}${rhs}';
  }

  bool isValidPlate(String plate) {
    RegExp platePattern = new RegExp(r"^[a-zA-Z]{3}(-| )*\d{4}$");
    return platePattern.hasMatch(plate);
  }
}

class Sinesp {
  final String URL =
      'https://cidadao.sinesp.gov.br/sinesp-cidadao/mobile/consultar-placa/v4';
  final String CAPTCHA_URL =
      'https://sinespcidadao.sinesp.gov.br/sinesp-cidadao/captchaMobile.png';
  final String SECRET = "#8.1.0#g8LzUadkEHs7mbRqbX5l";
  String xmlTemplate;

  Sinesp() {
    loadTemplate().then((xml) {
      this.xmlTemplate = xml;
      this.request("luv6009");
    });
  }

  Future<Car> search(String plate) async {
    return parse(request(plate));
  }

  Future<String> request(String plate) async {
    String data = this.getRequestBody(plate);
    Map<String, String> headers = {
      'Accept': 'text/plain, */*; q=0.01',
      'Cache-Control': 'no-cache',
      'Content-Length': '527',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Host': 'sinespcidadao.sinesp.gov.br',
      'User-Agent':
          'SinespCidadao / 3.0.2.1 CFNetwork / 758.2.8 Darwin / 15.0.0',
      'Connection': 'close',
    };

    var client = new http.Client();
    var response = await client.post(URL, body: data);
    return response.body;
  }

  Future<Car> parse(Future<String> response) async {
    var document = xml.parse(await response);
    var elements = document.findAllElements('return').first;
    Map<String, String> fields = new Map<String, String>();
    for (var node in elements.children) {
      var element = node as xml.XmlElement;
      fields[element.name.toString()] = element.text;
    }

    var carStatus = Car(
      city: fields['municipio'],
      state: fields['uf'],
      chassis: fields['chassi'],
      brand: fields['marca'],
      model: fields['modelo'],
      year: int.parse(fields['anoModelo']),
      color: fields['cor'],
      plate: fields['placa'],
      statusCode: int.parse(fields['codigoSituacao']),
      status: fields['situacao'],
    );

    var brandModel = carStatus.model.split('/');
    if (brandModel.length > 1) {
      carStatus.brand = brandModel[0];
      carStatus.model = brandModel[1];
    }

    return carStatus;
  }

  Future<String> loadTemplate() async {
    return await rootBundle.loadString('assets/sinesp_template.xml');
  }

  String getRequestBody(String plate) {
    String token = this.getToken(plate);
    String lat = this.getRandLatitude();
    String lon = this.getRandLongitude();
    String date = this.getDate();
    return sprintf(this.xmlTemplate, [lat, token, lon, date, plate]);
  }

  String getToken(plate) {
    // Generates SHA1 token as HEX based on specified plate and secret key.
    var plateAndSecret = "$plate$SECRET";
    var key = utf8.encode(plateAndSecret);
    var plateBytes = utf8.encode(plate);
    var hmacSha1 = new Hmac(sha1, key);
    return hmacSha1.convert(plateBytes).toString();
  }

  num getRandCoordinate([num radius = 2000]) {
    var gen = new Random();
    num seed = radius / 111000.0 * sqrt(gen.nextDouble());
    seed = seed * sin(2 * pi * gen.nextDouble());
    return seed;
  }

  String getRandLatitude() {
    var lat = this.getRandCoordinate() - 38.5290245;
    return lat.toStringAsFixed(7);
  }

  String getRandLongitude() {
    var lon = this.getRandCoordinate() - 3.7506985;
    return lon.toStringAsFixed(7);
  }

  String getDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }
}

class Car {
  String docID;
  String city;
  String state;
  String chassis;
  String brand;
  String model;
  num year;
  String color;
  String plate;
  num statusCode;
  String status;

  Car(
      {this.docID,
      this.city,
      this.state,
      this.chassis,
      this.brand,
      this.model,
      this.year,
      this.color,
      this.plate,
      this.statusCode,
      this.status});

  Car.fromFire(String id, Map<String, dynamic> map) {
    this.docID = id;
    this.city = map['city'];
    this.state = map['state'];
    this.chassis = map['chassis'];
    this.brand = map['brand'];
    this.model = map['model'];
    this.year = map['year'];
    this.color = map['color'];
    this.plate = map['plate'];
    this.statusCode = map['statusCode'];
    this.status = map['status'];
  }
  

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map['city'] = this.city;
    map['state'] = this.state;
    map['chassis'] = this.chassis;
    map['brand'] = this.brand;
    map['model'] = this.model;
    map['year'] = this.year;
    map['color'] = this.color;
    map['plate'] = this.plate;
    map['statusCode'] = this.statusCode;
    map['status'] = this.status;
    return map;
  }
}

///
/// Comunicar Furto
///
Widget _comunicarFurto(BuildContext context, TextEditingController otherController, CarDatabase carData ) {
  List<Widget> items = [];

  items.add(
    new SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: otherController,
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
                onPressed: () {
                  String plate = otherController.text;
                  if (carData.isValidPlate(plate)) {
                    String stdPlate = carData.getStdPlate(plate);
                    carData.search(stdPlate).then((car) {
                     car.status = "Furto/roubo";
                     car.statusCode = 3;
                      Firestore.instance.collection('cars').add(car.toMap());
                    });
                    otherController.text = "";
                  } else {
                    showDialog (
                      context: context,
                      builder: (context) {
                        return new AlertDialog(
                          content: Text("Placa inválida ${plate}"),
                        );
                      }
                    );
                  }
                },
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
