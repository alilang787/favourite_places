import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required bool isBothShowen,
  }) : _isBothShowen = isBothShowen;

  final bool _isBothShowen;

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
              child: Shimmer.fromColors(
                child: FittedBox(child: Text('This is dummy text')),
                baseColor: Colors.white,
                highlightColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (!_isBothShowen)
            Opacity(
              opacity: 0,
              child: CircleAvatar(
                radius: 34,
              ),
            )
        ],
      ),
    );
  }
}
