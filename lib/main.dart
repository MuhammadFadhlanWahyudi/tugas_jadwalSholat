import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tugas_jadwal_sholat/header_content.dart';
import 'package:tugas_jadwal_sholat/list_jadwal.dart';
import 'package:tugas_jadwal_sholat/model/ResponseJadwal.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHomeScreen(),
  ));
}

class MyHomeScreen extends StatefulWidget {
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  TextEditingController _locationController = TextEditingController();

  Future<ResponseJadwal> getJadwal({String location}) async {
    String url =
        'https://api.pray.zone/v2/times/today.json?city=bogor&school=9';
    final response = await http.get(url);
    final jsonResponse = json.decode(response.body);
    return ResponseJadwal.fromJsonMap(jsonResponse);
  }

  @override
  void initState() {
    if (_locationController.text.isEmpty || _locationController.text == null) {
      _locationController.text = 'Bogor';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final header = Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.width - 110,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 8.0,
                    offset: Offset(0.4, 4.0),
                    color: Colors.black45)
              ],
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    'https://i.pinimg.com/originals/f6/4a/36/f64a368af3e8fd29a1b6285f3915c7d4.jpg'),
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Tooltip(
                message: "Ubah Lokasi",
                child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.location_on),
                    onPressed: () {
                      _ShowDialogEditLocation(context);
                    }),
              )
            ],
          ),
        ),
        FutureBuilder(
            future: getJadwal(
                location: _locationController.text.toLowerCase().toString()),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return HeaderContent(snapshot.data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Data Tidak Tersedia",
                        style: TextStyle(
                            color: Colors.white
                        ),),
                    )
                );
              }
              return Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
              );
            }
        )
      ],
    );
    final body = Expanded(
        child: FutureBuilder
          (future: getJadwal(
            location: _locationController.text.toLowerCase().toString()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListJadwal(snapshot.data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Center(child: Text('Data Tidak Tersedia'));
              }
              return Center(child: CircularProgressIndicator());
            }
        ));
    return Scaffold(
      body: Column(
        children: <Widget>[header, body],
      ),
    );
  }

  void _ShowDialogEditLocation(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ubah Lokasi'),
            content: TextField(
              controller: _locationController,
              decoration: InputDecoration(hintText: 'Lokasi'),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, child: new Text('Batal',),
              ),
              new FlatButton(onPressed: () {
                Navigator.pop(context, () {
                  setState(() {
                    getJadwal(location: _locationController.text.toLowerCase()
                        .toString());
                  });
                });
              }, child: new Text('Ok'),
              ),
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
          );
        });
  }
}
