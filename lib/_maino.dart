import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'dart:math' show Random;
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({
    Key? key,
  }) : super(key: key);

  Future<List<ForeCast>> getForcast() async {
    var link = "http://10.0.2.2:8081/api/v1/forecast";
    final response = await http.get(Uri.parse(link));
    List<ForeCast> list = [];
    if (response.statusCode == 200) {
      print('This is the response ');
      var parsedResult =
          List<Map<String, dynamic>>.from(json.decode(response.body));
      print(parsedResult);
      var objectList =
          parsedResult.map((forecast) => ForeCast.fromJson(forecast)).toList();
      print(objectList.length);
      objectList.forEach((forecast) {
        list.add(forecast);
      });
    } else {
      print('Something bad happended');
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // var rand = Random();
    // var listForeCast = <ForeCast>[
    //   ForeCast(
    //       id: 12,
    //       date: DateTime.now().add(Duration(days: rand.nextInt(7))),
    //       description: 'Hot with a chance of multiple orgs',
    //       minTemperature: 12,
    //       maxTemperature: 23),
    //   ForeCast(
    //       id: 14,
    //       date: DateTime.now().add(Duration(days: rand.nextInt(7))),
    //       description: 'Cold with a chance of multiple coffee',
    //       minTemperature: 2,
    //       maxTemperature: 12),
    //   ForeCast(
    //       id: 13,
    //       date: DateTime.now().add(Duration(days: rand.nextInt(7))),
    //       description: 'Hot with a chance of multiple orgs',
    //       minTemperature: 12,
    //       maxTemperature: 32)
    // ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Workshop Slivers'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<ForeCast>>(
            future: getForcast(),
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data!
                        .map((e) => ForeCastWidget(casting: e))
                        .toList());
              } else {
                return Text('Loading');
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddForeCast()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ForeCast {
  final int id;
  final DateTime date;
  final String description;
  final int minTemperature;
  final int maxTemperature;
  ForeCast(
      {required this.id,
      required this.date,
      required this.description,
      required this.minTemperature,
      required this.maxTemperature});
  ForeCast.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id'], radix: 10),
        date = DateTime.parse(json['date']),
        description = json['description'],
        maxTemperature = int.parse(json['maxTemperature'], radix: 10),
        minTemperature = int.parse(json['minTemperature'], radix: 10);
}

class ForeCastWidget extends StatelessWidget {
  final ForeCast casting;
  const ForeCastWidget({Key? key, required this.casting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        casting.date.day.toString(),
        style: TextStyle(fontSize: 24),
      ),
      title: Text(DaysOfWeek[casting.date.weekday - 1].toString()),
      subtitle: Text(casting.description),
      trailing: Text("${casting.minTemperature} | ${casting.maxTemperature} C"),
    );
  }
}

// ignore: non_constant_identifier_names
List<String> DaysOfWeek = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday'
];

class AddForeCast extends StatefulWidget {
  const AddForeCast({Key? key}) : super(key: key);

  @override
  _AddForeCastState createState() => _AddForeCastState();
}

class _AddForeCastState extends State<AddForeCast> {
  GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  var _formData = Map<String, dynamic>();

  Future<DateTime?> getDateTime() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 14)),
      cancelText: 'Cancel',
      confirmText: 'Confrim',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Forecast'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: _formStateKey,
            child: Column(
              children: [
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Description Of Forcast'),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 3) {
                      return 'Itai Serious Boss';
                    }
                  },
                  onSaved: (value) {
                    _formData['description'] = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Min Temperature'),
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Itai Serious Boss';
                    }
                  },
                  onSaved: (value) {
                    _formData['minTemperatue'] = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Max Temperature'),
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Itai Serious Boss';
                    }
                  },
                  onSaved: (value) {
                    _formData['maxTemperature'] = value!;
                  },
                ),
                TextButton(
                    onPressed: () async {
                      var date = await getDateTime();
                      _formData['date'] = date.toString();
                      print(date!.toUtc());
                    },
                    child: Text('Add Date')),
                InkWell(
                  onTap: () async {
                    if (_formStateKey.currentState!.validate()) {
                      _formStateKey.currentState!.save();
                      print(_formData);
                      _formData['id'] = Random.secure().nextInt(1000);
                      // make api call here
                      print(int.parse(_formData['minTemperatue'], radix: 10));
                      var link = "http://10.0.2.2:8081/api/v1/forecast";
                      ForeCast obj = ForeCast(
                          date: DateTime.parse(_formData['date']),
                          description: _formData['description'],
                          id: Random.secure().nextInt(1000),
                          maxTemperature:
                              int.parse(_formData['maxTemperatue'], radix: 10),
                          minTemperature: int.parse(_formData['minTemperature'],
                              radix: 10));
                      final response = await http.put(
                        Uri.parse(link),
                        body: obj,
                      );
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        print('Yah done it');
                      } else {
                        print(response.body);
                        print('Errored');
                      }
                    }
                    print('Not Valid State');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * .6,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(
                              20,
                            ),
                            right: Radius.circular(20))),
                    child: Center(
                      child: Text('SubmitForecast'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
