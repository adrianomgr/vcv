import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class FlutterMobileVision {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mobile_vision');

  static const int CAMERA_BACK = 0;
  static const int CAMERA_FRONT = 1;

  ///
  ///
  ///
  static Future<Capture> read({
    bool flash: false,
    bool autoFocus: true,
    bool multiple: false,
    bool showText: true,
    int camera: CAMERA_BACK,
    double fps: 2.0,
  }) async {
    Map<String, dynamic> arguments = {
      'flash': flash,
      'autoFocus': autoFocus,
      'multiple': multiple,
      'showText': showText,
      'camera': camera,
      'fps': fps,
    };

    List list = await _channel.invokeMethod('read', arguments);
    var capture = await Capture(
      textList: await list.getRange(0, list.length-1).map((map) => OcrText.fromMap(map)).toList(),
      image: await list.last.values.first,
    );

    return capture;
  }

}

class Capture {
  List<OcrText> textList;
  Uint8List image;

  Capture({this.textList, this.image});

}


///
///
///
class OcrText {
  final String value;
  final String language;
  final int top;
  final int bottom;
  final int left;
  final int right;

  OcrText(
    this.value, {
    this.language: '',
    this.top: -1,
    this.bottom: -1,
    this.left: -1,
    this.right: -1,
    
  });

  OcrText.fromMap(Map map)
      : value = map['value'],
        language = map['language'],
        top = map['top'],
        bottom = map['bottom'],
        left = map['left'],
        right = map['right'];


  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'language': language,
      'top': top,
      'bottom': bottom,
      'left': left,
      'right': right,
    };
  }
}


