import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BottomBar extends StatefulWidget {
  final int index;
  const BottomBar({
    super.key,
    required this.index,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final List<String> bottomText = [
    'Place Name',
    'Place Image',
    'Place Location'
  ];
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      shape: CircularNotchedRectangle(),
      color: Theme.of(context).primaryColor.withOpacity(0.9),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 60,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Shimmer.fromColors(
                  child: Row(
                    children: [
                      Text('Pick your '),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position:
                                Tween(begin: Offset(0, 1), end: Offset(0, 0))
                                    .animate(animation),
                            child: child,
                          );
                        },
                        child: Text(
                          key: ValueKey(widget.index - 1),
                          bottomText[widget.index - 1],
                        ),
                      ),
                    ],
                  ),
                  baseColor: Colors.white,
                  highlightColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
