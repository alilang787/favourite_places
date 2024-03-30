// import 'dart:typed_data';
// import 'dart:ui' as ui;
import 'dart:convert';
import 'package:favourite_places/models/model_fav_places.dart';
import 'package:favourite_places/models/model_search_places.dart';
import 'package:favourite_places/screens/map-screen/widgets/bottom_model_sheet.dart';
import 'package:favourite_places/screens/map-screen/widgets/loc_pick_helpertext.dart';
import 'package:favourite_places/screens/map-screen/widgets/suggestion_opt_build.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// var logger = Logger();

enum MapView { OverView, Interacting }

class Coards {
  double lng;
  double lat;
  Coards({required this.lng, required this.lat});
}

class MapScreen extends StatefulWidget {
  final MapView mapView;
  final double? lng;
  final double? lat;
  final Function({
    required BuildContext ctx,
    required double lat,
    required double lng,
  })? locationSaver;
  MapScreen({
    super.key,
    required this.mapView,
    this.lng,
    this.lat,
    this.locationSaver,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String session_token = '40644562-1860-4c44-a72e-e24698d1f98c';

  MapboxMap? mapboxMap;
  ScreenCoordinate? coordinate;
  TextEditingController? _searchController;
  List<SuggestionModel> suggestions_global = [];
  PointAnnotationManager? pointAnnotationManager;
  PointAnnotation? pointAnnotation;
  late Uint8List marker;
  IconData loc_icon = Icons.location_disabled;
  Coards? coards;
  bool _addPrgress = false;

  void _loadMarker() async {
    logger.i('loadMarker called');
    final bytes = await rootBundle.load('assets/icons/red_marker.png');
    marker = bytes.buffer.asUint8List();
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
    _loadMarker();
  }

  @override
  void dispose() {
    _searchController!.dispose();
    super.dispose();
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    if (widget.mapView == MapView.OverView) {
      logger.i('called');
      showMarker(
        lng: widget.lng!,
        lat: widget.lat!,
        text: 'Your Place',
        textColor: Colors.red.shade600,
      );
      this.mapboxMap!.setCamera(
            CameraOptions(
              bearing: 0,
              pitch: 0,
              center: Point(coordinates: Position(widget.lng!, widget.lat!))
                  .toJson(),
              zoom: 16.0,
            ),
          );
    }
  }

  _mapStyleChanger(String style) {
    mapboxMap!.loadStyleURI(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mapView == MapView.Interacting
              ? 'Select you location'
              : 'Your Favourite Location',
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          MapWidget(
            key: ValueKey("mapWidget"),
            onMapCreated: _onMapCreated,
            onLongTapListener: (coard) {
              if (widget.mapView != MapView.Interacting) return;
              coordinate = coard;
              setState(() {
                coards = Coards(lng: coard.y, lat: coard.x);
              });
              mapboxMap!.easeTo(
                CameraOptions(
                  center: Point(
                    coordinates: Position(coard.y, coard.x),
                  ).toJson(),
                ),
                MapAnimationOptions(),
              );
              mapboxMap!.scaleBar.updateSettings(ScaleBarSettings(
                position: OrnamentPosition.BOTTOM_RIGHT,
              ));
              showMarker(lng: coard.y, lat: coard.x, text: 'Seleted Location');
            },
          ),
          if (widget.mapView == MapView.Interacting)
            Positioned(
              top: 45,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 70,
                alignment: Alignment.center,
                child: Autocomplete(
                  onSelected: (option) {
                    FocusScope.of(context).unfocus();
                  },
                  optionsBuilder: (textEditingValue) async {
                    suggestions_global =
                        await seachBarOnChange(textEditingValue.text);
                    return suggestions_global.map((e) => e.place_name).toList();
                  },
                  optionsViewBuilder: (ctx, onSelected, options) {
                    return OptBuilder(
                      session_token: session_token,
                      suggestions_global: suggestions_global,
                      onSelected: onSelected,
                      locationAnimation: _locationAnimation,
                    );
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(44),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Positioned(
            right: 4,
            top: 150,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(
                  Icons.layers_outlined,
                  color: Colors.black,
                ),
                onPressed: () => showModalBottomSheet(
                  showDragHandle: true,
                  context: context,
                  builder: (context) {
                    return BottomModelSheet(
                      mapStyleChanger: _mapStyleChanger,
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 150,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(
                  loc_icon,
                  color: loc_icon == Icons.my_location
                      ? Colors.blue
                      : Colors.black,
                ),
                onPressed: () async {
                  setState(() {
                    loc_icon = Icons.location_searching;
                  });
                  LocationData locationData = await _locPermission();

                  if (locationData.latitude != null) {
                    setState(() {
                      loc_icon = Icons.my_location;
                    });
                    _locationAnimation(
                      locationData.longitude!,
                      locationData.latitude!,
                    );
                    if (widget.mapView == MapView.Interacting) {
                      showMarker(
                        lng: locationData.longitude!,
                        lat: locationData.latitude!,
                        text: 'You here',
                        textColor: Colors.red,
                      );
                      setState(() {
                        coards = Coards(
                          lng: locationData.longitude!,
                          lat: locationData.latitude!,
                        );
                      });
                    } else {
                      if (widget.lat == locationData.latitude!)
                        pointAnnotationManager?.delete(pointAnnotation!);
                      mapboxMap!.location.updateSettings(
                        LocationComponentSettings(
                          enabled: true,
                          pulsingEnabled: true,
                          // locationPuck: LocationPuck(
                          // locationPuck3D: LocationPuck3D(
                          //   modelUri:
                          //       "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Embedded/Duck.gltf",
                          //   modelScale: [100.0, 100.0, 100.0],
                          // ),
                          // ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
          if (widget.mapView == MapView.Interacting)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.25,
              right: MediaQuery.of(context).size.width * 0.25,
              bottom: 100,
              child: coards == null
                  ? helperLocPicker()
                  : Container(
                      width: 40,
                      height: 60,
                      child: FittedBox(
                        child: _addPrgress
                            ? RefreshProgressIndicator()
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade50,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _addPrgress = true;
                                  });
                                  logger.i('reached');
                                  bool val = await widget.locationSaver!(
                                    ctx: context,
                                    lng: coards!.lng,
                                    lat: coards!.lat,
                                  );
                                  if (val)
                                    Navigator.pop(context);
                                  else
                                    setState(() {
                                      _addPrgress = false;
                                    });
                                },
                                icon: Icon(
                                  Icons.add,
                                  size: 34,
                                ),
                                label: Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
            )
        ],
      ),
    );
  }

//
//   ..........     M E T H O D S   ................
//

  seachBarOnChange(value) async {
    List<SuggestionModel> suggestions = [];
    final text = value.trim().replaceAll(' ', '+');
    if (text.isEmpty) {
      suggestions = [];
      return suggestions;
    }
    const mapBoxKey = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
    final suggest_url = Uri.parse(
        'https://api.mapbox.com/search/searchbox/v1/suggest?q=$value&language=en&session_token=$session_token&access_token=$mapBoxKey');
    final suggestion_response = await http.get(suggest_url);
    if (suggestion_response.statusCode != 200 ||
        suggestion_response.body.isEmpty) return;
    final Map su_res_decoded = json.decode(suggestion_response.body);
    final List su_raw = su_res_decoded['suggestions'];
    su_raw.forEach((e) {
      if (e['feature_type'].toString() == 'poi' ||
          e['feature_type'].toString() == 'place') {
        final suggestion = SuggestionModel(
          mapbox_id: e['mapbox_id'],
          place_name: e['name'],
          full_address: e['place_formatted'],
          feature_type: e['feature_type'],
        );
        suggestions.add(suggestion);
      }
    });

    return suggestions;
  }

  // ...........  location permission & data ................
  _locPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    return locationData;
  }

  //   ....... Location Animation  .........

  _locationAnimation(double lng, double lat) async {
    // await mapboxMap!.easeTo(
    //   CameraOptions(
    //     zoom: 2,
    //   ),
    //   MapAnimationOptions(
    //     duration: 3000,
    //     startDelay: 0,
    //   ),
    // );
    // await Future.delayed(Duration(seconds: 2));
    // await mapboxMap!.easeTo(
    //   CameraOptions(
    //     center: Point(
    //       coordinates: Position(lng, lat),
    //     ).toJson(),
    //     zoom: 6,
    //   ),
    //   MapAnimationOptions(
    //     duration: 2000,
    //     startDelay: 0,
    //   ),
    // );
    // await Future.delayed(Duration(milliseconds: 1900));
    await mapboxMap!.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(lng, lat),
        ).toJson(),
        zoom: 16,
      ),
      MapAnimationOptions(
        duration: 2000,
        startDelay: 0,
      ),
    );
  }

  //   ....... Location Marker  .........

  void showMarker({
    required double lng,
    required double lat,
    double? iconSize,
    String? text,
    Color? textColor,
  }) async {
    if (pointAnnotation != null)
      pointAnnotationManager?.delete(pointAnnotation!);
    pointAnnotationManager =
        await mapboxMap!.annotations.createPointAnnotationManager();
    pointAnnotation = await pointAnnotationManager!.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)).toJson(),
        iconSize: iconSize ?? 1.3,
        textField: text,
        textColor: textColor?.value ?? Colors.deepPurple.shade900.value,
        textOffset: [0, -2.0],
        textHaloBlur: 33,
        image: marker,
      ),
    );
  }
}
