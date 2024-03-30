import 'package:flutter/material.dart';

class EnterPlaceName extends StatefulWidget {
  final Function(String? val) placeNameGetter;
  final String? place_name;
  const EnterPlaceName({
    super.key,
    required this.placeNameGetter,
    required this.place_name,
  });

  @override
  State<EnterPlaceName> createState() => _EnterPlaceNameState();
}

class _EnterPlaceNameState extends State<EnterPlaceName> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _textController.text = widget.place_name ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _textController,
            onChanged: (value) {
              bool valid = _formKey.currentState!.validate();
              if (valid && value.trim().length > 2)
                widget.placeNameGetter(value);
              else
                widget.placeNameGetter(null);
            },
            validator: (value) {
              if (value != null && value.trim().length > 0) {
                var _isString = int.tryParse(value.substring(0, 1));

                if (_isString != null) {
                  return 'invalid name *(the first letter should not be number)';
                }
              }
              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'Enter you favourite place name',
            ),
          ),
        ),
      ),
    );
  }
}
