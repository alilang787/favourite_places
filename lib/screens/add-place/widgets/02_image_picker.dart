import 'dart:io';
import 'package:favourite_places/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageGetter extends StatefulWidget {
  ImageGetter({
    super.key,
    required this.imageGetter,
    required this.imagePicked,
  });
  final Function(File img) imageGetter;
  final File? imagePicked;

  @override
  State<ImageGetter> createState() => _ImageGetterState();
}

class _ImageGetterState extends State<ImageGetter> {
  final ImagePicker picker = ImagePicker();
  File? image;

  // File? image;

  void pick_image() async {
    XFile? imageX = await picker.pickImage(source: ImageSource.camera);
    if (imageX != null) {
      setState(() {
        image = File(imageX.path);
      });
      widget.imageGetter(image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePicked != null)
      setState(() {
        image = widget.imagePicked;
      });
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 300,
          height: 250,
          decoration: BoxDecoration(
            color: kColorPrimery.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 2,
              color: kColorPrimery.shade100,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: image == null
                ? null
                : Image.file(
                    image!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: pick_image,
          icon: Icon(Icons.camera),
          label: Text(
            image == null ? 'Pick Image' : 'Pick Again',
            style: TextStyle(
              fontSize: 22,
            ),
          ),
        )
      ],
    ));
  }
}
