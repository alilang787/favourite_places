import 'dart:async';
import 'dart:io';
import 'package:favourite_places/providers/provider_fav_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favourite_places/main.dart';
import 'package:favourite_places/models/model_fav_places.dart';
import 'package:favourite_places/screens/add-place/widgets/03_location_picker.dart';
import 'package:favourite_places/screens/add-place/widgets/bottom_bar.dart';
import 'package:favourite_places/screens/add-place/widgets/01_enter_place_name.dart';
import 'package:favourite_places/screens/add-place/widgets/02_image_picker.dart';
import 'package:flutter/material.dart';

enum FocusedPage {
  NameEntry,
  ImagePicker,
  LocPicker,
}

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  String? place_name;
  File? picked_image;
  LocData? loc_data;

  bool _isBothShowen = false;
  int pagePosition = 1;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // _pageController.jumpToPage(2);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pagePosition == 2)
      setState(() {
        _isBothShowen = true;
      });
    else
      setState(() {
        _isBothShowen = false;
      });
    return Scaffold(
      backgroundColor: kColorPrimery.shade50,
      appBar: AppBar(
        title: Text('Add New Place'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                EnterPlaceName(
                  placeNameGetter: _placeNameGetter,
                  place_name: place_name,
                ),
                ImageGetter(
                  imageGetter: _imageGetter,
                  imagePicked: picked_image,
                ),
                LocationPicker(
                  locGetter: _locGetter,
                  adress: loc_data != null ? loc_data!.full_adress : null,
                  mapImg: loc_data != null ? loc_data!.loc_image : null,
                ),
              ],
            ),
          ),
          if (pagePosition == 3 && loc_data != null)
            Container(
              height: 160,
              width: double.infinity,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(fav_provider.notifier).addplace(
                          name: place_name!,
                          image: picked_image!,
                          loc: loc_data!,
                        );
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Horizon',
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
      floatingActionButtonLocation:
          // _isBothShowen?
          FloatingActionButtonLocation.miniEndTop,
      // : FloatingActionButtonLocation.endDocked,
      floatingActionButton: place_name == null
          ? null
          : FloatingActionButton.extended(
              onPressed: null,
              backgroundColor: Colors.white,
              foregroundColor: kColorPrimery,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // if (_pageController.page?.toInt() == 1)
                  if (pagePosition != 1)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_sharp,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          pagePosition -= 1;
                        });
                        _pageController.animateToPage(
                          _pageController.page!.toInt() - 1,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.linear,
                        );
                      },
                    ),
                  if (pagePosition != 3)
                    if (pagePosition != 2 || picked_image != null)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 28,
                        ),
                        onPressed: () async {
                          if (_pageController.page!.toInt() == 0) {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(Duration(milliseconds: 300));
                          }

                          setState(() {
                            pagePosition += 1;
                          });
                          _pageController.animateToPage(
                            _pageController.page!.toInt() + 1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.linear,
                          );
                        },
                      ),
                ],
              ),
            ),
      bottomNavigationBar: BottomBar(
        isBothShowen: _isBothShowen,
      ),
    );
  }

  //      >>>>>>>>>>>>>>   M E T H O D S <<<<<<<<<<<<<<<<<
  void _placeNameGetter(String? val) {
    setState(() {
      place_name = val;
    });
  }

  void _imageGetter(File img) {
    setState(() {
      picked_image = img;
    });
  }

  void _locGetter(LocData loc) {
    setState(() {
      loc_data = loc;
    });
  }
}
