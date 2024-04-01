import 'package:animations/animations.dart';
import 'package:favourite_places/providers/provider_fav_place.dart';
import 'package:favourite_places/screens/add-place/screen_add_place.dart';
import 'package:favourite_places/screens/screen_detail_favplace.dart';
import 'package:favourite_places/widgets/widget_loading.dart';
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
  late Future<bool> _isFetching;

  @override
  void initState() {
    super.initState();

    _isFetching = ref.read(fav_provider.notifier).fetchdata();
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
          Tooltip(
            message: 'add button',
            child: IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddPlaceScreen();
                  },
                ),
              ),
              icon: Icon(Icons.add),
            ),
          )
        ],
      ),
      body: FavPlaces.isEmpty
          ? LoadingWidget(
              pendingFonts: _pendingFonts,
              isFetching: _isFetching,
            )
          : ListView.builder(
              itemCount: FavPlaces.length,
              itemBuilder: (context, index) {
                final place = FavPlaces[index];
                return Dismissible(
                  key: ValueKey(place.id),
                  onDismissed: (direction) {
                    return ref.read(fav_provider.notifier).delPlace(place);
                  },
                  child: AbsorbPointer(
                    absorbing: false,
                    child: OpenContainer(
                      closedBuilder: (context, action) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 36,
                            backgroundImage: FileImage(
                              place.loc_data.loc_image,
                            ),
                          ),
                          title: Text(place.name),
                          subtitle: Text(place.loc_data.full_adress),
                          trailing: LimitedBox(),
                        );
                      },
                      openBuilder: (context, action) {
                        return PlaceDetailScreen(place: place);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
