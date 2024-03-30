import 'dart:convert';
import 'package:favourite_places/models/model_search_places.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OptBuilder extends StatelessWidget {
  final List<SuggestionModel> suggestions_global;
  final String session_token;
  final Function onSelected;
  final Function locationAnimation;
  const OptBuilder({
    super.key,
    required this.session_token,
    required this.suggestions_global,
    required this.onSelected,
    required this.locationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: Material(
        color: Colors.white,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: suggestions_global.length,
          itemBuilder: (ctx, index) {
            final item = suggestions_global[index];
            return InkWell(
              onTap: () async {
                onSelected(item.place_name);
                const mapBoxKey = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
                final retrieve_url = Uri.parse(
                    'https://api.mapbox.com/search/searchbox/v1/retrieve/${item.mapbox_id}?session_token=$session_token&access_token=$mapBoxKey');
                final retrieval_response = await http.get(retrieve_url);
                if (retrieval_response.statusCode != 200 ||
                    retrieval_response.body.isEmpty) return;
                final ret_res_decoded = json.decode(retrieval_response.body);
                final Map coards =
                    ret_res_decoded['features'][0]['properties']['coordinates'];
                locationAnimation(
                  coards['longitude'],
                  coards['latitude'],
                );
              },
              child: ListTile(
                title: Text(item.place_name),
                subtitle: Text(item.full_address),
              ),
            );
          },
        ),
      ),
    );
  }
}
