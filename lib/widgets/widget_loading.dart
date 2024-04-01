import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerWidget({required Widget child}) {
  return Shimmer.fromColors(
    child: child,
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
  );
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    required this.pendingFonts,
    required this.isFetching,
  });
  // : _pendingFonts = pendingFonts;

  final Future pendingFonts;
  final Future<bool> isFetching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: isFetching,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return shimmerWidget(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  return false;
                },
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  // dragStartBehavior: DragStartBehavior.down,
                  itemCount: 10,
                  separatorBuilder: (context, index) {
                    return SizedBox();
                  },
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        radius: 30,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 30,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 12),
                          Container(
                            height: 15,
                            width: 300,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return Container(
              width: 250,
              child: FutureBuilder(
                future: pendingFonts,
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
            );
          }
        },
      ),
    );
  }
}
