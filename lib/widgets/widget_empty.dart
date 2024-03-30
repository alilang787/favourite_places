import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required Future pendingFonts,
  }) : _pendingFonts = pendingFonts;

  final Future _pendingFonts;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          width: 250,
          child: FutureBuilder(
            future: _pendingFonts,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done)
                return Text('Loading');
              else
                return Text(
                  'یہاں پر کچھ نہیں ہے! براہ کرم کچھ نیا منتخب کریں',
                  // maxLines: 10,
                  overflow: TextOverflow.clip,
                  textDirection: TextDirection.rtl,
                  textScaler: TextScaler.linear(2),
                  style: GoogleFonts.notoNastaliqUrdu().copyWith(
                    height: 2.5,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                );
            },
          ),
        ),
      );
  }
}