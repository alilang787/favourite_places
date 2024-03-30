import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class helperLocPicker extends StatefulWidget {
  const helperLocPicker({
    super.key,
  });

  @override
  State<helperLocPicker> createState() => _helperLocPickerState();
}

class _helperLocPickerState extends State<helperLocPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double wfactor = 0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    // _animationController.repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.7),
      ),
      alignment: Alignment.center,
      child: AnimatedTextKit(
        repeatForever: true,
        pause: Duration(milliseconds: 1),
        animatedTexts: [
          ColorizeAnimatedText(
            textAlign: TextAlign.center,
            'Long Tap To Pick Location',
            textStyle: GoogleFonts.fasterOne().copyWith(fontSize: 22),
            speed: Duration(milliseconds: 300),
            colors: [
              Colors.purple,
              Colors.blue,
              Colors.yellow,
              Colors.red,
            ],
          ),
        ],
      ),
    );
  }
}
