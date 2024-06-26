// import 'package:favourite_places/main_fav_places.dart';

import 'package:favourite_places/main_fav_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

//  Hello main

void main() {
  const mapBoxKey = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(mapBoxKey);
  // GoogleFonts.config.allowRuntimeFetching = false;
  runApp(ProviderScope(
  
    
    child: const MyApp(),
  ));
}

const MaterialColor kColorPrimery = Colors.deepPurple;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favourite Places',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home:FavouritePlacesMain(),
    );
  }
}
