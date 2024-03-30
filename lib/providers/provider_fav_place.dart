import 'dart:io';

import 'package:favourite_places/models/model_fav_places.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavPlacesNotify extends StateNotifier<List<ModelFavPlace>> {
  FavPlacesNotify() : super([]);
  void addplace(
      {required String name, required File image, required LocData loc}) {
    final ModelFavPlace place = ModelFavPlace(
      name: name,
      place_image: image,
      loc_data: loc,
    );
    state = [place, ...state];
  }
}

final fav_provider =
    StateNotifierProvider<FavPlacesNotify, List<ModelFavPlace>>((ref) {
  return FavPlacesNotify();
});
