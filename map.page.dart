import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  List<Marker> markers = [];
  double lat = 45.521563;
  double long = -122.677433;
  LatLng mainLocation = const LatLng(45.521563, -122.677433);
  List<DropOptions> listDrop = <DropOptions>[
    DropOptions(id: '1', value: 'Pneu'),
    DropOptions(id: '2', value: 'Pilha'),
    DropOptions(id: '3', value: 'Sucata'),
    DropOptions(id: '4', value: 'Comum'),
  ];
  String dropdownValue = '1';

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  bool isLoading = false;
  bool mock = true;
  static const int duration = 3;

  static Future<Response> _delay(
    Response response,
  ) async {
    return Future.delayed(const Duration(seconds: duration), () => response);
  }

  static Future<Response>? responseSuccess(String route) =>
      _delay(_responseSuccess(route));

  static Response _responseSuccess(String route) => Response(
        statusCode: 200,
        data: getMockSuccessType(route),
        requestOptions: RequestOptions(path: route),
      );

  static getMockSuccessType(String id) {
    switch (id) {
      case '1':
        return {
          'data': [
            {
              'id': '04',
              'lat': -20.352240384987592,
              'lng': -40.30212298036566,
              'title': 'Recicle Fácil Vix Centro de reciclagem',
              'type': 'Pneu'
            }
          ],
        };
      case '2':
        return {
          'data': [
            {
              'id': '02',
              'lat': -20.34029736628966,
              'lng': -40.29356058658282,
              'title': 'Supermercado Perim - Centro',
              'type': 'Pilha'
            },
            {
              'id': '03',
              'lat': -20.35410746858415,
              'lng': -40.299213223154894,
              'title': 'Universidade Vilha Velha',
              'type': 'Pilha'
            },
            {
              'id': '07',
              'lat': -20.33220125300863,
              'lng': -40.35334050814362,
              'title': 'Lorene',
              'type': 'Pilha'
            }
          ],
        };
      case '3':
        return {
          'data': [
            {
              'id': '08',
              'lat': -20.272123928251684,
              'lng': -40.31792261302999,
              'title': 'Faria Reciclagem - Vitoria',
              'type': 'Sucata'
            },
            {
              'id': '09',
              'lat': -20.152133192767458,
              'lng': -40.184967271397085,
              'title': 'Faria Reciclagem - Serra',
              'type': 'Comum'
            },
            {
              'id': '10',
              'lat': -20.30878084304554,
              'lng': -40.31283119542408,
              'title': 'Recicla Capixaba',
              'type': 'Sucata'
            }
          ],
        };
      default:
        return {
          'data': [
            {
              'id': '01',
              'lat': -20.3372400749566,
              'lng': -40.29348705517084,
              'title': 'Papelaria Rainha - Centro',
              'type': 'Comum'
            },
            {
              'id': '05',
              'lat': -20.34212340486057,
              'lng': -40.28812418006685,
              'title': 'Shopping Praia da Costa',
              'type': 'Comum'
            },
            {
              'id': '06',
              'lat': -20.35202991632563,
              'lng': -40.29771589620529,
              'title': 'Shopping Vila Velha',
              'type': 'Comum'
            },
            // {
            //   'id': '11',
            //   'lat': -20.355687936388872,
            //   'lng': -40.29809358643853,
            //   'title': 'Forum de Vila Velha',
            //   'type': 'Comum'
            // }
          ],
        };
    }
  }

  Future<List<MakerModel>> getListMakersFromRepository(String id) async {
    try {
      setState(() {
        isLoading = true;
        markers = [];
      });
      final dio = Dio();
      final response = mock
          ? await responseSuccess(id)
          : await dio.get('http://192.168.0.95:5000/get_data');
      setState(() {
        isLoading = false;
      });
      if (response?.data != null) {
        final list = response?.data as Map;
        return (list['data'] as List)
            .map(
              (
                item,
              ) =>
                  MakerModel(
                id: item['id'],
                lat: item['lat'],
                lng: item['lng'],
                title: item['title'],
                type: item['type'],
              ),
            )
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Marker>> getListMakers(String id) async {
    final list = await getListMakersFromRepository(id);
    return list
        .map((item) => Marker(
              markerId: MarkerId(item.id),
              position: LatLng(item.lat, item.lng),
              infoWindow: InfoWindow(
                title: item.title,
                snippet: item.type,
                onTap: () {},
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? id) async {
                      lat = -20.35410746858415;
                      long = -40.299213223154894;
                      LatLng position = LatLng(lat, long);
                      await mapController
                          .moveCamera(CameraUpdate.newLatLng(position));
                      setState(() {
                        dropdownValue = listDrop
                            .where((element) => element.id == id)
                            .first
                            .id;
                      });
                      final marksResult = await getListMakers(id ?? '');
                      setState(() {
                        markers = marksResult;
                        mainLocation = position;
                      });
                    },
                    items: listDrop
                        .map<DropdownMenuItem<String>>((DropOptions item) {
                      return DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                // ignore: prefer_collection_literals
                gestureRecognizers: Set()
                  ..add(Factory<PanGestureRecognizer>(
                      () => PanGestureRecognizer()))
                  ..add(Factory<ScaleGestureRecognizer>(
                      () => ScaleGestureRecognizer()))
                  ..add(Factory<TapGestureRecognizer>(
                      () => TapGestureRecognizer()))
                  ..add(Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer())),
                initialCameraPosition: CameraPosition(
                  target: mainLocation,
                  zoom: 11.0,
                ),
                onTap: (LatLng latLng) {
                  // controller.changeShowCardItem(false);
                },
                markers: Set<Marker>.from(markers),
                mapType: MapType.normal,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                onMapCreated: _onMapCreated,
              ),
        floatingActionButton: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showTextInputDialog(
                      context); // Function to show text input dialog
                },
                child: const Text('Quer Adicionar um local?'),
              ),
            ],
          ),
        ));
  }
}

class MakerModel {
  String id;
  double lat;
  double lng;
  String title;
  String type;
  MakerModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.title,
    required this.type,
  });
}

class DropOptions {
  String id;
  String value;
  DropOptions({required this.id, required this.value});
}

Future<void> _showTextInputDialog(BuildContext context) async {
  TextEditingController textController = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Exemplo: "nome, pilha, lat, long'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Digite aqui'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              String userText = textController.text;
              // Do something with the user's entered text
              if (kDebugMode) {
                print('Obrigado!: $userText');
              }
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Enviar'),
          ),
        ],
      );
    },
  );
}
