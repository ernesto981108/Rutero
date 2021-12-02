import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class ListenLocationWidget extends StatefulWidget {
  const ListenLocationWidget({Key? key}) : super(key: key);

  @override
  _ListenLocationState createState() => _ListenLocationState();
}

class _ListenLocationState extends State<ListenLocationWidget> {
  final Location location = Location();

  LocationData? _location;
  late StreamSubscription<LocationData> _locationSubscription;
  String? _error;
  String latitud = '';
  String longitud = '';
  String accuracy = '';
  bool? _enabled;

  Future<void> _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        _error = null;

        _location = currentLocation;
        if (_location!.accuracy! < 5) {
          latitud = _location!.latitude.toString();
          longitud = _location!.longitude.toString();
          accuracy = _location!.accuracy.toString();
          sendInfo();
          //   print('$_location');
          // print('$_location.accuracy');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Ubicacion en Tiempo real: ' +
              (_error ?? '${_location ?? "Desconocido"}'),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const Divider(
          height: 20,
        ),
        Center(
          child: FloatingActionButton(
            child: Image.asset(
              'assets/logo_boton1.png',
              scale: 5,
            ),
            onPressed: () => {
              _toggleBackgroundMode(),
              _listenLocation(),
              location.changeNotificationOptions(
                title: 'Localización en segundo plano activa',
              )
            },
          ),
        )
      ],
    );
  }

  var url = Uri.parse('http://152.206.177.70:1337/ubicacions');
  void sendInfo() async {
    await http.post(url, body: {
      'imei': '011010',
      'ubicacion': '$latitud,$longitud*${accuracy.toString()}',
      'ip': ''
    });
  }

  Future<void> _toggleBackgroundMode() async {
    setState(() {
      _error = null;
    });
    try {
      final bool result =
          await location.enableBackgroundMode(enable: !(_enabled ?? false));
      setState(() {
        _enabled = result;
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }
}
