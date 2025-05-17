import 'dart:async';
import 'dart:convert';
import 'package:anapurna_app/resto-side/resto-home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapSearchPlacesApi extends StatefulWidget {
  const GoogleMapSearchPlacesApi({super.key});

  @override
  State<GoogleMapSearchPlacesApi> createState() =>
      _GoogleMapSearchPlacesApiState();
}

class _GoogleMapSearchPlacesApiState extends State<GoogleMapSearchPlacesApi> {
  final _controller = TextEditingController();
  String _sessionToken = '';
  List<dynamic> _placeList = [];
  Timer? _debounce;

  late String _gomapsApiKey = '${dotenv.env['mapKey']}';

  @override
  void initState() {
    super.initState();
    _gomapsApiKey = dotenv.env['mapKey'] ?? '';
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_sessionToken.isEmpty) {
        setState(() {
          _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
        });
      }
      if (_controller.text.isNotEmpty) {
        getSuggestion(_controller.text);
      }
    });
  }

  Future<void> getSuggestion(String input) async {
    String baseURL = 'https://maps.gomaps.pro/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$_gomapsApiKey&sessiontoken=$_sessionToken';

    try {
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          print('Suggestions: $data');
        }
        setState(() {
          _placeList = data['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeId&key=$_gomapsApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          if (kDebugMode) {
            print('Selected Location Coordinates: $location');
          }
          return location;
        }
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Select Your Restaurant Location'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search your restaurant location...",
                prefixIcon: const Icon(Icons.map),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => _controller.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_placeList[index]["description"]),
                  onTap: () async {
                    final placeId = _placeList[index]["place_id"];
                    final location = await getPlaceDetails(placeId);
                    if (location != null) {
                      final lat = location['lat'];
                      final lng = location['lng'];

                      // Optionally save to local state or Firestore here

                      // Navigate to HomePage with the selected coordinates
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantHomePage(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
