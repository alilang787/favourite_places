import 'package:animations/animations.dart';
import 'package:favourite_places/models/model_fav_places.dart';
import 'package:favourite_places/screens/map-screen/screen_map_main.dart';
import 'package:flutter/material.dart';

class PlaceDetailScreen extends StatelessWidget {
  final ModelFavPlace place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: Stack(
        children: [
          Image.file(
            place.place_image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: OpenContainer(
                transitionDuration: Duration(milliseconds: 700),
                transitionType: ContainerTransitionType.fadeThrough,
                closedColor: Colors.transparent,
                openColor: Colors.transparent,
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60)),
                closedBuilder: (context, action) {
                  return CircleAvatar(
                    radius: 85,
                    backgroundImage: FileImage(place.loc_data.loc_image),
                  );
                },
                openBuilder: (context, action) {
                  return MapScreen(
                    mapView: MapView.OverView,
                    lng: place.loc_data.lng,
                    lat: place.loc_data.lat,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
