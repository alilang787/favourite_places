import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum Layers {
  Streets,
  Outdoors,
  Light,
  Dark,
  Satellite,
  SatelliteStreets,
  NavigationDay,
  NavigationNight,
}

class BottomModelSheet extends StatefulWidget {
  final Function(String layer) mapStyleChanger;
  BottomModelSheet({super.key, required this.mapStyleChanger});

  @override
  State<BottomModelSheet> createState() => _BottomModelSheetState();
}

class _BottomModelSheetState extends State<BottomModelSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  int tappedIndex = 0;
  final Map<Layers, String> Styles = {
    Layers.Streets: 'mapbox://styles/mapbox/streets-v12',
    Layers.Outdoors: 'mapbox://styles/mapbox/outdoors-v12',
    Layers.Light: 'mapbox://styles/mapbox/light-v11',
    Layers.Dark: 'mapbox://styles/mapbox/dark-v11',
    Layers.Satellite: 'mapbox://styles/mapbox/satellite-v9',
    Layers.SatelliteStreets: 'mapbox://styles/mapbox/satellite-streets-v12',
    Layers.NavigationDay: 'mapbox://styles/mapbox/navigation-day-v1',
    Layers.NavigationNight: 'mapbox://styles/mapbox/navigation-night-v1',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Map type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 22),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 80,
                    mainAxisExtent: 80,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemCount: Styles.length,
                itemBuilder: (context, index) {
                  bool _isTapped = tappedIndex == index;
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 700),
                    transitionBuilder: (child, animation) {
                      return AnimatedBuilder(
                        child: child,
                        animation: animation,
                        builder: (context, child) {
                          return Transform(
                            child: child,
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(1, 2, 1)
                              ..rotateY(3.14 + animation.value * 3.14),
                          );
                        },
                      );
                    },
                    child: GestureDetector(
                      key: ValueKey(_isTapped),
                      onTap: () {
                        setState(() {
                          tappedIndex = index;
                        });
                        widget.mapStyleChanger(Styles[Layers.values[index]]!);
                      },
                      child: Column(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                width: 3,
                                color: _isTapped ? Colors.green : Colors.grey,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                _getIcon(Layers.values[index]),
                                color: _isTapped ? Colors.green : Colors.black,
                              ),
                            ),
                          ),
                          // SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              Layers.values[index].name,
                              style: TextStyle(
                                color: _isTapped ? Colors.green : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  IconData _getIcon(Layers layer) {
    if (layer == Layers.Streets)
      return Icons.streetview;
    else if (layer == Layers.Outdoors)
      return Icons.door_sliding_outlined;
    else if (layer == Layers.Light)
      return Icons.light;
    else if (layer == Layers.Dark)
      return Icons.dark_mode_outlined;
    else if (layer == Layers.Satellite)
      return Icons.satellite_alt_outlined;
    else if (layer == Layers.SatelliteStreets)
      return Icons.satellite_alt_rounded;
    else if (layer == Layers.SatelliteStreets)
      return Icons.satellite_alt_rounded;
    else if (layer == Layers.NavigationDay)
      return Icons.nat;
    else if (layer == Layers.NavigationNight)
      return Icons.navigation_sharp;
    else
      return Icons.abc;
  }
}
