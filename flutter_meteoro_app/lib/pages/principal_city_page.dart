// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_meteoro_app/models/city.dart';
import 'package:flutter_meteoro_app/models/earthWeather.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

late double lat = 0;
late double long = 0;

class EarthWeatherPage extends StatefulWidget {
  const EarthWeatherPage({Key? key}) : super(key: key);

  @override
  _PrincipalPageState createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<EarthWeatherPage> {
  late Future<List<Hourly>> itemsHours;
  late Future<List<Daily>> itemsDayly;
  late Future<double> itemDaylyTempMax, itemDaylyTempMin;

  late Future<String> nameLocation;
  late Future<int> fechaLocation;
  late Future<String> iconLocation;

  @override
  void initState() {
    itemsHours = fetchHours();
    itemsDayly = fetchDayly();
    itemDaylyTempMax = fetchDaylyNowTempMax();
    itemDaylyTempMin = fetchDaylyNowTempMin();

    nameLocation = fetchNameCity();
    fechaLocation = fetchFechaCity();
    iconLocation = fetchIconCity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (lat == 0) {
      return Scaffold(
          backgroundColor: Color(0xff828CAE),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 60, bottom: 30),
                  child: Text(
                    'Bienvenido',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Image(image: AssetImage('assets/images/fondo.jpg')),
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    'Añadir ubicación \n predeterminada',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ));
    } else {
      return Scaffold(
          backgroundColor: Color(0xff828CAE),
          body: SingleChildScrollView(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(children: [
                FutureBuilder<String>(
                  future: nameLocation,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _getLocation(snapshot.data!);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
                FutureBuilder<int>(
                  future: fechaLocation,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _getFecha(snapshot.data!);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
                FutureBuilder<String>(
                  future: iconLocation,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _getIcon(snapshot.data!);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                ),
                Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 35, top: 5, bottom: 5),
                      child: Row(
                        children: [
                          Card(
                              color: Colors.white.withOpacity(.3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              margin: EdgeInsets.all(5),
                              elevation: 4,
                              child: Container(
                                  width: 150.0,
                                  child: Container(
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text('Max',
                                                    style: TextStyle(
                                                        fontSize: 25)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: FutureBuilder<double>(
                                                  future: itemDaylyTempMax,
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      return _getDaylyNow(
                                                          snapshot.data!);
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          '${snapshot.error}');
                                                    }
                                                    // By default, show a loading spinner.
                                                    return const CircularProgressIndicator();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ))))),
                          Card(
                              color: Colors.white.withOpacity(.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              margin: EdgeInsets.all(5),
                              elevation: 4,
                              child: Container(
                                  width: 150.0,
                                  child: Container(
                                      child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Min',
                                              style: TextStyle(fontSize: 25)),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: FutureBuilder<double>(
                                            future: itemDaylyTempMin,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return _getDaylyNowTempMin(
                                                    snapshot.data!);
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    '${snapshot.error}');
                                              }
                                              // By default, show a loading spinner.
                                              return const CircularProgressIndicator();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))))
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 205, top: 20, bottom: 5),
              child:
                  Text('Previsión por horas', style: TextStyle(fontSize: 16)),
            ),
            FutureBuilder<List<Hourly>>(
              future: itemsHours,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _HoursList(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
            const Padding(
              padding: EdgeInsets.only(right: 205, bottom: 5),
              child: Text('Previsión por dias', style: TextStyle(fontSize: 16)),
            ),
            FutureBuilder<List<Daily>>(
              future: itemsDayly,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _DaylyList(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ])));
    }
  }

  Future<List<Hourly>> fetchHours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('lat')!;
    long = prefs.getDouble('lng')!;

    if (lat == null) {
      lat = 37.3824;
      long = -5.9761;
    }
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=${lat}&lon=${long}&exclude=minutely&appid=4746be909c612853dd1618735b09914f&units=metric'));
    if (response.statusCode == 200) {
      return OneCallResponse.fromJson(jsonDecode(response.body)).hourly;
    } else {
      throw Exception('Failed to load people');
    }
  }

  Future<List<Daily>> fetchDayly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('lat')!;
    long = prefs.getDouble('lng')!;

    if (lat == null) {
      lat = 37.3824;
      long = -5.9761;
    }
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=${lat}&lon=${long}&exclude=minutely&appid=4746be909c612853dd1618735b09914f&units=metric'));
    if (response.statusCode == 200) {
      return OneCallResponse.fromJson(jsonDecode(response.body)).daily;
    } else {
      throw Exception('Failed to load people');
    }
  }

  Future<double> fetchDaylyNowTempMax() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('lat')!;
    long = prefs.getDouble('lng')!;

    if (lat == null) {
      lat = 37.3824;
      long = -5.9761;
    }
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=${lat}&lon=${long}&exclude=minutely&appid=4746be909c612853dd1618735b09914f&units=metric'));
    if (response.statusCode == 200) {
      return OneCallResponse.fromJson(jsonDecode(response.body))
          .daily[0]
          .temp
          .max;
    } else {
      throw Exception('Failed to load people');
    }
  }

  Future<double> fetchDaylyNowTempMin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('lat')!;
    long = prefs.getDouble('lng')!;

    if (lat == null) {
      lat = 37.3824;
      long = -5.9761;
    }
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=${lat}&lon=${long}&exclude=minutely&appid=4746be909c612853dd1618735b09914f&units=metric'));
    if (response.statusCode == 200) {
      return OneCallResponse.fromJson(jsonDecode(response.body))
          .daily[0]
          .temp
          .min;
    } else {
      throw Exception('Failed to load people');
    }
  }

  Widget _getDaylyNow(double daily) {
    return Text(daily.toStringAsFixed(0) + 'º',
        style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold));
  }

  Widget _getDaylyNowTempMin(double daily) {
    return Text(daily.toStringAsFixed(0) + 'º',
        style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold));
  }

  Future<String> fetchNameCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('lat')!;
    long = prefs.getDouble('lng')!;

    if (lat == null) {
      lat = 37.3824;
      long = -5.9761;
    }
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${long}&appid=4746be909c612853dd1618735b09914f'));
    if (response.statusCode == 200) {
      return CityResponse.fromJson(jsonDecode(response.body)).name;
    } else {
      throw Exception('Failed to load people');
    }
  }

  Future<int> fetchFechaCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('lat')!;
    long = prefs.getDouble('lng')!;

    if (lat == null) {
      lat = 37.3824;
      long = -5.9761;
    }
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${long}&appid=4746be909c612853dd1618735b09914f'));
    if (response.statusCode == 200) {
      return CityResponse.fromJson(jsonDecode(response.body)).dt;
    } else {
      throw Exception('Failed to load people');
    }
  }

  Future<String> fetchIconCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lat = prefs.getDouble('lat')!;
    long = prefs.getDouble('lng')!;

    if (lat == null) {
      lat = 37.3824;
      long = -5.9761;
    }
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${long}&appid=4746be909c612853dd1618735b09914f'));
    if (response.statusCode == 200) {
      return CityResponse.fromJson(jsonDecode(response.body)).weather[0].icon;
    } else {
      throw Exception('Failed to load people');
    }
  }

  Widget _getIcon(String icon) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
          width: 100,
          child: Image(image: AssetImage('assets/images/${icon}.png'))),
    );
  }

  Widget _getIcons() {
    return FutureBuilder<String>(
      future: iconLocation,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _getIcon(snapshot.data!);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _getLocation(String name) {
    return Text(name,
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold));
  }

  Widget _getFecha(int name) {
    initializeDateFormatting('es_ES', null).then((_) => _getFecha);
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(name * 1000);
    final DateFormat formatter = DateFormat.yMMMMd('es_ES');
    final String formatted = formatter.format(now);
    return Text(formatted.toString(), style: TextStyle(fontSize: 15));
  }

  Widget _HoursList(List<Hourly> HoursList) {
    return SizedBox(
      height: 170,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: HoursList.length,
        itemBuilder: (context, index) {
          return _HoursItem(HoursList.elementAt(index));
        },
      ),
    );
  }

  Widget _DaylyList(List<Daily> DaylyList) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: DaylyList.length,
        itemBuilder: (context, index) {
          return _DaylyItem(DaylyList.elementAt(index));
        },
      ),
    );
  }

  Widget _HoursItem(Hourly hourly) {
    initializeDateFormatting('es_ES', null).then((_) => _getFecha);
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(hourly.dt * 1000);
    final DateFormat formatterHora = DateFormat.Hm();
    final DateFormat formatterFecha = DateFormat.MMMd('es_ES');
    final String hora = formatterHora.format(now);
    final String fecha = formatterFecha.format(now);

    return Column(
      children: [
        Container(
            height: 130.0,
            width: 220,
            child: Card(
              color: Colors.white.withOpacity(.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              margin: EdgeInsets.all(5),
              elevation: 10,
              child: Container(
                width: 150.0,
                child: Container(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        children: [
                          Row(children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                  width: 60,
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/${hourly.weather[0].icon}.png'))),
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, bottom: 5, right: 25),
                                        child: Text(hora,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, bottom: 5),
                                        child: Text(fecha,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                        hourly.temp.toStringAsFixed(0) + 'º',
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text('Viento: ' +
                                        hourly.windSpeed.toStringAsFixed(1) +
                                        ' km/h'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text('Humedad: ' +
                                        hourly.humidity.toString() +
                                        ' %'),
                                  )
                                ])
                          ]),
                        ],
                      )),
                ),
              ),
            )),
      ],
    );
  }

  Widget _DaylyItem(Daily daily) {
    initializeDateFormatting('es_ES', null).then((_) => _getFecha);
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(daily.dt * 1000);
    final DateFormat formatter = DateFormat.MMMd('es_ES');
    final DateFormat formatterDia = DateFormat.EEEE('es_ES');
    final String dia = formatterDia.format(now);
    final String fecha = formatter.format(now);
    return Column(
      children: [
        Container(
            height: 130.0,
            width: 220,
            child: Card(
              color: Colors.white.withOpacity(.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              margin: EdgeInsets.all(5),
              elevation: 10,
              child: Container(
                width: 150.0,
                child: Container(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        // AÑADIR LA HORA DEL DIA CON hourly.dt y uso el format para sacar la hora //
                        children: [
                          Row(children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                  width: 60,
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/${daily.weather[0].icon}.png'))),
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 5),
                                    child: Text('${dia}\n${fecha}',
                                        style: TextStyle(
                                          fontSize: 18,
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                        daily.temp.max.toStringAsFixed(0) +
                                            'º ' +
                                            daily.temp.min.toStringAsFixed(0) +
                                            'º',
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text('Viento: ' +
                                        daily.windSpeed.toStringAsFixed(1) +
                                        ' km/h'),
                                  ),
                                ])
                          ]),
                        ],
                      )),
                ),
              ),
            )),
      ],
    );
  }
}
