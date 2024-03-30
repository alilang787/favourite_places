import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

var uuid = Uuid();
var logger = Logger();

class LocData {
  final double lng;
  final double lat;
  final String full_adress;
  final File loc_image;

  LocData({
    required this.lng,
    required this.lat,
    required this.full_adress,
    required this.loc_image,
  });
}

class ModelFavPlace {
  String id;
  final String name;
  final File place_image;
  final LocData loc_data;

  ModelFavPlace({
    required this.name,
    required this.place_image,
    required this.loc_data,
    String? id,
  }) : this.id = id ?? uuid.v4();
}
