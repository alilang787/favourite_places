import 'dart:io';

import 'package:favourite_places/models/model_fav_places.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class FavPlacesNotify extends StateNotifier<List<ModelFavPlace>> {
  FavPlacesNotify() : super([]);

  //  fetch data form database on load.............

  Future<bool> fetchdata() async {
    // await Future.delayed(Duration(seconds: 3));
    final database = await _getDatabase();
    final data = await database.query('fav_places');
    final List<ModelFavPlace> list = data.map((e) {
      return ModelFavPlace(
        id: e['id'] as String,
        name: e['name'] as String,
        place_image: File(e['place_image'] as String),
        loc_data: LocData(
          lng: e['lng'] as double,
          lat: e['lat'] as double,
          full_adress: e['full_adress'] as String,
          loc_image: File(e['loc_image'] as String),
        ),
      );
    }).toList();

    state = list;
    return true;
  }

  //   add new place to database ..........................

  addplace({
    required String name,
    required File image_raw,
    required LocData loc_raw,
  }) async {
    final appDir = await syspath.getApplicationDocumentsDirectory();

    File image = await image_raw
        .copy(path.join(appDir.path, path.basename(image_raw.path)));

    File loc_image = await loc_raw.loc_image
        .copy(path.join(appDir.path, path.basename(loc_raw.loc_image.path)));

    final ModelFavPlace place = ModelFavPlace(
      name: name,
      place_image: image,
      loc_data: LocData(
        lng: loc_raw.lng,
        lat: loc_raw.lat,
        full_adress: loc_raw.full_adress,
        loc_image: loc_image,
      ),
    );

    final database = await _getDatabase();
    try {
      await database.insert('fav_places', {
        'id': place.id,
        'name': place.name,
        'place_image': place.place_image.path,
        'full_adress': place.loc_data.full_adress,
        'loc_image': place.loc_data.loc_image.path,
        'lng': place.loc_data.lng,
        'lat': place.loc_data.lat,
      });
    } catch (e) {
      logger.i(e.toString());
    }

    state = [place, ...state];
  }

  //   add new place to database ..........................

  delPlace(ModelFavPlace place) async {
    await place.place_image.delete();
    await place.loc_data.loc_image.delete();
    final db = await _getDatabase();
    int val =
        await db.delete('fav_places', where: 'id = ?', whereArgs: [place.id]);
    logger.i(val);

    state = state.where((element) => element != place).toList();
  }
}

// .................    Provider .............
final fav_provider =
    StateNotifierProvider<FavPlacesNotify, List<ModelFavPlace>>((ref) {
  return FavPlacesNotify();
});

//    ................  Outie Methods ................

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final database = await sql.openDatabase(
    path.join(dbPath, 'fav_places.db'),
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE fav_places (id TEXT PRIMARY KEY, name TEXT, place_image TEXT, full_adress TEXT,loc_image TEXT, lng REAL, lat REAL)');
    },
    version: 1,
  );
  return database;
}
