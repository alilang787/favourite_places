import 'dart:convert';
import 'dart:io';
import 'package:favourite_places/models/model_fav_places.dart';
import 'package:favourite_places/screens/map-screen/screen_map_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as appDir;
import 'package:favourite_places/main.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class LocationPicker extends StatefulWidget {
  final File? mapImg;
  final String? adress;
  final Function locGetter;
  LocationPicker({
    super.key,
    required this.mapImg,
    required this.adress,
    required this.locGetter,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  bool _isLoading = false;
  File? _mapImage;
  String? _adress;
  List<int>? tempImg;
  @override
  void initState() {
    super.initState();
    _mapImage = widget.mapImg;
    _adress = widget.adress;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 300,
          height: 250,
          decoration: BoxDecoration(
            color: kColorPrimery.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 2,
              color: kColorPrimery.shade100,
            ),
          ),
          child: tempImg == null
              ? null
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.file(
                        _mapImage!,
                        // Uint8List.fromList(tempImg!),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 70,
                          width: 300,
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          color: Colors.white.withOpacity(0.7),
                          child: Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade700,
                              highlightColor: Colors.grey.shade400,
                              child: Text(
                                _adress!,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 130,
              height: 30,
              alignment: Alignment.center,
              child: FittedBox(
                child: _isLoading
                    ? Container(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: Icon(Icons.location_on),
                        label: Text(
                          'Pick Automatic',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              width: 130,
              height: 30,
              alignment: Alignment.center,
              child: FittedBox(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return MapScreen(
                          mapView: MapView.Interacting,
                          locationSaver: _getLoactionArtifacts,
                        );
                      },
                    ));
                  },
                  icon: Icon(Icons.map),
                  label: Text(
                    'Pick on Map',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ));
  }

//
//
//
//     >>>>>>>>>>>>>>>>  M E T H O D S  <<<<<<<<<<<<<<<<<<<<

  void _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
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

    _locationData = await location.getLocation();
    final double lng = _locationData.longitude!;
    final double lat = _locationData.latitude!;

    //   ....Current Location Fetched.....

    await _getLoactionArtifacts(ctx: context, lat: lat, lng: lng);
    setState(() {
      _isLoading = false;
    });
  }

  //   .... getLoactionArtifacts (image & adress)  ....

  Future<bool> _getLoactionArtifacts({
    required BuildContext ctx,
    required double lng,
    required double lat,
  }) async {
    bool worked = await _loadLocationArtifacts(lat: lat, lng: lng);
    if (!worked)
      showAdaptiveDialog(
        context: ctx,
        builder: (ctx) {
          return AlertDialog.adaptive(
            title: Text('Something went wrong!'),
            content: Text('make sure you have working internet connection'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Okey'),
              )
            ],
          );
        },
      );
    return worked;
  }

  Future<bool> _loadLocationArtifacts(
      {required double lng, required double lat}) async {
    const mapBoxKey = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
    if (mapBoxKey.isEmpty) return false;

    final _addressCompos = Uri.parse(
        'https://api.mapbox.com/search/geocode/v6/reverse?longitude=$lng&latitude=$lat&access_token=$mapBoxKey');
    final _staticMapCompos = Uri.parse(
        'https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/pin-s+f53d3d($lng,$lat)/$lng,$lat,16,0/300x250?access_token=$mapBoxKey');

    late Response resp_adress;
    late Response resp_statimg;
    try {
      resp_adress = await http.get(_addressCompos);
      resp_statimg = await http.get(_staticMapCompos);
    } catch (e) {
      return false;
    }

    if (resp_adress.statusCode != 200 ||
        resp_statimg.statusCode != 200 ||
        resp_adress.body.isEmpty ||
        resp_statimg.body.isEmpty) return false;

    final imgBytes = resp_statimg.body.codeUnits;
    final _appdir = await appDir.getTemporaryDirectory();
    final _filePath = path.join(_appdir.path, '${uuid.v4()}.jpg');
    File _imgFile = File(_filePath);

    logger.i(_imgFile.path);
    _imgFile = await _imgFile.writeAsBytes(imgBytes);
    setState(() {
      _adress = json.decode(resp_adress.body)['features'][0]['properties']
          ['full_address'];
      tempImg = imgBytes;
      _mapImage = _imgFile;
    });

    final loc = LocData(
      lng: lng,
      lat: lat,
      full_adress: _adress!,
      loc_image: _mapImage!,
    );
    widget.locGetter(loc);

    return true;
  }
}
