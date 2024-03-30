import 'package:favourite_places/providers/provider_fav_place.dart';
import 'package:favourite_places/screens/add-place/screen_add_place.dart';
import 'package:favourite_places/widgets/widget_empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FavouritePlacesMain extends ConsumerStatefulWidget {
  const FavouritePlacesMain({super.key});

  @override
  ConsumerState<FavouritePlacesMain> createState() =>
      _FavouritePlacesMainState();
}

class _FavouritePlacesMainState extends ConsumerState<FavouritePlacesMain> {
  late Future _pendingFonts;

  @override
  void initState() {
    super.initState();
    _pendingFonts = GoogleFonts.pendingFonts([GoogleFonts.notoNastaliqUrdu()]);
  }

  // Future<void> fontPending() async {
  //   // await Future.delayed(Duration(seconds: 5));
  //   await GoogleFonts.alike();
  //   // await GoogleFonts.pendingFonts();
  // }

  @override
  Widget build(BuildContext context) {
    final FavPlaces = ref.watch(fav_provider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite Places'),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        foregroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return AddPlaceScreen();
                },
              ),
            ),
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: FavPlaces.isEmpty
          ? EmptyWidget(pendingFonts: _pendingFonts)
          : ListView.builder(
              itemCount: FavPlaces.length,
              itemBuilder: (context, index) {
                final place = FavPlaces[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 36,
                    backgroundImage: FileImage(
                      place.place_image,
                    ),
                  ),
                  title: Text(place.name),
                  subtitle: Text(place.loc_data.full_adress),
                );
              },
            ),
    );
  }
}
