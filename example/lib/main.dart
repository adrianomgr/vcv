import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
                new Tab(text: 'Denuncias'),
                new Tab(text: 'Veículos Reportados'),
              ],
            ),
            title: new Text('Vigilância Cidadã de Veículos'),
          ),
          body: new TabBarView(children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder(
                      stream: Firestore.instance
                          .collection("sightings")
                          .snapshots(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          default:
                            if (!snapshot.hasData)                          return Center(
                                child: CircularProgressIndicator(),
                              );
                            return ListView.builder(
                                // reverse: true,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  return Denuncias(
                                      snapshot.data.documents[index].data);
                                });
                        }
                      }),
                ),
              ],
            ),
            _dados(context),
          ]),
        ),
      ),
    );
  }
}

class Denuncias extends StatelessWidget {
  final Map<String, dynamic> data;

  Denuncias(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://gastroahotel.cz/files/2014/10/silueta.jpg"))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Veículo Encontrado",
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: new FutureBuilder(
                      future: data["car"].get(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return new Text('waiting');
                          default:
                            if(snapshot.hasData) {
                              return Text(snapshot.data['plate']);
                            } else {
                              return new Text('invalido');
                            }
                        }
                      }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
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
